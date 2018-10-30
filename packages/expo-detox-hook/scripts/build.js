const childProcess = require('child_process');
const fs = require('fs-extra');

// Just make the usage a little prettier
function sh(cmdline, opts) {
	const args = cmdline.split(' ');
	const cmd = args.shift();
	return childProcess.execFileSync(cmd, args, opts);
  }

if (process.platform === 'darwin') {
  console.log("\nPackaging ExpoDetoxHook iOS sources");

  fs.removeSync('ExpoDetoxHook-ios-src.tbz');

  sh("tar --exclude-from=.tbzignore -cjf ../ExpoDetoxHook-ios-src.tbz .", { cwd: "ios" });
}
