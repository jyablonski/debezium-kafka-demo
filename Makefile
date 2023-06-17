.PHONY: up
up:
	@docker compose up -d

.PHONY: down
down:
	@docker compose down

.PHONY: ksql
ksql:
	@docker exec -it ksqldb ksql http://ksqldb:8088

.PHONY: follow-logs
follow-logs:
	@docker-compose logs -f kafka-connect

PHONY: git-rebase
git-rebase:
	@git checkout master
	@git pull
	@git checkout test-123
	@git rebase master
	@git push

.PHONY: bump-patch
bump-patch:
	@bump2version patch
	@git push --tags
	@git push

.PHONY: bump-minor
bump-minor:
	@bump2version minor
	@git push --tags
	@git push

.PHONY: bump-major
bump-major:
	@bump2version major
	@git push --tags
	@git push
