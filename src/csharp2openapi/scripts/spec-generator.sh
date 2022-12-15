#!/bin/bash

### .env File:
source ${PWD}/.env;

### Input Variables:
name=$1;
basename=$2;
csharpFile="csharp/$3";

### Definitions:
tmp=".tmp";
specFile="${tmp}/specFile.txt";
showNullables=1; # 1 for true; 0 for false

### Source Code:

echo; echo "Processing... ${csharpFile}";

runAWK="gawk -v showNullables=${showNullables} -i ./src/utils/functions.awk -f ./src/csharp2openapi/utils";
outputBasename="openapi/auto-generated-spec/${name}/$(echo ${csharpFile} | gawk 'BEGIN{ FS="/"; } { split($(NF), word, "\\."); print word[1]; }')";

awkSchema="${runAWK}/schemaBuilder.awk";
eval ${awkSchema} ${csharpFile}" > " "${outputBasename}Schema.yaml" \
  && sed -i "$ d" "${outputBasename}Schema.yaml" \
  && echo "> Built: ./${outputBasename}Schema.yaml" \
  && echo ${outputBasename}"Schema.yaml" \
  >> ${specFile};

awkTemplate="${runAWK}/templateBuilder.awk";
eval ${awkTemplate} ${csharpFile}" > " "${outputBasename}Template.yaml" \
  && sed -i "$ d" "${outputBasename}Template.yaml"\
  && echo "> Built: ./${outputBasename}Template.yaml";

# awkSample="${runAWK}/sample.awk";
# if [[ "${file}" == "Request" ]]; then
#   eval ${awkSample} ${csharpFile}" > " "${outputBasename}Sample.yaml" \
#     && sed -i "$ d" "${outputBasename}Sample.yaml" \
#     && echo "> Built: ./${outputBasename}Sample.yaml";
# fi

# hiddenPropsArtifacts=${artifacts}"/hidden-properties";
# awkHidden=${runAWK}"/getHiddenProps.awk";
# eval ${awkHidden} ${csharpFile}" > " "${outputBasename}Hidden.yaml" \
#   && sed -i "$ d" "${outputBasename}Hidden.yaml" \
#   && echo "> Built: ./${outputBasename}Hidden.yaml" \
#   && cp "${outputBasename}Hidden.yaml" ${hiddenPropsArtifacts};

