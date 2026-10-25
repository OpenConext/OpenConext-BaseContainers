FROM eclipse-temurin:21-jre-alpine
RUN apk add --no-cache curl
HEALTHCHECK \
      --start-period=30s \
      --start-interval=1s \
      --interval=10s \
      --timeout=1s \
      --retries=20 \
      CMD curl --fail -s -o /dev/null -w "%{http_code}" http://localhost/internal/health
