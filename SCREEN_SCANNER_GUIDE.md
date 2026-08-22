# 2K Screen Scanner Guide

## Camera button locations

- **Play → Box score:** opponent/result, game importance, PTS, REB, AST, STL, BLK, TOV, shooting makes/attempts, minutes, and plus/minus.
- **More → Player → player card:** team, position, overall, potential, age, jersey number, height, and weight.
- **More → Player → Player Development:** recognized attribute names and ratings. Scan one category page at a time if needed.
- **More → Player → Badges:** recognized badge names and tier text.
- **More → League → Confirm MyNBA transactions:** multiple trades, signings, waivers, releases, and waiver claims from one transaction-log screen.

## How a scan works

1. Tap the small camera button beside the section.
2. Choose **Take photo** or **Choose screenshot**.
3. Wait for on-device text recognition.
4. Review every current/scanned comparison.
5. Uncheck anything that looks wrong.
6. Tap **Apply**. Unrecognized fields remain unchanged and manual editing stays available.

Game scans fill the form first; the game is not processed until **Finish game & process career** is tapped.

## Capture tips

- A direct PlayStation/Xbox console screenshot transferred to the phone is usually clearest.
- For a TV photo, hold the phone square to the screen and move close enough that stat labels are sharp.
- Avoid reflections, motion blur, menu animations, and extreme viewing angles.
- Include labels and values together. For a table box score, include the column headings and the full row containing your player name.
- Scan additional attribute or badge pages separately. Each scan changes only the fields it recognizes and the user approves.

## Android build note

The scanner uses a native OCR module, so it requires an EAS APK, Codemagic build, or Android development build. It does not run inside Expo Go. On first use, Google Play Services may need internet access to prepare its text-recognition model; recognition is then performed on the device and the app does not upload the selected image to an OCR server.
