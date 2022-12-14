#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
descriptions=$(ls ${OPENAPI}/descriptions*)

### Source Code:

# Generate a .csv file with descriptions
cat ${descriptions} \
  | gawk '
    BEGIN {
      FS = ": ";
    }
    {
      description = "";
      for (i=2; i <=NF; i++) {
        description = description $i;
      }
      print $1"@"description
    }' \
  > ${ASSETS}"/descriptions.csv";

# Generate a .csv file to fill missing descriptions
cat ${descriptionsMissing} \
  | gawk 'BEGIN { FS = ": " } { print $1,"," }' \
  > ${ASSETS}"/descriptions-missing.csv";

