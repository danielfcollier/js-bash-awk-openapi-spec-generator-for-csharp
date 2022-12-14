const path = require("path");

const apisConfig = require("../openapi/config.json");
const commandHandler = require("./handlers/commandHandler");
const specHandler = require("./handlers/specHandler");

const options = {
  specGenerator: path.join("csharp2openapi", "scripts", "spec-generator.sh"),
  specParser: path.join("csharp2openapi", "scripts", "spec-parser.sh"),
  bundle: path.join("csharp2openapi", "scripts", "bundle.sh"),
  csharp: path.join("cspell", "csharp.sh"),
  // descriptions: path.join("cspell", "csharp.sh"),
  spell: path.join("cspell", "api.sh"),
  lint: path.join("csharp2openapi", "scripts", "lint.sh"),
  postman: path.join("csharp2openapi", "scripts", "postman.sh"),
};

function main() {
  const args = process.argv;
  const argument = args[2];
  const option = (argument) => {
    return options[argument] || "invalid";
  };
  const script = option(argument);

  if (script === "invalid") {
    console.log(`Invalid option: ${argument}`);
    console.log("Choose one valid option:");
    Object.keys(options).forEach((opt) => console.log(`- ${opt}`));
    console.log("\nUsage: make script option=<option>");
    return;
  }

  const cwd = process.cwd();
  const projectFolder = __dirname.replace(cwd, "./");
  const command = `bash ${path.join(projectFolder, script)}`;

  if (/^spec/.test(argument)) {
    specHandler(argument, command);
  } else {
    apisConfig.forEach((api) => {
      const { basename } = api;
      const execution = `${command} ${basename}`;
      commandHandler(execution);
    });
  }
}

main();
