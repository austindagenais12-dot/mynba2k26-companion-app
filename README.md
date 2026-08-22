# NBA 2K26 Career Companion Mobile — Version 1.2.1

A standalone mobile career-RPG companion for NBA 2K26 MyNBA Player Lock. This edition deliberately does **not** connect to VenueLab, NBA 2K26 memory, or your PC. You can enter facts manually or approve fields recognized from photos/screenshots of your console; the app generates the immersive career world around them.

## Included in V1

- Touch-first Home / Career / Play / Social / More interface
- Persistent offline local save using Expo SQLite key-value storage
- Shared save format between Android and iOS
- Randomized prospect creation
- Compressed High School / NCAA / JUCO / OTE / NBL / European pathways
- NBA Draft handoff: NBA 2K26 MyNBA determines your actual draft team and pick
- Camera/screenshot-assisted game logging with a required review step
- On-device recognition for player overview fields, attributes, badge tiers, and transaction logs
- Original Android launcher icon with adaptive and themed-icon artwork
- XP and attribute upgrades with escalating costs
- Badge tracker
- Dynamic off-court encounters with hidden consequences
- Persistent relationship system and NPC memories
- Interactive social feed, likes, replies and player posts
- Fictional media ecosystem, rumors and companion-generated news
- Dynamic storylines, rivalries and career chapters
- Sponsors, contract offers, counters, obligations and brand objectives
- Agent trust and simplified career finances
- Offseason training, recovery, relationships, sponsor work, community work and vacations
- Around-the-league news and persistent world players
- Manual trade/free-agency/waiver confirmation for important MyNBA roster moves
- Career milestones, trophy room, history and legacy
- Aging and wear-and-tear when seasons advance
- Immersion modes: Basketball Focused / Immersive / Full Life / Chaos
- Quick / Normal / Detailed pre-NBA simulation pacing
- Optional romantic-life events toggle
- JSON export/import for backups and phone-to-phone transfer
- Canon labels: 2K Confirmed / User Confirmed / Companion Canon / Rumor

## Important mobile design rule

NBA 2K26 remains the source of truth for basketball. A game, draft result, trade, signing, award, etc. becomes **2K Confirmed** only when you enter it or explicitly approve recognized fields in the scan-review screen. OCR results are never silently committed.

## Project stack

- React Native
- Expo SDK 57
- TypeScript
- Expo SQLite key-value storage
- Expo Image Picker for camera/gallery capture
- On-device ML Kit text recognition on Android
- No server and no account required by the app itself

## Development start

1. Install Node.js.
2. Open this project folder in a terminal.
3. Run `npm install`.
4. Create an Android development build or EAS build.

The screen scanner contains a native OCR module and is not available inside Expo Go. The rest of the project can still be inspected there, but camera autofill requires a development/APK build.

## Standalone builds

The included `eas.json` has build profiles for mobile packaging.

The repository also includes a GitHub Actions workflow that builds a release APK after a push to `main` or a manual workflow dispatch. The finished artifact is named `NBA2K26-Career-Companion-v1.2.1-APK`.

Android APK:

    npm install
    npx eas-cli build --platform android --profile preview

Android native local build after installing Android Studio / Android SDK:

    npm install
    npx expo prebuild --platform android
    npx expo run:android

For iOS, Apple requires Xcode/macOS for local native builds or Apple credentials for a signed cloud/device build:

    npm install
    npx eas-cli build --platform ios --profile preview

The source is complete, but this package does not contain a pre-signed APK or IPA. Signing credentials and platform build tooling are intentionally not embedded in the project.

## Save transfer

Open **More → Settings → Share / export save** on one phone. Import the resulting JSON through **Import save JSON** on the other platform.

## Copyright / branding

This is a fan-made companion project. NBA, NBA 2K and related marks belong to their respective owners. The project does not ship game assets or circumvent game protections.

## Version 1.1 — Player Setup Update

Version 1.1 adds a first-launch prospect setup screen and an editable player profile. You can now set your player name, position, age, height, weight, hometown, nationality, dominant hand, high-school year, starting school/academy/club, and jersey number before the career begins. Existing Version 1 saves are migrated and shown the setup screen once so the placeholder identity can be replaced without deleting career progress. Player identity can later be edited from **More → Player → Edit profile**.

The **Randomize basketball profile** action now preserves your chosen identity, body information, position, school, and jersey number; it only randomizes basketball ability/upside/personality.

## Version 1.2 — 2K Screen Scanner

Version 1.2 adds small camera buttons beside the box score, player overview, attributes, badges, and league transactions. The user can take a TV photo or choose a direct console screenshot. Text recognition runs on the phone, then a review sheet shows current and scanned values with per-row checkboxes. Only checked rows are applied.

The parser supports labeled game stats and column-style box scores, common NBA 2K attribute names, badge tiers, player OVR/POT/body fields, and multi-line trade/signing/waiver/release logs. Direct screenshots and sharp, glare-free TV photos give the best results.

The Android package also includes a custom launcher icon using the companion's charcoal and coral palette. Separate foreground and monochrome assets support adaptive masks and Android 13+ themed icons.
