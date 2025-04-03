.PHONY: help build pull migrate up down \
        start-core start-posthog start-all stop-all logs

help:
	@grep -E '^[a-zA-Z_-]+:.*?

build: 
	docker compose build

pull: 
	docker compose pull

migrate:
	@echo "🔍 Pastikan service postgres sudah running..."
	docker compose ps | grep postgres | grep "running" > /dev/null || \
		( echo "❌ Service postgres belum jalan. Jalankan: make start-core"; exit 1 )
	docker compose run --rm web ./bin/migrate


up: 
	docker compose up -d

down: 
	docker compose down

start-core: 
	docker compose up -d postgres redis zookeeper kafka clickhouse object_storage


start-posthog: 
	docker compose up -d web plugins worker caddy

stop-all: 
	docker compose down -v

logs: 
	docker compose logs -f
