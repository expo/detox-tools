#!/usr/bin/env node

const cp = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const OSX_APP_PATH = path.join(os.homedir(), 'Library');
const OSX_LIBRARY_ROOT_PATH = path.join(OSX_APP_PATH, 'ExpoDetoxHook');

function getVersion() {
    return require(path.join(__dirname, 'package.json')).version;
  }

function getFrameworkPath() {
    const version = getVersion();
    let sha1 = cp.execSync(`(echo "${version}" && xcodebuild -version) | shasum | awk '{print $1}'`).toString().trim();
    return `${OSX_LIBRARY_ROOT_PATH}/ios/${sha1}/ExpoDetoxHook.framework/ExpoDetoxHook`;
}

const detoxAppPath = path.join(process.cwd(), 'node_modules/detox');
const detoxPackageJsonPath = path.join(detoxAppPath, 'package.json');

if (fs.existsSync(detoxPackageJsonPath)) {
    // { shell: true } option seems to break quoting on windows? Otherwise this would be much simpler.
    if (process.platform === 'win32') {
        const result = cp.spawnSync(
        'cmd',
        ['/c', path.join(process.cwd(), 'node_modules/.bin/detox.cmd')].concat(process.argv.slice(2)),
        { stdio: 'inherit' });
        process.exit(result.status);
    } else {
        const expoDetoxHookFrameworkPath = getFrameworkPath();
        if (!fs.existsSync(expoDetoxHookFrameworkPath)){
            console.log("expo-detox-hook is not installed in your osx Library. See <TODO:(quin) readme> for more info.");
            process.exit(1);
        }
        const result = cp.spawnSync(
        path.join(process.cwd(), 'node_modules/.bin/detox'),
        process.argv.slice(2),
        { stdio: 'inherit',
          env: {SIMCTL_CHILD_DYLD_INSERT_LIBRARIES: expoDetoxHookFrameworkPath},
        });
        process.exit(result.status);
    }
} else {
    console.log("detox is not installed in this directory");
    process.exit(1);
}