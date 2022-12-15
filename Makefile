MAKEFLAGS += --silent
MAKEFLAGS += --no-print-directory

run:
	@-$(MAKE) clean
	@-docker build -t docsbuilder .
	@-docker create --name solution docsbuilder
	@-docker cp solution:/app/assets ${PWD}
	@-docker cp solution:/app/openapi/auto-generated-spec ${PWD}/openapi
	@-docker cp solution:/app/openapi/descriptions.yaml ${PWD}/openapi
	@-docker cp solution:/app/openapi/descriptions-missing.yaml ${PWD}/openapi
	@-docker cp solution:/app/openapi/descriptions-not-used.yaml ${PWD}/openapi
	@-docker rm -f solution

script:
	@-node ./src/main.js $(option)

simplified:
	@-clear
	@-$(MAKE) clean
	@-$(MAKE) script option="specGenerator"
	@-$(MAKE) script option="specParser"
	@-rm -rf .tmp
	@-mkdir -p ./assets/openapi
	@-$(MAKE) script option=bundle

complete: simplified postman spell lint descriptions

spell:
	@-mkdir -p ./assets/errors-spell
	@-$(MAKE) script option=spell
	@-$(MAKE) script option=csharp

lint:
	@-mkdir -p ./assets/errors-lint
	@-$(MAKE) script option=lint

postman:
	@-mkdir -p ./assets/postman
	@-$(MAKE) script option=postman

descriptions:
	@-mkdir -p ./assets/descriptions
	@-$(MAKE) script option=descriptions

clean:
	@-rm -rf ./assets
	@-rm ./openapi/descriptions-missing.yaml 2> /dev/null || true
	@-rm ./openapi/descriptions-not-used.yaml 2> /dev/null || true
