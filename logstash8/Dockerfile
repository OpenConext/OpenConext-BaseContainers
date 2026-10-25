FROM docker.elastic.co/logstash/logstash:8.19.20

USER root

RUN mkdir -p /var/log/logstash && chown -R logstash:logstash /var/log/logstash

USER logstash

RUN bin/logstash-plugin install logstash-output-influxdb
