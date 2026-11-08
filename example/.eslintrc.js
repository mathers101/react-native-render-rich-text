module.exports = {
  root: true,
  extends: '@react-native',
  parserOptions: {
    babelOptions: {
      // The editor lints from the repo root. Babel only loads
      // babel.config.js from its project root, so point it here.
      root: __dirname,
    },
  },
};
