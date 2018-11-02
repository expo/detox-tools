#!/usr/bin/env node

const program = require('commander');

// `expo-detox-cli` will only route here on certain commands. The usual route is to invoke the `detox` local-cli.
program
  .arguments('<process>')
  .command('expo-clean-framework-cache', `Delete all compiled framework binaries from ~/Library/ExpoDetoxHook, they will be rebuilt on 'npm install' or when running 'expo-build-framework-cache'`)
  .command('expo-build-framework-cache', `Build ExpoDetoxHook.framework to ~/Library/ExpoDetoxHook. The framework cache is specific for each combination of Xcode and ExpoDetoxHook versions`)
  .parse(process.argv);
