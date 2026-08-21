# Android Version

This folder is configured as the Android-only edition.

## Build an installable APK with EAS

    npm install
    npx eas-cli build --platform android --profile preview

The `preview` profile in `eas.json` requests APK output for direct installation.

## Local Android Studio build

Install Android Studio/SDK first, then:

    npm install
    npx expo prebuild --platform android
    npx expo run:android

There is no VenueLab or PC sync in this edition. All 2K events are confirmed manually in-app.
