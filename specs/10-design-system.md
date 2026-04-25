# 10 — Design System

> **Version:** 0.1-MVP | **Status:** Planning
> Yellow + Blue · Warm tone · Chill to look at
> All values are implementation-ready. Copy directly into `theme.dart`.

---

## Colour Palette

### Primary

| Token | Hex | Usage |
|---|---|---|
| `kYellowPrimary` | `#FFC53D` | Primary actions, highlights, success glow |
| `kYellowLight` | `#FFF3C0` | Backgrounds, card fills, idle states |
| `kYellowDark` | `#B97C00` | Yellow text on light bg, hover states |
| `kYellowAccent` | `#FFE082` | Drop zone idle border, soft highlights |
| `kBluePrimary` | `#4A90D9` | Secondary actions, progress, toggles |
| `kBlueLight` | `#D6EAFF` | Blue card fills, info states |
| `kBlueDark` | `#1A4F7A` | Blue text on light bg |
| `kBlueDeep` | `#0D3359` | Parent dashboard headers |

### Warm Neutrals

| Token | Hex | Usage |
|---|---|---|
| `kWarmWhite` | `#FDF8EE` | Main canvas (child side) |
| `kWarmSurface` | `#F5EDD8` | Card backgrounds |
| `kWarmBorder` | `#E8D5A3` | Dividers, inactive borders |
| `kWarmMuted` | `#C4A96B` | Disabled state |
| `kTextPrimary` | `#3D2C00` | All primary text (warm brown-black) |
| `kTextSecondary` | `#7A6235` | Labels, captions |
| `kTextHint` | `#B8A06A` | Placeholder, hint text |

### Semantic

| Token | Hex | Usage |
|---|---|---|
| `kSuccess` | `#4CAF50` | Success indicators (sparingly) |
| `kError` | `#E53935` | Auth errors only |
| `kOverlay` | `#3D2C0066` | Modal overlays (40% warm black) |

---

## Typography

```dart
// Google Fonts: Sarabun (Thai-first, warm, highly legible)
// Fallback: system-ui

const kFontFamily = 'Sarabun';

// Scale
const kTextXL   = TextStyle(fontFamily: kFontFamily, fontSize: 32, fontWeight: FontWeight.w700, color: kTextPrimary, height: 1.3);
const kTextLg   = TextStyle(fontFamily: kFontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: kTextPrimary, height: 1.4);
const kTextMd   = TextStyle(fontFamily: kFontFamily, fontSize: 18, fontWeight: FontWeight.w500, color: kTextPrimary, height: 1.5);
const kTextBase = TextStyle(fontFamily: kFontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: kTextPrimary, height: 1.6);
const kTextSm   = TextStyle(fontFamily: kFontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: kTextSecondary, height: 1.5);
const kTextXs   = TextStyle(fontFamily: kFontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: kTextHint, height: 1.4);

// Child-facing labels (larger for accessibility)
const kChildLabel = TextStyle(fontFamily: kFontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: kTextPrimary, height: 1.4);
```

---

## Spacing System

```dart
// 8px base grid
const kSpace1 = 4.0;
const kSpace2 = 8.0;
const kSpace3 = 12.0;
const kSpace4 = 16.0;
const kSpace5 = 20.0;
const kSpace6 = 24.0;
const kSpace8 = 32.0;
const kSpace10 = 40.0;
const kSpace12 = 48.0;
const kSpace16 = 64.0;
```

---

## Border Radius

```dart
const kRadiusSm  = BorderRadius.circular(8);
const kRadiusMd  = BorderRadius.circular(16);
const kRadiusLg  = BorderRadius.circular(24);
const kRadiusXl  = BorderRadius.circular(32);
const kRadiusFull = BorderRadius.circular(999);  // pill / circle
```

---

## Elevation & Shadow

No Material elevation. Use warm-tinted custom shadows.

```dart
// Gentle warm card shadow
const kShadowSm = BoxShadow(
  color: Color(0x20B97C00),
  blurRadius: 8,
  offset: Offset(0, 2),
);

const kShadowMd = BoxShadow(
  color: Color(0x30B97C00),
  blurRadius: 16,
  offset: Offset(0, 4),
);

const kShadowLg = BoxShadow(
  color: Color(0x40B97C00),
  blurRadius: 24,
  offset: Offset(0, 8),
);
```

---

## Component Specs

### ScenarioCard (Module A Hub)

```
Size: 160×200dp
Background: kWarmSurface
Border: 1.5px kWarmBorder
Border radius: kRadiusMd
Shadow: kShadowSm

Structure:
  [Thumbnail image — 160×120dp, fills top]
  [kSpace3 padding]
  [Title — kChildLabel, kTextPrimary, max 2 lines]
  [kSpace2]
  [Category badge — kBlueLight bg, kBlueDark text, 12px, pill]

Disabled state:
  Thumbnail: 40% opacity
  Overlay: kWarmBorder at 50% on top
  Title: kTextHint colour
  Not tappable (AbsorbPointer)

Active/hover state (child tap):
  scale: 1.04 (200ms ease)
  Shadow: kShadowMd
```

### ModuleCard (ModeSelectScreen)

```
Size: fills 1/3 of screen width minus padding (min 120dp, max 200dp)
Aspect ratio: 1:1.2
Background: kYellowLight
Border radius: kRadiusLg
Shadow: kShadowMd

Structure:
  [Illustration — 80×80dp, centred, top 40% of card]
  [Thai label — kTextLg, kTextPrimary, centred]
  [Description line — kTextSm, kTextSecondary, centred, max 1 line]

Tap state:
  scale: 1.04, 200ms
```

### VocabularyCard (Sound Board)

```
Size: square, fills grid cell (screen_width / 5 - 12dp)
Background: white
Border: 1px kWarmBorder
Border radius: kRadiusMd
Shadow: kShadowSm

Structure:
  [Image — 70% of card height]
  [Word — kChildLabel, kTextPrimary, centred]

Active state:
  Border: 2px kBluePrimary
  Shadow: kShadowMd
  Fades to idle after 1s
```

### PrimaryButton (Parent side)

```
Height: 52dp
Background: kYellowPrimary
Text: kTextLg, kTextPrimary (brown on yellow)
Border radius: kRadiusMd
Width: fills parent

Disabled:
  Background: kWarmMuted
  Text: kTextHint

Loading:
  CircularProgressIndicator, kTextPrimary colour, 20dp
```

### Toggle Switch (Parent Scenarios)

```
Use Flutter Switch with:
  activeColor: kBluePrimary
  activeTrackColor: kBlueLight
  inactiveThumbColor: kWarmMuted
  inactiveTrackColor: kWarmBorder
```

---

## Animation Constants

```dart
const kDurationFast   = Duration(milliseconds: 150);
const kDurationNormal = Duration(milliseconds: 300);
const kDurationSlow   = Duration(milliseconds: 500);

const kCurveDefault   = Curves.easeInOut;
const kCurveSpring    = Curves.elasticOut;
const kCurvePop       = Curves.easeOutBack;
```

---

## Flutter ThemeData

```dart
ThemeData get appTheme => ThemeData(
  fontFamily: kFontFamily,
  colorScheme: ColorScheme.light(
    primary: kYellowPrimary,
    secondary: kBluePrimary,
    surface: kWarmWhite,
    background: kWarmWhite,
    onPrimary: kTextPrimary,
    onSecondary: Colors.white,
    error: kError,
  ),
  scaffoldBackgroundColor: kWarmWhite,
  appBarTheme: AppBarTheme(
    backgroundColor: kWarmWhite,
    foregroundColor: kTextPrimary,
    elevation: 0,
    titleTextStyle: kTextLg,
  ),
  cardTheme: CardTheme(
    color: kWarmSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: kRadiusMd,
      side: BorderSide(color: kWarmBorder, width: 1.0),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kWarmSurface,
    border: OutlineInputBorder(
      borderRadius: kRadiusMd,
      borderSide: BorderSide(color: kWarmBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: kRadiusMd,
      borderSide: BorderSide(color: kBluePrimary, width: 2),
    ),
    labelStyle: kTextSm,
    hintStyle: kTextSm.copyWith(color: kTextHint),
  ),
  useMaterial3: true,
);
```

---

## Iconography

- Use **Phosphor Icons** (phosphor_flutter package) — rounded, friendly, not too technical.
- Child side: no icons except back arrow.
- Parent side: tab icons (list, chart-bar, toggle-right).
- Size: 24dp standard, 28dp for tab bar.
- Colour: always `kTextSecondary` inactive, `kBluePrimary` active.

---

## Do / Don't

| Do | Don't |
|---|---|
| Warm yellow + sky blue | Neon or saturated greens |
| Rounded corners everywhere | Sharp right angles |
| Sarabun for all text | Sans-serif without Thai character support |
| Gentle shadows (warm tint) | Material elevation shadows (grey) |
| Animate on success (celebrate) | Animate on failure (punish) |
| Large hitboxes (60dp min) | Small tap targets |
