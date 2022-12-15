#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
basename=$1;

### Source Code:

root="csharp";
outputFile="./assets/errors-spell/${root}-errors.csv";

ls -R ${root} \
  | gawk '{ if (substr($0, 1, 1) == ".") print substr($0, 1, length($0) - 1)"/**/*.cs" }' \
  | xargs npx cspell --local=en,es,pt --unique --relative --no-summary --no-progress \
  | gawk -i "./src/utils/functions.awk" '{ print substr(trim($5),  2, length(trim($5)) - 2), "," , "," , $1 }' \
  | sort --ignore-case --unique --field-separator=, --key=1,1 \
  > ${outputFile};

result=$(wc -l ${outputFile} | gawk '{ print $1 }');
echo "#" ${root}":" ${result} "spelling errors founds.";

if (( ${result} == 0)); then
  rm ${outputFile};
fi
