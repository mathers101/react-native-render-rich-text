const path = require('path');
const pak = require('../package.json');

// Autolink against the real package root, not the Yarn nohoist symlink under
// example/node_modules. Kotlin incremental compilation on Windows treats that
// symlink as a different source tree, so a one-file edit fails with unresolved
// `internal` symbols (e.g. CodeBackgroundSpan vs InlineBackgroundGeometry).
module.exports = {
  dependencies: {
    [pak.name]: {
      root: path.join(__dirname, '..'),
    },
  },
};
