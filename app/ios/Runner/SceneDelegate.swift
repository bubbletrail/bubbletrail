import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Files that launched the app arrive here; Dart picks them up via
    // getInitialFile once it is running.
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      for context in connectionOptions.urlContexts {
        _ = appDelegate.handleFileUrl(context.url, deferred: true)
      }
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)

    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      for context in URLContexts {
        _ = appDelegate.handleFileUrl(context.url)
      }
    }
  }
}
