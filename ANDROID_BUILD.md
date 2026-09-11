# Android build notes

This project is an offline Expo wrapper around `starfall-shattered-fates.html`. The game itself runs locally inside the app, so the campaign, relationships, world state, and saves do not require an account or internet connection after installation.

## Codemagic APK build

The repository root contains `codemagic.yaml`, configured to install dependencies, resolve the Expo-compatible WebView package, generate the Android project, and build a release APK. In Codemagic, select the `star-wars-shattered-fates` branch and start the `android-apk` workflow. The finished APK appears under Artifacts.

## GitHub Actions fallback

The repository also contains `.github/workflows/starfall-android.yml`. Run it from the Actions tab with **Run workflow**. It uploads the release APK as a downloadable workflow artifact.

## EAS cloud APK build

From this project folder:

```bash
npm install
npx expo install react-native-webview
npx eas-cli login
npx eas-cli build --platform android --profile preview
```

The `preview` profile is configured to produce a directly installable `.apk`. EAS will display the build page and download link when the build finishes.

## Local Android build

If Android Studio and the Android SDK are installed:

```bash
npx expo prebuild --platform android
npx expo run:android
```

## Termux route

On a Samsung phone, install Node.js and Git in Termux, clone or copy this folder, then trigger Codemagic/GitHub Actions from the browser. The phone only needs to download and install the completed APK; the build runs remotely.
