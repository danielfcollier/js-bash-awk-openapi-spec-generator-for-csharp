# Generate an OpenAPI Schema based CSharp types and code notations.
#
# code notation in the .cs file:
#   /// description: Put a description here.
#   /// tag: example
#   /// value: 1
#
# Refer to README.md for more details.
#
# p.s.: value fields must comply with the .yaml notation and it should be an one-liner

BEGIN {
  # Definitions
  TRUE = 1;
  FALSE = 0;
  ERROR_CODE = 1;

  # Constants (.cs file)
  MEMBER_POSITION = 1;
  TYPE_POSITION = 2;
  DATA_POSITION = 3;
  EQUAL_SIGN_POSITION = 8;
  MINIMUM_ROW_LENGTH = 3;

  # Variables
  classCounter = 0;
  propertyCounter = 0;
  docsLastRow = 0;
  descriptionContent = "";
  flagContent = "";
  valueContent = "";
  isSearchClass = FALSE;
  depth = "" ? 0 : depth;

  # Custom variables
  isArrayChild = "" ? FALSE : isArrayChild;

  # Start .yaml file
  if (depth == "") {
    print "summary: Example Template";
    print "value:";
  }
}

NF >= MINIMUM_ROW_LENGTH {
  # Clear spacing and split row
  row = trim($0);

  # Determine row characteristics
  isComment = trim($1) == "//";
  if (isComment) {
    next;
  }

  isDocs = trim($1) == "///";
  if (isDocs) {
    switch($2) {
      case "description:":
        descriptionContent = "";
        for (k = DATA_POSITION; k <= NF; k++) {
          descriptionContent = sprintf("%s %s", descriptionContent, $k);
        }
        descriptionContent = trim(descriptionContent);
        break;

      case "flag:":
        flagContent = $3;
        break;

      case "value:":
        valueContent = "";
        for (k = DATA_POSITION; k <= NF; k++) {
          valueContent = sprintf("%s %s", valueContent, $k);
        }
        valueContent = trim(valueContent);
        break;

      default:
        print "### ERROR in Docs";
    }
    docsLastRow = NR;
    next;
  }

  # Docs must be applied to the next property
  if (NR > (docsLastRow + 1)) {
    descriptionContent = "";
    flagContent = "";
    valueContent = "";
  }

  # Gather csharp data
  csharpMember = trim($(MEMBER_POSITION));
  csharpType = $(TYPE_POSITION);
  isDictionary = match(csharpType, /Dictionary.?/) ? 1 : 0;
  dataShift = isDictionary ? 1 : 0;

  csharpType = $(TYPE_POSITION + 2*dataShift);
  csharpData = $(DATA_POSITION + 1*dataShift);

  # Flow control
  if (csharpType == "class") {
    classCounter++;
    isSearchClass = csharpData == searchTerm;
  }

  isMainClass = (classCounter == 1) && (searchTerm == "") && (depth == 0);
  mapClassProperties = isMainClass || isSearchClass;

  if (!mapClassProperties) {
    next;
  }

  # Accept only public properties
  isPublicProperty = csharpMember == "public";

  # Jump hidden properties
  isHiddenProperty = flagContent == "hide" || flagContent == "empty";

  # Map .cs data to OpenAPI .yaml
  hasJumpedClassDefinition = propertyCounter > 0;

 if (isPublicProperty && !isHiddenProperty && hasJumpedClassDefinition) {

    # map type and formats
    specification = getOpenAPISpec(csharpType);
    split(specification, props, "&");
    openAPItype = props[1];
    openAPIformat = props[2];

    # .yaml Metadata
    isTypeRecursivable = openAPItype == "object" || openAPItype == "array";
    isNullable = match(csharpType, /\?$/) > 0;
    hasFormat = length(openAPIformat) > 0;
    hasDefaultValue = $(EQUAL_SIGN_POSITION) == "=";
    isRequired = !isNullable && !hasDefaultValue;
    defaultValue = $(EQUAL_SIGN_POSITION + 1);

    # .cs FLAGS
    hasDescription = descriptionContent != "";
    hasDateFlag = flagContent == "date";
    hasEnumFlag = flagContent == "enum";
    hasExampleFlag = flagContent == "example";
    hasNullFlag = flagContent == "null";

    if (hasDateFlag) { openAPIformat = "date"; }
    if (hasEnumFlag) { split(valueContent, enumValues, "_"); }

    if (flagContent == "binary" \
      || flagContent == "email" \
      || flagContent == "hostname" \
      || flagContent == "password" \
      || flagContent == "uri" \
      || flagContent == "uuid" \
      ) {
      openAPIformat = flagContent;
    }

    ###########################################################################
    # Custom function
    ###########################################################################

    # Pretty print
    propertyMargin = marginDepth("  ", depth);

    if (isTypeRecursivable) {
      printf("%s%s:\n", propertyMargin, getCamelCase(csharpData));
    } else {
      template = openAPIformat ? openAPIformat : openAPItype;
      if (propertyCounter == 1 && isArrayChild) {
        printf("%s: %s\n", getCamelCase(csharpData), template);
        isArrayChild = FALSE;
      } else {
        printf("%s%s: %s\n", propertyMargin, getCamelCase(csharpData), template);
      }
    }

    # Access properties from objects and arrays recursively
    isNotMainClass = classCounter >= 1;
    if (isTypeRecursivable && isNotMainClass) {

      if (isNullable) {
        questionMarkRemoved = substr(csharpType, 1, length(csharpType) - 1);
        csharpType = questionMarkRemoved;
      }

      if (openAPItype == "object") {
        rDepth = depth + 1;
        isArrayChild = FALSE;
      }

      if (openAPItype == "array") {
        arrayMargin = marginDepth("    ", depth);
        printf("%s- ", arrayMargin);

        matchStart = match(csharpType, /</);
        matchEnd = match(csharpType, />/);
        listType = substr(csharpType, matchStart + 1, matchEnd - matchStart - 1);
        csharpType = listType;
        rDepth = depth + 2;
        isArrayChild = TRUE;

        if (isPrimitive(csharpType)) {
          if (csharpType == "string") {
            isTypeRecursivable = FALSE;
            print "string";
          }

          csharpType = csharpData;
        }
      }

      if (isTypeRecursivable) {
        command = "gawk -v showNullables=\"" showNullables "\" -v searchTerm=\"" csharpType "\" \
          -v depth=\""rDepth"\" -v isArrayChild=\""isArrayChild"\" -i ./src/utils/functions.awk \
          -f ./src/csharp2openapi/utils/templateBuilder.awk " FILENAME;

        system(command);
      }
    }

    ###########################################################################
    # End of Custom Function
    ###########################################################################

    # Space between properties
    if (depth == 0) { printf("\n"); }
  }

  # Docs must be applied to the next property
  if (NR == (docsLastRow + 1)) {
    descriptionContent = "";
    flagContent = "";
    valueContent = "";
  }

  ## Flow control
  if (!isHiddenProperty) {
    propertyCounter++;
  }
}

END {
  if (propertyCounter == 0) {
    BLANK_LINE = sprintf("%s#", propertyMargin);

    printf("\n");
    printf("%s#############################################\n", propertyMargin);
    printf("%s################## ERROR ####################\n", propertyMargin);
    printf("%s#############################################\n", propertyMargin);
    print BLANK_LINE;
    printf("%s# Missing object properties!!!\n", propertyMargin);
    print BLANK_LINE;
    printf("%s# Property:\n", propertyMargin);
    printf("%s#   %s\n", propertyMargin, searchTerm);
    print BLANK_LINE;
    printf("%s# Hint: include as a comment in the file.\n", propertyMargin);
    print BLANK_LINE;
    printf("%s# File:\n", propertyMargin);
    printf("%s#   %s\n", propertyMargin, FILENAME);
    print BLANK_LINE;
    printf("%s#############################################\n", propertyMargin);

    exit ERROR_CODE;
  }
}
