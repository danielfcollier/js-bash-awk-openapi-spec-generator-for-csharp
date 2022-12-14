run:
	@docker build -t docsbuilder .
	@docker create --name solution docsbuilder
	@docker cp solution:/app/assets ${PWD}
	@docker cp solution:/app/openapi/auto-generated-spec ${PWD}/openapi
	@docker cp solution:/app/openapi/descriptions-missing.yaml ${PWD}/openapi
	@docker cp solution:/app/openapi/descriptions-not-used.yaml ${PWD}/openapi
	@docker rm -f solution

api: api-build api-bundle

api-build:
	@bash ./src/csharp2openapi/build.sh 1

api-bundle:
	@bash ./src/csharp2openapi/bundler.sh

descriptions:
	@bash ./src/utils/descriptions-update.sh

clean:
	@rm -rf ./assets
	@rm -rf ./assets
	@rm -rf ./openapi/auto-generated-spec
	@rm ./openapi/descriptions-missing.yaml
	@rm ./openapi/descriptions-not-used.yaml

cspell: cspell-api cspell-csharp

cspell-api:
	@bash ./src/cspell-tools/apis.sh

cspell-csharp:
	@bash ./src/cspell-tools/csharp.sh

lint:
	@bash ./src/csharp2openapi/linter.sh