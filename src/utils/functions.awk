function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s; }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s; }
function trim(s) { return rtrim(ltrim(s)); }

function getCamelCase(property) {
  firstLetter = tolower(substr(property, 1, 1));
  stringBody = substr(property, 2, length(property));
  camelCase = firstLetter stringBody;

  return camelCase;
}

function marginDepth(space, depth) {
  margin = space;
  for (i = 1; i <= depth; i++) {
    margin = margin "  ";
  }

  return margin;
}

function removeColon(word) {
  if (match(word, /;$/)) {
    return substr(word, 1, length(word) - 1);
  }

  return word;
}

function formatValueYAML(value) {
  # remove semicolon
  trimmedValue = trim(value);
  formattedValue = substr(trimmedValue, 1, length(trimmedValue) - 1);

  hasQuotes = substr(formattedValue, 1, 1) == "\"";
  hasHash = substr(formattedValue, 2, 1) == "#";

  # remove quotes
  if (hasQuotes && !hasHash) {
    formattedValue = substr(formattedValue, 2, length(formattedValue) - 2);
  }

  return formattedValue;
}

function getOpenAPISpec(csharpType) {
  oFormat = "";

  switch(csharpType) {
    case /^bool.?/:
      oType = "boolean";
      break;

    case /^DateTime.?/:
      oType = "string";
      oFormat = "date-time";
      break;

    case /^string.?/:
      oType = "string";
      break;

    case /^char.?/:
      oType = "string";
      oFormat = "char";
      break;

    case /^short.?/:
    case /^ushort.?/:
      oType = "integer";
      oFormat = "int16";
      break;

    case /^int.?/:
    case /^uint.?/:
      oType = "integer";
      oFormat = "int32";
      break;

    case /^long.?/:
    case /^ulong.?/:
      oType = "integer";
      oFormat = "int64";
      break;

    case /^float.?/:
      oType = "number";
      oFormat = "float";
      break;

    case /^decimal.?/:
    case /^double.?/:
      oType = "number";
      oFormat = "double";
      break;

    case /^List.?/:
      oType = "array";
      break;

    case /^byte.?/:
    case /^sbyte.?/:
      oType = "string";
      oFormat = "byte";
      break;

    case /^object.?/:
    default:
      oType = "object";
  }

  result = oType "&" oFormat;

  return result;
}

function isPrimitive(testType) {
  switch(testType) {
    case /^bool.?/:
    case /^DateTime.?/:
    case /^string.?/:
    case /^char.?/:
    case /^short.?/:
    case /^ushort.?/:
    case /^int.?/:
    case /^uint.?/:
    case /^long.?/:
    case /^ulong.?/:
    case /^float.?/:
    case /^decimal.?/:
    case /^double.?/:
    case /^byte.?/:
    case /^sbyte.?/:
      return 1; # TRUE
  }

  return 0; # FALSE
}
