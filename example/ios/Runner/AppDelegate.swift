import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// The key used by the Google Maps SDK to render map tiles.
  ///
  /// Supplied by the same `--dart-define=GOOGLE_MAPS_API_KEY=...` that feeds the
  /// Dart code and the Android manifest. The "Inject Google Maps API key" build
  /// phase decodes it out of DART_DEFINES and writes it into the built
  /// Info.plist, so there is nothing to configure per machine.
  ///
  /// A GOOGLE_MAPS_API_KEY environment variable on the Run scheme is honoured
  /// too, for anyone launching from Xcode rather than from `flutter run`.
  private var mapsApiKey: String {
    // An unresolved build setting arrives as the literal "$(NAME)".
    if let fromPlist = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
      !fromPlist.isEmpty, !fromPlist.hasPrefix("$(")
    {
      return fromPlist
    }

    if let fromEnvironment = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"],
      !fromEnvironment.isEmpty
    {
      return fromEnvironment
    }

    return "PASTE_GOOGLE_MAPS_API_KEY_HERE"
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey(mapsApiKey)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
