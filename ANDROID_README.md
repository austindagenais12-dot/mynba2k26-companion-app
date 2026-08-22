# Android Version

This folder is configured as the Android-only edition.

## Build an installable APK with EAS

    npm install
    npx eas-cli build --platform android --profile preview

The `preview` profile in `eas.json` requests APK output for direct installation.

## Build with GitHub Actions

The included `Build Android APK` workflow runs on pushes to `main` and can also be started manually from the repository's **Actions** tab. Its downloadable artifact contains `NBA2K26_Career_Companion_v1.2.1.apk`.

## Local Android Studio build

Install Android Studio/SDK first, then:

    npm install
    npx expo prebuild --platform android
    npx expo run:android

There is no VenueLab, PC, or game-memory sync in this edition. Version 1.2 can recognize text from a camera photo or selected console screenshot, but every proposed change must be reviewed and confirmed in-app.

The native OCR dependency does not run in Expo Go. Use an EAS APK or Android development build when testing camera-assisted autofill.

## Apply this update from Termux

Use the copy-paste commands in `TERMUX_UPDATE_V1_2.txt`. They extract the flat update ZIP, copy its contents into the existing GitHub repository root without adding another project folder, install the new native dependencies, verify the launcher artwork, and push the update for a fresh Codemagic Android Release build.

Keep the installed app on the phone until the replacement APK is ready. Android can preserve the local career save when the new APK uses the same package and signing identity.
