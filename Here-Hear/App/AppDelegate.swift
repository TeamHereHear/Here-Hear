import FirebaseCore
import UIKit
import FirebaseAuth
import GoogleSignIn
import MusicKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // Firebase 및 기타 초기 설정을 구성
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        MusicManger.shared.setupMusic()
        return true
    }

    // 구글 로그인 처리를 위한 함수
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
