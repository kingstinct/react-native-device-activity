[![Test Status](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml/badge.svg)](https://github.com/Kingstinct/react-native-device-activity/actions/workflows/test.yml)
[![Latest version on NPM](https://img.shields.io/npm/v/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Downloads on NPM](https://img.shields.io/npm/dt/react-native-device-activity)](https://www.npmjs.com/package/react-native-device-activity)
[![Discord](https://dcbadge.vercel.app/api/server/5wQGsRfS?style=flat)](https://discord.gg/5wQGsRfS)

# react-native-device-activity

Provides access to Apples DeviceActivity API. It does require a Custom Dev Client to work with Expo.

# API documentation

- [Documentation for the main branch](https://github.com/expo/expo/blob/main/docs/pages/versions/unversioned/sdk/react-native-device-activity.md)
- [Documentation for the latest stable release](https://docs.expo.dev/versions/latest/sdk/react-native-device-activity/)

# Installation in managed Expo projects

For [managed](https://docs.expo.dev/archive/managed-vs-bare/) Expo projects, please follow the installation instructions in the [API documentation for the latest stable release](#api-documentation). If you follow the link and there is no documentation available then this library is not yet usable within managed projects &mdash; it is likely to be included in an upcoming Expo SDK release.

The package requires native code, which includes a custom app target. Currently it requires targeting iOS 15 or higher, so populate app.json/app.config.json as follows:
```
"plugins": [
    [
      "expo-build-properties",
      {
        "ios": {
          "deploymentTarget": "15.0"
        },
      },
    ],
    [
      "../app.plugin.js",
      {
        "appleTeamId": "34SE8X7Q58"
      },
    ]
  ],
  ```

# Installation in bare React Native projects

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

### Add the package to your npm dependencies

```
npm install react-native-device-activity
```

### Configure for iOS

Run `npx pod-install` after installing the npm package.



# Contributing

Contributions are very welcome! Please refer to guidelines described in the [contributing guide]( https://github.com/expo/expo#contributing).
