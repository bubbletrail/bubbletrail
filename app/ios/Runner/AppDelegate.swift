import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var pendingFileUrl: URL?
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(
      name: "app.bubbletrail.app/file_handler",
      binaryMessenger: controller.binaryMessenger
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

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Check if this is a file URL we can handle
    let ext = url.pathExtension.lowercased()
    if ext == "xml" || ext == "ssrf" || ext=="uddf" {
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

        // Send to Flutter
        if let channel = methodChannel {
          channel.invokeMethod("fileReceived", arguments: destinationUrl.path)
        } else {
          // App not fully initialized yet, store for later
          pendingFileUrl = destinationUrl
        }
        return true
      } catch {
        print("Error copying file: \(error)")
        return false
      }
    }

    return super.application(app, open: url, options: options)
  }
}
