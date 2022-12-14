const apisConfig = require("../../openapi/config.json");
const commandHandler = require("./commandHandler");

function specHandler(argument, baseCommand) {
  const initializer = () => {
    commandHandler("rm -rf openapi/auto-generated-spec 2> /dev/null", false);
    commandHandler("echo '🌵 Running Docs Builder:'");
    commandHandler("mkdir .tmp && touch .tmp/specFile.txt && touch .tmp/tempFile.txt", false);
    commandHandler("mkdir -p openapi/auto-generated-spec", false);
  };

  const generator = () => {
    apisConfig.forEach((api) => {
      const { name, basename, endpoints } = api;
      commandHandler(`mkdir -p openapi/auto-generated-spec/${name}`, false);

      endpoints.forEach((endpoint) => {
        const { source } = endpoint;
        Object.values(source).forEach((codeFile) => {
          const command = `${baseCommand} ${name} ${basename} ${codeFile}`;
          commandHandler(command, false);
        });
      });
    });
  };

  const parser = () => {
    commandHandler(baseCommand);
  };

  if (argument === "specGenerator") {
    initializer();
    generator();
  }

  if (argument === "specParser") {
    parser();
  }
}

module.exports = specHandler;
