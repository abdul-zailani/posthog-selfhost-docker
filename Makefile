.PHONY: up down build migrate

build:
	docker compose build

pull:
	docker compose pull

migrate:
	docker compose run --rm web ./bin/migrate

up:
	docker compose up -d worker plugins web caddy

down:
	docker compose down
