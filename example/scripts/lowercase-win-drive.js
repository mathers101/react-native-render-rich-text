const Module = require('module');

// Metro indexes files from path.resolve (lowercase drive letter on this
// machine) but require.resolve keeps the uppercase drive letter of whichever
// path first loaded a package. Hash lookups then miss. Normalize before Metro
// captures those paths, and pass the same hook to worker processes.
const hook = __filename.replace(/\\/g, '/');
const currentOptions = process.env.NODE_OPTIONS || '';
if (!currentOptions.includes(hook)) {
  process.env.NODE_OPTIONS = [currentOptions, `--require ${hook}`]
    .filter(Boolean)
    .join(' ');
}

const resolveFilename = Module._resolveFilename;
Module._resolveFilename = function (request, parent, isMain, options) {
  const resolved = resolveFilename.call(this, request, parent, isMain, options);
  if (typeof resolved === 'string' && /^[A-Z]:[\\/]/.test(resolved)) {
    return resolved[0].toLowerCase() + resolved.slice(1);
  }
  return resolved;
};
