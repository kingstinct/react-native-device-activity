# Example project setup

The example project is linked specifically to simplify development. This means it's not looking exactly like the published package, but for most intents and purposes it should result in the same outcome.
- The config plugin has a `copyToTargetFolder` option that is set to false. This is to prevent the target folder from being copied to the example project and potentially overwriting the original files.
- The swift files in the targets folder are linked to the root project instead of duplicated. If adding new swift files, try to link them instead of duplicating to keep things clean.
- The entitlements and info.plist files however duplicated - to not mess with the example project/signing etc.
- There is a Shared.swift file that can be accessed by all targets. This is linked to each target in the example project, but in the published package it's copied and duplicated to each target. I prefer this to making more changes in @bacons/xcode package which only supports swift files on the root level of each target directory.
