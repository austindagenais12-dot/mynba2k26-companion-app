# Android Version

This folder is configured as the Android-only edition.

## Build an installable APK with EAS

    npm install
    npx eas-cli build --platform android --profile preview

The `preview` profile in `eas.json` requests APK output for direct installation.

## Build with GitHub Actions

The included `Build Android APK` workflow runs on pushes to `main` and can also be started manually from the repository's **Actions** tab. Its downloadable artifact contains `NBA2K26_Career_Companion_v1.3.0.apk`.

## Local Android Studio build

Install Android Studio/SDK first, then:

    npm install
    npx expo prebuild --platform android
    npx expo run:android

There is no console-account or game-memory sync in this edition. Version 1.3 can recognize text from camera photos or selected console screenshots, including multi-image draft classes and schedules, but every proposed change must be reviewed and confirmed in-app. Its MyNBA historical-season tracker also applies period-correct teams and major league rules from 1983–84 through 2025–26.

The native OCR dependency does not run in Expo Go. Use an EAS APK or Android development build when testing camera-assisted autofill.

## Apply this update from Termux

Use the copy-paste commands in `TERMUX_UPDATE_V1_3.txt` to pull and verify the update directly from GitHub, or install the finished APK from the phone's Downloads folder.

Keep the installed app on the phone until the replacement APK is ready. Android can preserve the local career save when the new APK uses the same package and signing identity.
