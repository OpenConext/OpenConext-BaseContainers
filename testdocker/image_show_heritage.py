import json
import sys
from datetime import datetime
from zoneinfo import ZoneInfo

# Import the Registry provider directly to avoid the brittle 'OrasClient' wrapper
import oras.container
import oras.provider

TIME_ZONE = "Europe/Amsterdam"


def parse_purl_to_ref(uri: str, digest_dict):
    """
    Translates a Buildx PURL (pkg:docker/...) into a standard OCI reference.
    """
    # 1. Remove the scheme prefix
    # Result: "debian@bookworm?platform=..." or "ghcr.io/owner/repo@sha..."
    path = uri.replace("pkg:docker/", "")

    # 2. Strip the query parameters (platform info)
    # Result: "debian@bookworm" or "ghcr.io/owner/repo"
    path = path.split('?')[0]

    # 3. Strip the tag if present (after the @)
    # We rely entirely on the digest for the audit trail
    repo = path.split('@')[0]

    # 4. Determine the Registry and Namespace logic
    parts = repo.split('/')

    if len(parts) == 1:
        # Case: 'debian' -> 'docker.io/library/debian'
        full_ref = f"docker.io/library/{repo}"
    elif "." not in parts[0] and "localhost" not in parts[0]:
        # Case: 'myuser/myrepo' -> 'docker.io/myuser/myrepo'
        # (Checking for a '.' in the first part is a standard way to detect a hostname)
        full_ref = f"docker.io/{repo}"
    else:
        # Case: 'ghcr.io/owner/repo' -> stays as is
        full_ref = repo

    # 5. Append the immutable digest
    sha = digest_dict.get("sha256")
    return f"{full_ref}@sha256:{sha}"


# get a correct Registry for the specified image
def get_registry_provider(insecure=False):
    reg = oras.provider.Registry(insecure=insecure)
    return reg


# fetch manifest for the specified image
def get_manifest(image_ref: str, reg: oras.provider.Registry | None = None) -> tuple[oras.provider.Registry, dict]:
    if reg is None:
        # Detect which registry we are talking to
        is_local = "hamlet" in image_ref or "localhost" in image_ref
        reg = get_registry_provider(insecure=is_local)

    if reg is None:
        raise Exception(f"No registry provider found for image {image_ref}")

    manifest = reg.get_manifest(construct_image_ref(image_ref))
    return reg, manifest


# fetch blob for the specified ref
def get_blob(ref: str, digest: str, reg: oras.provider.Registry | None = None) -> tuple[oras.provider.Registry, dict]:
    if reg is None:
        # Detect which registry we are talking to
        is_local = "hamlet" in ref or "localhost" in ref
        reg = get_registry_provider(insecure=is_local)

    if reg is None:
        raise Exception(f"No registry provider found for image {ref}")

    resp = reg.get_blob(construct_image_ref(ref), digest)
    data = resp.json()
    return data


# get the created date from a manifest file
def get_created_from_manifest(image_ref: str, manifest: dict, reg: oras.provider.Registry) -> datetime | None:
    config_desc = manifest.get("config")
    if not config_desc:
        return None

    digest = config_desc.get("digest")
    #resp = reg.get_blob(construct_image_ref(image_ref), digest)
    #data = resp.json()
    data = get_blob(image_ref, digest, reg)
    if "created" in data:
        created = datetime.fromisoformat(data["created"])
        return created.astimezone(ZoneInfo(TIME_ZONE))
    else:
        return None


def get_build_date(image_ref: str, manifest: dict, reg: oras.provider.Registry) -> list[tuple[str, str, datetime|None]]:
    # OCI/Docker media types for manifest lists vs single-arch manifests
    INDEX_MEDIA_TYPES = {
        "application/vnd.oci.image.index.v1+json",
        "application/vnd.docker.distribution.manifest.list.v2+json",
    }

    # media typeis is either an index (application/vnd.oci.image.index.v1+json) or a real manifest
    # (application/vnd.oci.image.manifest.v1+json)
    media_type = manifest.get("mediaType", "")

    if media_type in INDEX_MEDIA_TYPES or "manifests" in manifest:
        # It's a manifest list / OCI index — recurse into each platform entry
        results: list[tuple[str, str, datetime|None]] = []
        for entry in manifest.get("manifests", []):
            digest = entry.get("digest")
            platform_info = entry.get("platform", {})
            platform_str = "{}/{}".format(
                platform_info.get("os", "?"),
                platform_info.get("architecture", "?")
            )

            # Skip attestation manifests injected by BuildKit
            # These have platform.os == "unknown" and are not real images
            if platform_info.get("os") == "unknown":
                continue

            # Build a ref for the specific platform manifest using its digest
            container = oras.container.Container(image_ref)
            platform_ref = f"{container.registry}/{container.api_prefix}@{digest}"

            platform_ref = construct_image_ref(image_ref, digest)

            _, submanifest = get_manifest(platform_ref, reg)
            created = get_created_from_manifest(image_ref, submanifest, reg)

            results.append((platform_ref, platform_str, created))
        return results
    else:
        created = get_created_from_manifest(image_ref, manifest, reg)

        return [(image_ref, "unknown/unknown", created)]


# given an existing image, return a new image ref with the specified digest
def construct_image_ref(image_ref: str, digest: str|None = None) -> str:
    container = oras.container.Container(image_ref)

    if container.registry == "docker.io":
        container.registry = "index.docker.io"

    if digest is not None:
        container.digest = digest

    ref = container.uri
    return ref


def walk_ancestry(image_ref, insecure=True):
    print(f"{'IMAGE REFERENCE':<65} | {'PLATFORM':<12} | {'CREATED':<32}")
    print("-" * 130)

    current_ref = image_ref
    if True:
        # 1. Get the Manifest (Index or Image)
        # This method is stable across nearly all oras versions
        print(f"getting {current_ref}")

        reg, manifest = get_manifest(current_ref)

        created = get_build_date(current_ref, manifest, reg)
        for idx, i in enumerate(created):
            container = oras.container.Container(image_ref)
            ref_str = "/".join((container.registry, container.api_prefix)) if idx==0 else ""
            print(f"{ref_str:<65} | {i[1]:<12} | {i[2].strftime("%Y-%m-%d %H:%M"):<32}")

        # 3. Navigate the SLSA Provenance
        # We look for the 'unknown' platform entry which holds the build secrets
        parent_ref = None
        parent_digest = None
        for m in manifest.get('manifests', []):
            if m.get('platform', {}).get('os') == 'unknown':

                #attestation_ref = f"{current_ref.rsplit(':', 1)[0]}@{m['digest']}"
                attestation_ref = construct_image_ref(current_ref, m['digest'])
                #attestation_manifest = reg.get_manifest(attestation_ref)
                _, attestation_manifest = get_manifest(attestation_ref)

                # 2. The actual SLSA JSON is usually the first layer of THIS manifest
                if 'layers' in attestation_manifest and len(attestation_manifest['layers']) > 0:
                    slsa_layer_digest = attestation_manifest['layers'][0]['digest']

                    # 3. NOW you can call get_blob for the actual JSON content
                    #att_resp = reg.get_blob(current_ref, slsa_layer_digest)
                    #att = att_resp.json()
                    att = get_blob(current_ref, slsa_layer_digest, reg)

                    # Safely navigate SLSA structure
                    predicate = att.get('predicate', {})

                    if False:
                        if "packages" in predicate:
                            del predicate["packages"]
                        if "files" in predicate:
                            del predicate["files"]
                        if "relationships" in predicate:
                            del predicate["relationships"]
                        print(json.dumps(predicate, indent=4))

                    build_def = predicate.get('buildDefinition', {})
                    deps = build_def.get('resolvedDependencies', [])
                    for dep in deps:
                        parent_ref = dep.get('uri', '')
                        parent_digest = dep.get('digest', '')

                        # recurse
                        if parent_ref and parent_ref != current_ref:
                            current_ref = parse_purl_to_ref(parent_ref, parent_digest)
                            walk_ancestry(current_ref, insecure)




def test():
    registry = get_registry_provider()

    # Fetch the manifest
    # MUST use index.docker.io for the API to work with ORAS
    image = "ghcr.io/openconext/openconext-engineblock/openconext-engineblock"
    manifest = registry.get_manifest(image)

    print("Media Type:", manifest.get("mediaType"))
    print("Schema Version:", manifest.get("schemaVersion"))

    print("\nLayers:")
    for layer in manifest.get("layers", []):
        print(f" - {layer.get('mediaType')} ({layer.get('size')} bytes)")


if __name__ == "__main__":
    # Ensure we capture the image from CLI
    if len(sys.argv) > 1:
        target = sys.argv[1]
    else:
        target = 'ghcr.io/openconext/openconext-engineblock/openconext-engineblock'
        #target = 'docker.io/library/composer@sha256:3788b2e8abbae045c2d9884b766cb91a7f294816b24d2b8965ee16ca99172ece'
        #target = 'ghcr.io/openconext/openconext-engineblock/openconext-engineblock:latest@sha256:a4b58f9349d3ee69c0be74783b64cbbf86d85931a3d586693809f30245ea716c'

    # Auto-detect insecure for localhost
    use_insecure = "localhost" in target or "hamlet" in target
    walk_ancestry(target, insecure=use_insecure)
