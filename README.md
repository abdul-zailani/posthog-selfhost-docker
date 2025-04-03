# 📘 Infrastruktur PostHog Self-hosted

## 🧩 Ringkasan Stack

| Komponen         | Detail                                         |
|------------------|------------------------------------------------|
| **PostHog**      | v1.43.0 (self-hosted)                          |
| **Orkestrasi**   | Docker Compose                                 |
| **Lingkungan**   | Local Dev / Staging / Production               |
| **Reverse Proxy**| Caddy (otomatis HTTPS via Let's Encrypt)       |
| **Database**     | PostgreSQL 12.13                               |
| **Event Store**  | ClickHouse 22.8 (custom log minimal)           |
| **Queue**        | Kafka + Zookeeper                              |
| **Cache**        | Redis 6.2                                      |
| **Object Storage** | MinIO (bucket: `posthog`)                    |

---

## 📂 Struktur Direktori

```
posthog-docker-compose-poc/
├── .env
├── .env.example
├── docker-compose.yml
├── Makefile
├── README.md
├── caddy/
│   └── Caddyfile
├── clickhouse-posthog/
│   ├── Dockerfile
│   ├── log-server-config.xml
│   └── log-users-config.xml
└── .github/
    └── workflows/
        └── docker-compose.yml
```

---

## 🚀 Prosedur Deploy

1. **Clone & Setup**
   ```bash
   git clone git@github.com:your-org/posthog-stack.git
   cd posthog-stack
   cp .env.example .env
   ```

2. **Build image & pull dependency**
   ```bash
   make build
   make pull
   ```

3. **Start core services terlebih dahulu**
   > Pastikan database, Kafka, ClickHouse, dan object storage sudah running
   ```bash
   make start-core
   ```

4. **Jalankan migrasi database**
   ```bash
   make migrate
   ```

5. **Jalankan semua service PostHog**
   ```bash
   make start-posthog
   ```

6. **(Opsional) Cek status migrasi async**
   ```bash
   docker compose run --rm asyncmigrationscheck
   ```

---

## 💾 Named Volumes

| Volume Name          | Fungsi                   |
|----------------------|--------------------------|
| `postgres_data`      | Penyimpanan PostgreSQL   |
| `clickhouse_data`    | Data ClickHouse          |
| `zookeeper_data`     | Data Zookeeper           |
| `zookeeper_datalog`  | Datalog Zookeeper        |
| `zookeeper_logs`     | Log Zookeeper            |
| `object_storage_data`| Bucket MinIO             |
| `caddy_data`         | TLS certs Caddy          |
| `caddy_config`       | Konfigurasi Caddy        |

---

## 🔐 Keamanan

- Pastikan `.env` tidak di-commit (`.gitignore` sudah disiapkan).
- Gunakan HTTPS via Caddy dengan auto TLS.
- Gunakan password acak untuk:
  - `MINIO_ROOT_PASSWORD`
  - `SECRET_KEY`
- Gunakan `chmod 600 .env` untuk membatasi akses file.

---

## 🔁 Backup & Restore

### Backup:
```bash
docker run --rm -v posthog-docker-compose-poc_postgres_data:/data busybox tar czf - /data > pg_backup.tar.gz
```

### Restore:
```bash
docker run --rm -v posthog-docker-compose-poc_postgres_data:/data -i busybox tar xzf - < pg_backup.tar.gz
```

---

## ✅ CI/CD Pipeline (GitHub Actions)

- Workflow build & healthcheck otomatis tersedia di:
  `.github/workflows/docker-compose.yml`

### Yang dicek:
- `docker compose build`
- `docker compose up -d`
- Healthcheck container
- Cek async migrations

---

## 🔧 Upgrade PostHog

1. Update image di `docker-compose.yml`:
   ```yaml
   image: posthog/posthog:release-1.44.0
   ```

2. Jalankan:
   ```bash
   docker compose pull
   make start-core
   make migrate
   make start-posthog
   ```
