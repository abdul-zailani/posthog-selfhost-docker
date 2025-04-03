
FROM alpine AS downloader
RUN apk add curl
RUN curl -L https://github.com/PostHog/posthog/archive/refs/tags/1.43.0.tar.gz | tar zxv

FROM clickhouse/clickhouse-server:22.8

# Copy konfigurasi dan skema dari source PostHog
COPY --from=downloader /posthog-1.43.0/posthog/idl/                                  /idl/
COPY --from=downloader /posthog-1.43.0/docker/clickhouse/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
COPY --from=downloader /posthog-1.43.0/docker/clickhouse/config.xml                 /etc/clickhouse-server/config.xml
COPY --from=downloader /posthog-1.43.0/docker/clickhouse/users.xml                  /etc/clickhouse-server/users.xml

# Tambahkan konfigurasi logging minimal
COPY ./log-server-config.xml                  /etc/clickhouse-server/config.d/
COPY ./log-users-config.xml                   /etc/clickhouse-server/users.d/
