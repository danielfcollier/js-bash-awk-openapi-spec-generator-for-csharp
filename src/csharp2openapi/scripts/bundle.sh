#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
basename=$1;

### Source Code:

inputFile="./${OPENAPI}/apis/${basename}.yaml";
outputFile="./${ASSETS}/${OPENAPI}/${basename}.yaml";

npx @redocly/openapi-cli bundle ${inputFile} --dereferenced --output ${outputFile};
