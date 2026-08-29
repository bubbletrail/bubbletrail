import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var pendingFileUrl: URL?
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    methodChannel = FlutterMethodChannel(
      name: "app.bubbletrail.app/file_handler",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getInitialFile" {
        if let url = self?.pendingFileUrl {
          result(url.path)
          self?.pendingFileUrl = nil
        } else {
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // Copies a dive log file into the documents directory and hands it to Dart,
  // or stores it for Dart to request on startup when deferred.
  func handleFileUrl(_ url: URL, deferred: Bool = false) -> Bool {
    let ext = url.pathExtension.lowercased()
    if ext == "xml" || ext == "ssrf" || ext == "uddf" || ext == "json" {
      // Copy file to app's documents directory to ensure we have access
      let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let destinationUrl = documentsPath.appendingPathComponent("import_\(UUID().uuidString).\(ext)")

      do {
        // Start accessing security-scoped resource if needed
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
          if accessing {
            url.stopAccessingSecurityScopedResource()
          }
        }

        try FileManager.default.copyItem(at: url, to: destinationUrl)

        if deferred || methodChannel == nil {
          // Dart is not listening yet, store for later
          pendingFileUrl = destinationUrl
        } else {
          // Send to Flutter
          methodChannel?.invokeMethod("fileReceived", arguments: destinationUrl.path)
        }
        return true
      } catch {
        print("Error copying file: \(error)")
        return false
      }
    }

    return false
  }
}
