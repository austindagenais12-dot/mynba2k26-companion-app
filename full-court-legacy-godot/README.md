# Full Court Legacy — Godot Android prototype v0.4

An original, Android-first player-lock basketball career prototype built with Godot 4.7.2. You control one created player at all times in a fictional Lakeshore Raptors open gym.

## Playable features

- Third-person player-lock movement and camera
- Corrected four-direction mobile joystick with diagonal movement
- Smooth Austin-inspired sports-anime player with swept dark hair, expressive eyes, thick brows, full beard, moustache, and broader athletic proportions
- Original production turnaround based on the supplied front/profile photos, with a matching Lakeshore Raptors No. 7 uniform
- Rounded capsule, sphere, and tapered-mesh anatomy and clothing—no block-shaped player body parts
- Mobile-efficient toon skin, eye, hair, beard, uniform, and shoe materials with ink-like silhouette outlines
- Eleven real `AnimationPlayer` clips: idle, walk, sprint, left/right dribble, left/right crossover, shot gather, shot release/follow-through, defensive stance, and defensive shuffle
- Cubic-angle keyframe interpolation and custom transition blending instead of direct per-frame pose twitching
- Motion Studio with 2,304 saved signature combinations that rebuild authored curve amplitude and playback timing across locomotion, release, handle, and tempo styles
- Mobile joystick plus sprint, crossover, shoot, and reset-ball controls
- Keyboard equivalents for desktop testing
- Hold/release shot timing with early, late, good, and green feedback
- Distance-based two- and three-point attempts
- Defender positioning and proximity-based shot contests
- Aerodynamic ball simulation with quadratic drag, backspin decay, Magnus lift, and an iterative shot solver
- Regulation-scaled 32-segment rim with tuned steel/backboard/court restitution and friction
- 84-particle constraint net with nylon drag, ball interaction, and five-pass real-time deformation
- Physical rebounds, loose-ball recovery, and downward scoring trigger
- Two-minute repeatable open-gym sessions
- Persistent career XP, points, attempts, makes, and sessions in `user://full_court_legacy_career.json`
- Rebuilt real-world Lakeshore gym with polished maple grain, cinderblock/acoustic walls, safety padding, six-row retractable bleachers, clerestory windows, double exits, trusses, HVAC, LED fixtures, scorer table, benches, and ball rack
- Original scoreboard, shot clock, championship banners, Canadian flag, mountain mural, court wordmarks, and Lakeshore Raptors identity
- Fully original court, gym, players, hoop, HUD, and fictional identity

## Controls

| Action | Touch | Keyboard |
|---|---|---|
| Move | Left joystick | WASD / arrows |
| Sprint | Hold **SPRINT** | Shift |
| Crossover | Tap **CROSS** | E |
| Shoot | Hold and release **SHOOT** | Hold and release Space |
| Recover/reset ball | Tap **RESET BALL** | R |
| Open animation picker | Tap **MOTION STUDIO** | Q cycles one style |

## Run in Godot

Open this folder as a Godot 4.7.2 project and press **F6/F5**. The project uses GDScript and the GL Compatibility renderer, so it does not require .NET or proprietary third-party assets.

The included anime character is a complete in-engine articulated rig designed for mobile and backed by authored Godot animation resources. It is not yet a hand-sculpted and skinned Blender GLB; `assets/models/README.md` defines that later production model/LOD contract, and `assets/animations/README.md` defines the scalable motion-capture import pipeline.

## Android package

The `Android` export preset produces a debug-signed ARM64 APK. The accompanying GitHub Actions workflow installs the matching Godot export templates, validates the game headlessly, exports the APK, and uploads it as a build artifact.

## Original-game boundary

Full Court Legacy is inspired by the depth and player-lock perspective of modern basketball career games, but it uses original code, names, UI, league concepts, and art. It includes no NBA, NBA 2K, team, player, logo, audio, or other licensed assets.
