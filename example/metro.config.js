const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');
const { mergeConfig } = require('@react-native/metro-config');

function lowercaseDrive(absolutePath) {
  return absolutePath.replace(/^[A-Z]:/, drive => drive.toLowerCase());
}

const projectRoot = lowercaseDrive(__dirname);
const workspaceRoot = lowercaseDrive(path.resolve(projectRoot, '..'));
const libraryEntry = path.join(workspaceRoot, 'src', 'index.tsx');

const config = {
  projectRoot,
  watchFolders: [workspaceRoot],
  resolver: {
    nodeModulesPaths: [
      path.resolve(projectRoot, 'node_modules'),
      path.resolve(workspaceRoot, 'node_modules'),
    ],
    // Yarn links this package with an absolute symlink. Metro mishandles that
    // on Windows, so resolve the example import to the workspace entry.
    resolveRequest: (context, moduleName, platform) => {
      if (moduleName === 'react-native-render-rich-text') {
        return {
          type: 'sourceFile',
          filePath: libraryEntry,
        };
      }
      // Library source lives above the example app, so a normal lookup finds
      // the workspace copy of React. Pin React to the app's copy.
      if (
        moduleName === 'react' ||
        moduleName.startsWith('react/') ||
        moduleName === 'react-native' ||
        moduleName.startsWith('react-native/')
      ) {
        return context.resolveRequest(
          {
            ...context,
            originModulePath: path.join(projectRoot, 'index.js'),
          },
          moduleName,
          platform,
        );
      }
      return context.resolveRequest(context, moduleName, platform);
    },
  },
};

module.exports = mergeConfig(getDefaultConfig(projectRoot), config);
