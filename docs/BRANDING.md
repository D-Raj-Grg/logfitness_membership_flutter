# Branding: icon, splash, logo

## Source of the mark

The LOG wordmark is `../logfitness_web/src/app/icon.svg` (viewBox 512): a near-black
rounded tile with a hand-drawn white `LOG` -- an `L` path, two rings (r 36,
stroke 28) for `O` and `G`, the `G` crossbar, then two cut-outs (a horizontal slit
through the middle band, and a notch at the top-right of the `G`).
`lib/features/common/log_mark.dart` (`LogMark`, `LogMarkPainter`,
`LogMarkGeometry`) reproduces it as one vector path (union of the shapes minus
the mask rectangles). Do not redraw it by hand; change the geometry there only
if the web icon changes. Reference: `../logfitness_web/public/brand/`.

The mark's box is 292 x 100 units. `LogMark(size:)` is the mark width; with
`withTile: true` it is the SVG's full tile (side `size`, mark at 57%).

## Colours

| Name           | Hex       | Use                                           |
| -------------- | --------- | --------------------------------------------- |
| Tar Road       | `#17181D` | icon background, native splash background    |
| Elegant Grey   | `#8B9096` | accent (not used in the icon)                 |
| Paper          | `#F4F5F6` | off-white text on Tar Road (the icon uses pure white) |

## Regenerating every raster

```sh
flutter test tool/gen_icons_test.dart
```

Writes (all drawn from the vector at final size, never downscaled):

- `assets/brand/log_icon_1024.png`, `log_icon_512.png` (opaque, full-bleed, for
  the App Store / Play listing) and `log_mark_foreground_1024.png` (transparent).
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` -- every size Contents.json
  lists, as RGB PNGs with **no alpha channel** (the encoder in the tool writes
  colour type 2; check with `sips -g hasAlpha`).
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/*` -- white mark, 96 pt wide.
- `android/app/src/main/res/mipmap-*/ic_launcher.png`, `ic_launcher_round.png`
  (legacy, pre-Android 8) and `ic_launcher_foreground.png` (adaptive + themed).
- `android/.../drawable-*/launch_mark.png` (pre-Android 12 splash) and
  `drawable-nodpi/splash_icon.png` (Android 12+ splash).

The XML (`mipmap-anydpi-v26/ic_launcher*.xml`, `values/colors.xml`,
`values-v31`, `values-night-v31`, `drawable/launch_background.xml`) and the
`LaunchScreen.storyboard` colour are hand-written and not touched by the tool.

## Safe-zone rules

- **iOS icon**: the 1024 marketing icon is a full-bleed Tar Road square, no
  rounded corners, no alpha -- iOS applies the mask. The mark is 58% of the width.
- **Android adaptive**: 108 dp layer, only the central 66 dp circle is guaranteed
  visible. The mark is 56% of the layer (60.5 dp wide, half-diagonal ~32 dp).
  Background is the `ic_launcher_background` colour; the monochrome layer for
  Android 13 themed icons reuses the same foreground silhouette.
- **Android 12+ splash**: the system draws `splash_icon` inside a circle of ~67%
  of the icon canvas on `windowSplashScreenBackground`; same proportions as the
  adaptive foreground, so the mark fits.
- **Native splash** is always Tar Road with the 96-wide mark centred. Flutter's
  own `SplashScreen` follows the theme: dark mode matches (`surface` = Tar Road);
  light mode shows `#F8F9FA`, so light-mode users see a dark-to-light change at
  handover.
