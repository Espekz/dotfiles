up:
	docker-compose up -d

down:
	docker-compose down

bash:
	docker-compose exec php bash

console:
	docker-compose exec php php bin/console

test:
	docker-compose exec php php bin/phpunit

migrate:
	docker-compose exec php php bin/console doctrine:migrations:migrate --no-interaction