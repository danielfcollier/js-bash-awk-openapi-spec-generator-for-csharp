#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
basename=$1;

### Source Code:

inputFile="./openapi/apis/${basename}.yaml";
outputFile="./assets/openapi/${basename}.yaml";

npx @redocly/openapi-cli bundle ${inputFile} --dereferenced --output ${outputFile};
