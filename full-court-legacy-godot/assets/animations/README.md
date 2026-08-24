# Motion Studio pipeline

Motion Studio currently exposes 2,304 playable procedural signature profiles. Each saved profile combines locomotion, release, ball-handle, and tempo families without loading thousands of large skeletal clips into mobile memory.

For future motion-capture imports:

1. Retarget motion to the production humanoid skeleton.
2. Export each family as glTF 2.0 / GLB AnimationLibraries.
3. Keep gameplay clips in small category packs (locomotion, dribble, shots, finishes, defense, reactions).
4. Stream or selectively package animation packs; do not place every source trial in the base APK.
5. Preserve `RESET`, root-motion, looping, and left/right metadata during Godot import.

Legally reusable source candidate: the Carnegie Mellon Graphics Lab Motion Capture Database lists 2,605 trials and states that its motions are free for all uses: https://mocap.cs.cmu.edu/

Never import ripped NBA 2K animation files.
