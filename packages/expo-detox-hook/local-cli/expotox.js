#!/usr/bin/env node
const program = require('commander');

program
  .arguments('<process>')
  .command('clean-framework-cache', `Delete all compiled framework binaries from ~/Library/ExpoDetoxHook, they will be rebuilt on 'npm install' or when running 'expo-build-framework-cache'`)
  .command('build-framework-cache', `Build ExpoDetoxHook.framework to ~/Library/ExpoDetoxHook. The framework cache is specific for each combination of Xcode and ExpoDetoxHook versions`)
  .parse(process.argv);
