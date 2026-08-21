# NBA 2K26 Career Companion Mobile — Version 1

A standalone mobile career-RPG companion for NBA 2K26 MyNBA Player Lock. This edition deliberately does **not** connect to VenueLab, NBA 2K26 memory, or your PC. You confirm the important in-game facts manually; the app generates the immersive career world around them.

## Included in V1

- Touch-first Home / Career / Play / Social / More interface
- Persistent offline local save using Expo SQLite key-value storage
- Shared save format between Android and iOS
- Randomized prospect creation
- Compressed High School / NCAA / JUCO / OTE / NBL / European pathways
- NBA Draft handoff: NBA 2K26 MyNBA determines your actual draft team and pick
- Manual 2K-confirmed game logging
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

NBA 2K26 remains the source of truth for basketball. The mobile app never pretends it saw your game. A game, draft result, trade, signing, award, etc. becomes **2K Confirmed** only when you enter it.

## Project stack

- React Native
- Expo SDK 57
- TypeScript
- Expo SQLite key-value storage
- No server and no account required by the app itself

## Development start

1. Install Node.js.
2. Open this project folder in a terminal.
3. Run `npm install`.
4. Run `npx expo start` or create a development build.

## Standalone builds

The included `eas.json` has build profiles for mobile packaging.

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
