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

# Commands for Docker
.PHONY: docker_startapp
docker_startapp:
	@read -p "Enter new django app name: " app_name; \
	docker-compose run --rm app sh -c "python manage.py startapp $$app_name"

.PHONY: docker_build
docker_build:
	docker-compose build --no-cache app

.PHONY: docker_createsuperuser
docker_createsuperuser:
	docker-compose run --rm app sh -c "python manage.py createsuperuser"

.PHONY: docker_test
docker_test:
	docker-compose run --rm app sh -c "coverage run manage.py test && coverage report -m && flake8 --max-line-length=120" --parallel

docker_up:
	docker-compose up

docker_up_bg:
	docker-compose up -d

docker_update:
	docker-compose down
	docker-compose up --build

docker_down:
	docker-compose down

docker_logs:
	docker-compose logs -f $(ARG)

docker_makemigrations:
	docker-compose run --rm app python manage.py makemigrations

docker_migrate:
	docker-compose run --rm app python manage.py migrate

docker_createstatic:
	docker-compose run --rm app python manage.py createstatic

docker_armageddon:
	docker system prune