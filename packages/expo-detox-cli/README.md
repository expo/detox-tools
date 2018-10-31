# What is this
The `expo-detox-cli` is a wrapper around the (detox-cli)[https://github.com/wix/Detox/blob/master/docs/Introduction.GettingStarted.md#4-install-detox-command-line-tools-detox-cli]. It does the same thing as the detox-cli, except it adds an extra environment variable when you run your tests on OSx, to let the testing harness know where the extra dynamic libraries from (expo-cli-hook)[https://github.com/expo/detox-tools/tree/master/packages/expo-detox-hook] are.

# Installation
You can install the cli by running `npm install -g expo-detox-cli`.

# Usage
You would use this cli the same way you would the `detox-cli`, except instead of running the `detox` binary, you run `expotox`.

For example. you would run `expotox test` instead of the usual `detox test`.