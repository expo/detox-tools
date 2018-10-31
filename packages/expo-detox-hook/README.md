# What is this
The `expo-detox-hook` is an iOS framework that you install via npm, and it gets put in your Library directory. This package exists because we need to call into the test runtime and add some extra changes in order to get Detox and Expo platforms to play well with each other. 

# Installation
You can install the framework by declaring `expo-detox-hook` in your `package.json` and running `npm install`, which should install the framework to your Library directory.

# Usage
Download `expo-detox-cli` and when you run `expotox`, it should let the test harness know about the `expo-detox-hook` frameworks.