# google_maps_widget_demo

Demo app for the [google_maps_widget](https://pub.dev/packages/google_maps_widget)
package. It draws a route between two points, tracks a mock driver along it, and
demonstrates error handling, dark mode and both ways of updating the source.

## Requirements

Pinned in `.fvmrc`, so [fvm](https://fvm.app) users get the right toolchain
automatically.

| | |
| --- | --- |
| Flutter | 3.38.0 or newer (pinned to 3.44.8) |
| Android | minSdk 24, Gradle 9.1.0, AGP 9.0.1, JDK 17 |
| iOS | deployment target 14.0, CocoaPods |

## 1. Get an API key

Create one in the [Google Cloud Console](https://console.cloud.google.com), then
enable **all three** of these on the project, plus **billing**:

- Maps SDK for Android
- Maps SDK for iOS
- Routes API

Missing the Routes API is the most common mistake: the map renders, the markers
appear, and no route is ever drawn. The app surfaces the reason in a red banner
via the widget's `onError` callback, so check there first.

Enable **Routes API**, not the older Directions API. That one is in Legacy
status and Google no longer allows it to be enabled on new Cloud projects.

> [!WARNING]
> An application restricted key (Android package name plus SHA-1, or iOS bundle
> id) **will not work for the route**. Those restrictions are enforced by the
> native Maps SDK, which attaches the app identity; the Routes API call is a
> plain HTTPS request from Dart and carries none. Google rejects it with:
>
> ```
> PERMISSION_DENIED: Requests from this Android client application <empty> are blocked.
> ```
>
> Map tiles keep working, so only the route disappears. Use two keys: one
> application restricted for the SDKs, and one restricted by **API** only
> (Routes API) for `apiKey:`. Cap its quota and set a billing alert, since a key
> without an application restriction is extractable from the app. For
> production, proxy the call through your own backend so the key never ships.

## 2. Supply the key

Copy the template and fill it in:

```sh
cp .env.example .env
```

```
GOOGLE_MAPS_API_KEY=your_key_here
```

then run:

```sh
flutter run --dart-define-from-file=.env
```

That is the whole setup. `--dart-define-from-file` is built into Flutter, so
there is no package to add, and the key never reaches a command line or your
shell history. `.env` is covered by `.gitignore`, `.pubignore` and `.ignore`, so
it is not committed, not published, and not surfaced in editor search.

### From VS Code

Launch configurations are checked in for both ways of opening this project, and
both read the same `example/.env`. Create the file, press F5, nothing else.

| What you opened in VS Code | Config used |
| --- | --- |
| The package root, `google_maps_widget/` | `.vscode/launch.json` |
| The example app, `google_maps_widget/example/` | `example/.vscode/launch.json` |

VS Code only reads the `.vscode/launch.json` belonging to the folder you opened,
so the two never conflict.

### Where the key actually goes

One entry in `.env` reaches three different places, which is why this works at
all rather than only covering the Dart code:

| Destination | For | How it gets there |
| --- | --- | --- |
| `lib/main.dart` | the route (Routes API) | `String.fromEnvironment`, which must be `const` |
| `AndroidManifest.xml` | map tiles on Android | `android/app/build.gradle` decodes `dart-defines` into a manifest placeholder |
| `Info.plist` | map tiles on iOS | the **Inject Google Maps API key** build phase decodes `DART_DEFINES`, read by `AppDelegate.swift` |

iOS needs that build phase because the values arrive base64 encoded in
`DART_DEFINES`, which xcconfig cannot decode. It writes into the **built**
`Info.plist` rather than generating an xcconfig, because xcconfig build settings
are resolved before build phases run, so a generated one would be a build stale.

> [!NOTE]
> Do not reach for `flutter_dotenv`. It reads the file at runtime inside Dart,
> but Android needs the key at build time to put it in the manifest, and iOS
> needs it before Flutter starts. It can only ever cover one of the three.

### Other ways

Pass it inline, though it then lands in your shell history:

```sh
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
```

Or skip the flag entirely and replace the literal `PASTE_GOOGLE_MAPS_API_KEY_HERE`
in `lib/main.dart`, `android/app/build.gradle` and `ios/Runner/AppDelegate.swift`.
Fine for a quick look, but do not commit the result.

## 3. Run

`flutter run` has no project-directory flag, so run these from inside
`example/`. If you are at the package root, `cd example` first.

```sh
flutter pub get
flutter run --dart-define-from-file=.env
```

Build artifacts:

```sh
flutter build apk --debug --dart-define-from-file=.env
flutter build ios --no-codesign --dart-define-from-file=.env
```

## What the demo shows

- **Update source** rebuilds with a new `sourceLatLng`, so the marker and route follow declaratively.
- **Show source info** reaches the map controller through a `GlobalKey`, the imperative path.
- **Dark theme** switches `ThemeMode`, and the app passes a matching `style` JSON to the map.
- A mock driver stream moves a marker and reroutes every 500 ms.
- Total **distance and time** appear under the map, from `totalDistanceCallback` and `totalTimeCallback`. The Routes API returns these numerically, as an `int` of metres and a `Duration`, so the app formats them.
- Route failures appear in a banner at the top, from `onError`.
