#!/usr/bin/env node
const cp = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const OSX_APP_PATH = path.join(os.homedir(), 'Library');
const OSX_LIBRARY_ROOT_PATH = path.join(OSX_APP_PATH, 'ExpoDetoxHook');

const detoxAppPath = path.join(process.cwd(), 'node_modules/detox');
const detoxPackageJsonPath = path.join(detoxAppPath, 'package.json');

const expoDetoxHookAppPath = path.join(process.cwd(), 'node_modules/expo-detox-hook');
const expoDetoxHookPackageJsonPath = path.join(expoDetoxHookAppPath, 'package.json');

function getFrameworkPath() {
    const version = require(expoDetoxHookPackageJsonPath).version;
    let sha1 = cp.execSync(`(echo "${version}" && xcodebuild -version) | shasum | awk '{print $1}'`).toString().trim();
    return `${OSX_LIBRARY_ROOT_PATH}/ios/${sha1}/ExpoDetoxHook.framework/ExpoDetoxHook`;
}

if (!fs.existsSync(detoxPackageJsonPath)) {
    console.log("detox is not installed in this directory");
    process.exit(1);
}

// { shell: true } option seems to break quoting on windows? Otherwise this would be much simpler.
if (process.platform === 'win32') {
    const result = cp.spawnSync(
    'cmd',
    ['/c', path.join(process.cwd(), 'node_modules/.bin/detox.cmd')].concat(process.argv.slice(2)),
    { stdio: 'inherit' });
    process.exit(result.status);
} else {
    if (!fs.existsSync(expoDetoxHookPackageJsonPath)) {
        console.log("expo-detox-hook is not installed in this directory. You should declare it in package.json and run `npm install`");
        process.exit(1);
    }

    // Route to `expo-detox-hook` cli if command begins with `expo-`
    const command = process.argv.slice(2)[0];
    if (command && command.startsWith('expo-')){
        const result = cp.spawnSync(
        path.join(process.cwd(), 'node_modules/.bin/expotox'),
        process.argv.slice(2),
        { stdio: 'inherit' });
        process.exit(result.status);
    }

    const expoDetoxHookFrameworkPath = getFrameworkPath();
    if (!fs.existsSync(expoDetoxHookFrameworkPath)){
        console.log("expo-detox-hook is not installed in your osx Library. Run `expotox expo-clean-framework-cache && expotox expo-build-framework-cache` to fix this.");
        process.exit(1);
    }
    const result = cp.spawnSync(
    path.join(process.cwd(), 'node_modules/.bin/detox'),
    process.argv.slice(2),
    { stdio: 'inherit',
        env: { 
            ...process.env, SIMCTL_CHILD_DYLD_INSERT_LIBRARIES: expoDetoxHookFrameworkPath
        },
    });
    process.exit(result.status);
}