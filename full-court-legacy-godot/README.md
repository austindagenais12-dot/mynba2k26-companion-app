# Full Court Legacy — Godot Android prototype

An original, Android-first player-lock basketball career prototype built with Godot 4.7.2. You control one created player at all times in a fictional Lakeshore Raptors open gym.

## Playable features

- Third-person player-lock movement and camera
- Corrected four-direction mobile joystick with diagonal movement
- Austin-inspired articulated player model with swept dark hair, thick brows, full beard, moustache, and broader athletic proportions
- Procedural idle, walk, sprint, dribble-hand, crossover, defensive-shuffle, shot-gather, jump, release, and follow-through animations
- Mobile joystick plus sprint, crossover, shoot, and reset-ball controls
- Keyboard equivalents for desktop testing
- Hold/release shot timing with early, late, good, and green feedback
- Distance-based two- and three-point attempts
- Defender positioning and proximity-based shot contests
- Physical ball, backboard, segmented rim, rebounds, loose-ball recovery, and scoring trigger
- Two-minute repeatable open-gym sessions
- Persistent career XP, points, attempts, makes, and sessions in `user://full_court_legacy_career.json`
- Fully procedural court, gym, players, hoop, HUD, and original fictional identity

## Controls

| Action | Touch | Keyboard |
|---|---|---|
| Move | Left joystick | WASD / arrows |
| Sprint | Hold **SPRINT** | Shift |
| Crossover | Tap **CROSS** | E |
| Shoot | Hold and release **SHOOT** | Hold and release Space |
| Recover/reset ball | Tap **RESET BALL** | R |

## Run in Godot

Open this folder as a Godot 4.7.2 project and press **F6/F5**. The project uses GDScript and the GL Compatibility renderer, so it does not require .NET or third-party assets.

## Android package

The `Android` export preset produces a debug-signed ARM64 APK. The accompanying GitHub Actions workflow installs the matching Godot export templates, validates the game headlessly, exports the APK, and uploads it as a build artifact.

## Original-game boundary

Full Court Legacy is inspired by the depth and player-lock perspective of modern basketball career games, but it uses original code, names, UI, league concepts, and art. It includes no NBA, NBA 2K, team, player, logo, audio, or other licensed assets.
