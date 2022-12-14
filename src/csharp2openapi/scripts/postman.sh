#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
basename=$1;

### Source Code:

inputFile="./${ASSETS}/${OPENAPI}/${basename}.yaml";
outputFile="${ASSETS}/postman/${basename}-collection.json";

npx openapi-to-postmanv2 -s ${inputFile} -o ${outputFile} -p \
  -O folderStrategy=Tags,keepImplicitHeaders=true,requestParametersResolution=Example,includeAuthInfoInExample=false;
