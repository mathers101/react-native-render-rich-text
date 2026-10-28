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
    // example/package.json depends on this unscoped name via link:.., and Yarn
    // nohoist keeps that symlink beside the real package. Autolinking both
    // adds the same native library twice and CMake rejects the shared build dir.
    'react-native-render-rich-text': {
      platforms: {
        android: null,
        ios: null,
      },
    },
  },
};
