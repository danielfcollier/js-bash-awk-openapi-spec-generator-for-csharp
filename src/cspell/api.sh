#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
basename=$1;

### Source Code:

inputFile="./assets/openapi/${basename}.yaml";
outputFile="./assets/errors-spell/${basename}-errors.csv";

npx cspell --local=en,es,pt --unique --relative --no-summary --no-progress ${inputFile} \
  | gawk -i ./src/utils/functions.awk '{ print substr(trim($5),  2, length(trim($5)) - 2), "," , "," , $1 }' \
  | sort --ignore-case --unique --field-separator=, --key=1,1 \
  > ${outputFile};

# More cspell options: --show-suggestions

result=$(wc -l ${outputFile} | gawk '{ print $1 }');
echo "#" ${basename}":" ${result} "spelling errors founds.";

if (( ${result} == 0 )); then
  rm ${outputFile};
fi