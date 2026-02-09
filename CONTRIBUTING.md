# Repository development setup

## Example app config (env-driven)

The example app uses `apps/example/app.config.ts` so local developer values do not need to be committed.

Create local env values from the template:

```bash
cp apps/example/.env.example apps/example/.env
```

Supported variables:

- `RNDA_APPLE_TEAM_ID`
- `RNDA_APP_GROUP`
- `RNDA_IOS_BUNDLE_ID`
- `RNDA_ANDROID_PACKAGE`

If these variables are missing, `app.config.ts` falls back to stable defaults for this repository.

## Example app follows CNG

The example app no longer tracks `apps/example/ios` and `apps/example/android`.

Regenerate native folders when needed:

```bash
cd apps/example
bun run prebuild
# or
bun run ios
bun run android
```

## Swift test ownership

Swift test sources are package-owned and live in:

- `packages/react-native-device-activity/ios/Tests`

The iOS test runner lives in:

- `packages/react-native-device-activity/ios/TestHarness`

## Plugin testing

In addition to app/prebuild validation, config plugin regression tests are defined under:

- `packages/react-native-device-activity/plugin/__tests__`

Run them with:

```bash
cd packages/react-native-device-activity
bun run test:plugin
```
