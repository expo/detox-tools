#!/usr/bin/env node
const cp = require('child_process');
const path = require('path');

const result = cp.spawnSync(
    path.join(process.cwd(), 'node_modules/.bin/expotox'),
    process.argv.slice(2),
    { stdio: 'inherit' });
    process.exit(result.status);
}