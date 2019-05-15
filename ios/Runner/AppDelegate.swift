import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window.rootViewController as? FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "flutter.native/helper", binaryMessenger: controller!)
    weak var weakSelf: AppDelegate? = self
    nativeChannel.setMethodCallHandler { (call, result) in
        if ("helloFromNativeCode" == call.method) {
            let strNative = weakSelf?.helloFromNativeCode()
            result(strNative)
        } else if (call.method == "whatsAppShare") {
            if let path = call.arguments as? String {
                if (weakSelf?.shareOnWhatsApp(path: path)) != nil {
                    result((FlutterMethodNotImplemented))
                }
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func helloFromNativeCode() -> String? {
        return "Hello from iOS..."
    }
    
    func shareOnWhatsApp(path: String) -> String? {
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    let documentInteractionController = UIDocumentInteractionController(url: URL(string: path)!)
                    documentInteractionController.uti = "net.whatsapp.movie"
                    let rootVC = UIApplication.shared.keyWindow?.rootViewController
                    documentInteractionController.presentOpenInMenu(from: .zero, in: rootVC!.view, animated: true)
                    return nil
                }
            }
        }
        return "Error"
    }
}
