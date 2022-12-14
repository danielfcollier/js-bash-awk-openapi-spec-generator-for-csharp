const { exec } = require("child_process");

function commandHandler(command, showLog = true) {
  exec(`${command}`, (error, stdout, stderr) => {
    if (showLog) {
      if (error) {
        console.log(`error: ${error.message}`);
        return;
      }
      if (stderr) {
        console.log(`stderr: ${stderr}`);
        return;
      }
      console.log(`${stdout}`);
    }
  });
}

module.exports = commandHandler;
