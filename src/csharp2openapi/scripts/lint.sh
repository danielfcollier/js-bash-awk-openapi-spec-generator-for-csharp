#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
basename=$1;

### Source Code:

inputFile="./assets/openapi/${basename}.yaml";
outputFile="./assets/errors-lint/${basename}-errors.txt";

# Most errors are due to missing ERROR RESPONSES in the OpenAPI file
npx @redocly/openapi-cli lint ${inputFile} 2> ${outputFile};
