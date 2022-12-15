#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:

### Definitions:
tmp=".tmp";
specFile="${tmp}/specFile.txt";
tempFile=${tmp}"/tempFile.txt";
getDescriptions=${tmp}"/getDescriptions.awk";

descriptions="./openapi/descriptions.yaml";
descriptionsNotUsed="./openapi/descriptions-not-used.yaml";
descriptionsMissing="./openapi/descriptions-missing.yaml";

### Source Code:

# Proccess the schemas files to gather all the description's tags:
cat ${specFile} \
  | xargs gawk 'NF > 1 { if ($1 != "description:") { next; } print substr($2, 2, length($2) - 1); }' \
  | sort \
  | uniq \
  > ${tempFile};

# Compare the documented tags with the current tags. And, update the documentation with the diff:
diff ${tempFile} <( cat ${descriptions} | gawk '{ print substr($1, 1, length($1) - 1); }' | sort -u ) \
  | gawk 'NF > 1 { if ($1 == "<") { print $2": Put a description here." } }' \
  >> ${descriptions};

# Multi-purpose outputs:

# >>> Show non used descriptions
diff ${tempFile} <( cat ${descriptions} | gawk '{ print substr($1, 1, length($1) - 1); }' | sort -u ) \
  | gawk 'NF > 1 { if ($1 == ">") { print $2": ---" } }' \
  > ${descriptionsNotUsed} \
  ; rm ${tempFile} ;

# >>> Sort descriptions
cat ${descriptions} \
  | sort \
  | uniq \
  > ${tempFile} \
  ; cat ${tempFile} \
  > ${descriptions} \
  ; rm ${tempFile};

# >>> Show missing descriptions
diff \
  <( grep -e "Put a description here." -e "ENUM" -e "''" ${descriptions} | gawk '{ print $1 }' | sort | uniq ) \
  <( cat ${descriptionsNotUsed} | gawk '{ print $1 }' | sort | uniq) | gawk 'NF == 2 { print $2, "---" }' \
  > ${descriptionsMissing};

# TODO(@danielfcollier): Work on Hidden Properties Reports
#
# >>> Showing files with hidden properties
# hiddenPropsArtifacts=${artifacts}"/hidden-properties";
# mkdir ${hiddenPropsArtifacts} 2> /dev/null;

# echo ; echo "Files with hidden properties:"; echo;
# ls ${hiddenPropsArtifacts} \
#   | gawk -v hiddenDir=${hiddenPropsArtifacts} '
#     {
#       lines = system("lines=$(wc -l "hiddenDir"/"$1" | gawk \x27{print $1}\x27); if (( $lines > 2 )); then echo "hiddenDir"/"$1"; else rm "hiddenDir"/"$1"; fi;" );
#     }'



# Replace the documented descriptions in the generated schema files:
#
# but first... creates an AWK function to get the descriptions:
#
echo "function getDescription(key) {" >> ${getDescriptions};
echo "  switch(key) {" >> ${getDescriptions};
cat ${descriptions} \
  | gawk -i ./src/utils/functions.awk '
      {
        printf("    case \"@%s\":\n", substr($1, 1, length($1) - 1));
        description = "";
        for (i = 2; i <= NF; i++) {
          description = description " " $i;
        }
        printf("      return \"%s\";\n\n", trim(description));
  }' \
  >> ${getDescriptions};
echo "    default:" >> ${getDescriptions};
echo "      return \"Missing description for: \" key;" >> ${getDescriptions};
echo "  }" >> ${getDescriptions};
echo "}" >> ${getDescriptions};
#
# now, put the descriptions in the schema files:
#

echo "Rebuilding schemas with descriptions...";
for file in $(cat ${specFile}); do
    cat ${file} \
      | gawk -i ${getDescriptions} '{
        if ($1 == "description:" && $2) {
          sub($2, getDescription($2), $0);
          print $0;
          } else {
            print $0;
          }
      }' \
      > ${tempFile};
    
    cat ${tempFile} > ${file}
done

# Finish the process:
rm -rf ${tmp} 2> /dev/null;

echo; echo "🌵 Documentation updated!!!"; echo;
