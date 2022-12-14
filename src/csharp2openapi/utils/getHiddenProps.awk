# Generate an OpenAPI Example with all types and formats.
#
# auxiliary tags for code notation in the .cs file:
#   /// tag: null | date
#
# Refer to README.md for more details.

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
  hasHiddenParent = FALSE;
  depth = "" ? 0 : depth;
  hideCounter = 0;

  # Start .yaml file
  if (depth == "") {
    print "type: object";
    print "properties:";
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

  # Gather CSharp data
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

  # Map .cs data to OpenAPI .yaml
  hasJumpedClassDefinition = propertyCounter > 0;

  if (isPublicProperty && hasJumpedClassDefinition) {

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
    # TODO(danielfcollier@gmail.com): missing object level required tag.
    isRequired = !isNullable && !hasDefaultValue && FALSE;
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

    # Jump hidden properties
    isToShow = (searchTerm == "" && isTypeRecursivable) || flagContent == "hide";

    if (isToShow) {
      # Pretty print
      propertyMargin = marginDepth("  ", depth);
      attributesMargin = marginDepth("    ", depth);
      enumMargin = marginDepth("      ", depth);

      printf("%s%s:\n", propertyMargin, getCamelCase(csharpData));
      printf("%stype: %s\n", attributesMargin, openAPItype);

      if (flagContent == "empty") {
        isTypeRecursivable = FALSE;
        propertyCounter = 1;
        printf("%sadditionalProperties: false\n", attributesMargin);
      }

      # if (hasDescription) {
      #   printf("%sdescription: %s\n", attributesMargin, descriptionContent);
      # }

      # if (hasFormat) {
      #   printf("%sformat: %s\n", attributesMargin, openAPIformat);
      # }

      if (isRequired) {
        printf("%srequired: true\n", attributesMargin);
      }

      # if (isNullable && showNullables) {
      #   printf("%snullable: true\n", attributesMargin);
      # }

      if (hasEnumFlag) {
        printf("%senum:\n", attributesMargin);
        for (i = 1; i <= length(enumValues); i++) {
          # TODO(danielfcollier@gmail.com): better handling of enum types (strings vs int for numbers).
          printValue = "\""enumValues[i]"\"";
          printf("%s- %s\n", enumMargin, printValue);
        }
      }

      # Access properties from objects and arrays recursively
      isNotMainClass = classCounter >= 1;
      if (isTypeRecursivable && isNotMainClass) {
        print hideCounter;

        # hasHiddenParent = TRUE;

        if (isNullable) {
          questionMarkRemoved = substr(csharpType, 1, length(csharpType) - 1);
          csharpType = questionMarkRemoved;
        }

        if (openAPItype == "object") {
          printf("%sproperties:\n", attributesMargin);
          rDepth = depth + 2;
        }

        if (openAPItype == "array") {
          printf("%sitems:\n", attributesMargin);
          printf("%s  type: object\n", attributesMargin);
          printf("%s  properties:\n", attributesMargin);

          matchStart = match(csharpType, /</);
          matchEnd = match(csharpType, />/);
          listType = substr(csharpType, matchStart + 1, matchEnd - matchStart - 1);
          csharpType = listType;
          rDepth = depth + 3;

          if (isPrimitive(csharpType)) {
            csharpType = csharpData;
          }
        }

        command = "gawk -v showNullables=\""showNullables"\" -v searchTerm=\""csharpType"\" \
          -v depth=\""rDepth"\" -v hasHiddenParent=\""hasHiddenParent"\" \
          -i ./src/utils/functions.awk -f ./src/csharp2openapi/utils/getHiddenProps.awk " FILENAME;

        system(command);

        # hasHiddenParent = FALSE;
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
