import Cocoa
import FlutterMacOS
import Sparkle

public class BTSparklePlugin: NSObject, FlutterPlugin {
  private let updaterController: SPUStandardUpdaterController

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "btsparkle", binaryMessenger: registrar.messenger)
    let instance = BTSparklePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  override init() {
    updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    super.init()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "checkForUpdates" {
      updaterController.checkForUpdates(nil)
      result(nil)
    }
  }
}
