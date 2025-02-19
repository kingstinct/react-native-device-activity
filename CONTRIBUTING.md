# Example project setup

The example project is linked specifically to simplify development. This means it's not looking exactly like the published package, but for most intents and purposes it should result in the same outcome.

- The config plugin has a `copyToTargetFolder` option that is set to false. This is to prevent the target folder from being copied to the example project and potentially overwriting the original files.
- The swift files in the targets folder are linked to the root project instead of duplicated. If adding new swift files, try to link them instead of duplicating to keep things clean.
- The entitlements and info.plist files however duplicated - to not mess with the example project/signing etc.
- There is a Shared.swift file that can be accessed by all targets. This is linked to each target in the example project, but in the published package it's copied and duplicated to each target. I prefer this to making more changes in @bacons/xcode package which only supports swift files on the root level of each target directory.
- In addition the example project contains an XCode test target as well as SwiftLint.

## Prebuild

To try out prebuild functionality (i.e. the config plugin) run `bun run prebuild` in the example project (it uses the `INTERNALLY_TEST_EXAMPLE_PROJECT` and `COPY_TO_TARGET_FOLDER` env variables to behave like a published package). This should be used to verify changes are expected, but the result should not in it's full state be commited to the example project, since it will break the DX of the example project as explained above.
