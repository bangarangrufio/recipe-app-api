SHELL := /bin/bash # Use bash syntax
ARG := $(word 2, $(MAKECMDGOALS) )

clean:
	@find . -name "*.pyc" -exec rm -rf {} \;
	@find . -name "__pycache__" -delete

poetry_install:
	poetry install --no-root

poetry_test:
	poetry run app/manage.py test app/ $(ARG) --parallel --keepdb

poetry_test_reset:
	poetry run app/manage.py test app/ $(ARG) --parallel

ruff_check:
	poetry run ruff check .

ruff_check_fix:
	poetry run ruff check . --fix

ruff_format:
	poetry run ruff format .

# Commands for Docker version
docker_setup:
	docker-compose build --no-cache app

docker_test:
	docker-compose run --rm app sh -c "python manage.py test && ruff check ." --parallel

docker_up:
	docker-compose up -d

docker_update:
	docker-compose down
	docker-compose up -d --build

docker_down:
	docker-compose down

docker_logs:
	docker-compose logs -f $(ARG)

docker_makemigrations:
	docker-compose run --rm app python manage.py makemigrations

docker_migrate:
	docker-compose run --rm app python manage.py migrate