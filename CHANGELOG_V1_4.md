# NBA 2K26 Career Companion — Version 1.4.0

## Immersive phone

- Added a dedicated Phone tab with a phone-style lock/home screen, status area, app icons and dock.
- Added Messages, Contacts and Calendar phone apps plus a shortcut to the existing Social feed.
- Added persistent conversation threads, unread counts, free-form replies and optional quick replies.
- Added fictional incoming career texts after development checkpoints, draft declaration, draft night, logged games, team changes and season advancement.
- Added contact roles for NBA players, coaches, scouts, agents, family, friends, trainers, executives and media.
- Added manual contact creation and one-tap discovery of era-accurate players from the selected MyNBA roster.
- Added relationship trust/closeness gains for replies to linked contacts.
- Added an explicit notice that all phone conversations are private companion simulation and not real messages from the people named.

## Connected game calendar

- Made the active MyNBA calendar the source of truth for every new NBA game log.
- Replaced manual opponent selection with an unlogged scheduled-matchup selector.
- Locked each new game to its schedule date, opponent and home/away status.
- Prevented duplicate logging of the same schedule row.
- Kept screenshot-assisted box-score entry while ignoring scanned opponent text so it cannot overwrite the selected matchup.
- Added schedule completion totals and progress indicators.
- Added LOGGED status, result and player stat line directly to completed Calendar rows.
- Added the same schedule/completion view inside the Phone Calendar app.
- Preserved existing pre-1.4 game entries as legacy logs.
- Preserved schedule IDs when applying photo overrides or restoring the Modern Era baseline wherever a matchup can be matched.

## Platform and migration

- Advanced the local save schema to version 5 while preserving existing careers.
- Added automatic starter contacts/messages to upgraded saves.
- Advanced app version to 1.4.0 and Android versionCode to 6.
- Kept package `com.careercompanion.nba2k26`, launcher artwork and signing workflow unchanged for in-place Android updates.

