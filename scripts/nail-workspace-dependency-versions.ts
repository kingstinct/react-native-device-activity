import { Glob } from "bun";
import fs from "fs";

// Find all package.json files (excluding node_modules)
const packageFilesUnfiltered = new Glob("./**/package.json").scanSync();

const packageFiles = [...packageFilesUnfiltered].filter(
  (filePath) => !filePath.includes("node_modules"),
);

// Create a map of package names to their versions
const packageVersions: Record<string, string> = {};
packageFiles.forEach((filePath) => {
  const pkg = JSON.parse(fs.readFileSync(filePath, "utf8"));
  if (pkg.name && pkg.version) {
    packageVersions[pkg.name] = pkg.version;
  }
});

// Process each package.json
packageFiles.forEach((filePath) => {
  const pkg = JSON.parse(fs.readFileSync(filePath, "utf8"));
  let modified = false;

  // Helper function to process dependencies
  const processDeps = (deps: Record<string, string>) => {
    if (!deps) return deps;
    const newDeps = { ...deps };

    Object.entries(deps).forEach(([name, version]) => {
      if (version.startsWith("workspace:")) {
        const actualVersion =
          version === "workspace:*"
            ? packageVersions[name]
            : version.replace("workspace:", "");

        if (actualVersion) {
          newDeps[name] = actualVersion;
          modified = true;
        }
      }
    });
    return newDeps;
  };

  // Process all dependency types
  pkg.dependencies = processDeps(pkg.dependencies);
  pkg.devDependencies = processDeps(pkg.devDependencies);
  pkg.peerDependencies = processDeps(pkg.peerDependencies);

  // Save if modified
  if (modified) {
    fs.writeFileSync(filePath, `${JSON.stringify(pkg, null, 2)}\n`);
  }
});
