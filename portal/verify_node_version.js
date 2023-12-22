// a script to check that our project’s node version is at-least 14.19.3
const semver = require("semver");
const { engines } = require("./package");
const version = engines.node;
if (!semver.satisfies(process.version, version)) {
  throw new Error(
    `The current node version${process.version} does not satisfy the required version ${version} .`
  );
}
