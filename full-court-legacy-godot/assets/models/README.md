# Photoreal player asset contract

The runtime player rig is now the mobile fallback. The production Austin model should be delivered as `austin_player.glb` using glTF 2.0 with:

- one humanoid skeleton and a neutral A-pose bind pose
- body and uniform LOD0 at 55k–80k triangles; mobile LOD1 at 24k–35k; LOD2 at 10k–16k
- separate head, eyes, teeth, strand-card hair/beard, body, jersey, shorts, compression layer, and shoes
- 2K mobile PBR maps for skin/head and uniform; 1K maps for hair, eyes, and shoes
- base-color, normal, ORM, opacity (hair only), and skin thickness/subsurface masks
- facial blend shapes for blink, jaw open, smile, frown, brow raise, and phoneme-ready mouth forms
- no NBA, NBA 2K, real-team, or third-party brand assets

`assets/reference/austin_player_turnaround_v1.jpg` is the repository-sized identity, uniform, proportion, and material target. The game can accept the final `.glb` without changing the physics or Motion Studio systems.
