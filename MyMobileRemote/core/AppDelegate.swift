//
//  AppDelegate.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 7/6/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import UIKit
import SwiftUI
import AVKit

class DisplaySettingsPane: ObservableObject {
    @Published var shown: Bool = false
}

class Request: ObservableObject {
    @Published var request: URLRequest? = nil
}

class Response: ObservableObject {
    @Published var data: Data? = nil
    @Published var response: HTTPURLResponse? = nil
    @Published var error: Error? = nil
}

class ObservedRokuButtons: ObservableObject {
    @Published var array = [RemoteButton]()
    
    func sendRefreshRequest() {
        AppDelegate.instance.netAsync(url: "\(AppDelegate.instance.settings.rokuBaseURL)/query/apps", method: "GET", header: nil, body: nil, callback: nil)
    }
    
    func updateFor(array: [RemoteButton]) {
        self.array = array
    }
}

class ObservedText: ObservableObject {
    @Published var text: String? = nil
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var settings: Settings = Settings.load()!
    var displaySettingsPane: DisplaySettingsPane = DisplaySettingsPane()
    var latestRequest: Request = Request()
    var latestResponse: Response = Response()
    var rokuChannelButtons: ObservedRokuButtons = ObservedRokuButtons()
    var text: ObservedText = ObservedText()
    var networkManager: NetworkManager = NetworkManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.rokuChannelButtons.sendRefreshRequest()
        let audioSession = AVAudioSession.sharedInstance()
        do {
           try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: [
                                        NSKeyValueObservingOptions.new,
                                        NSKeyValueObservingOptions.old,
            ], context: nil)
        } catch {
           print("Error")
        }
        return true
    }
    
    
    func clearDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            if !self.settings.volButtons {
                return
            }
            guard let dict = change else {
                return
            }
            guard let new = dict[NSKeyValueChangeKey.newKey] as? Float, let old = dict[NSKeyValueChangeKey.oldKey] as? Float else {
                return
            }
            if (old < new) {
                Buttons.VOLUME_UP.exec()
            } else if (old > new) {
                Buttons.VOLUME_DOWN.exec()
            }
        }
     }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

    func netAsync(url: String, method: String, header: [String: String]?, body: [String: String]?, callback: ((Data?,  HTTPURLResponse?, Error?) -> Void)?) {
        self.networkManager.async(url: url, method: method, header: header, body: body, callback: callback)
    }
    
    func updateTextFieldFor(character: String) {
        print("updateTextFieldFor(\(character)")
        self.text.text = character
    }
   
//
//    func netSync(url: String, method: String) -> (Data?, HTTPURLResponse?, Error?)? {
//        let s = DispatchSemaphore(value: 0)
//        var req = URLRequest(url: URL(string: url)!)
//        req.httpMethod = method
//        var result: (Data?, HTTPURLResponse?, Error?) = (nil, nil, nil)
//        let task = URLSession.shared.dataTask(with: req) { data, response, error in
//            result = (data, response as? HTTPURLResponse, error)
//            s.signal()
//        }
//        task.resume()
//        let waitResult = s.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(Constants.ROKU_APP_QUERY_TIMEOUT_SECONDS))
//        return waitResult == .success ? result : nil
//    }
    
    func netSync(url: String, method: String) -> (Data?, HTTPURLResponse?, Error?)? {
        return self.networkManager.sync(url: url, method: method)
    }
    
    static var instance: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    static func sanitizeURL(url: String) -> String? {
        print(url)
        guard let regex = try? NSRegularExpression(pattern: "^http:\\/\\/([0-9]|\\.|:)*", options: .caseInsensitive) else {
            return nil
        }
        return regex.stringByReplacingMatches(in: url, options: [], range: NSRange(location: 0, length:  url.count), withTemplate: "")
    }
}

struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewMain()
            .environmentObject(AppDelegate.instance.settings)
            .environmentObject(AppDelegate.instance.displaySettingsPane)
            .environmentObject(AppDelegate.instance.latestRequest)
            .environmentObject(AppDelegate.instance.latestResponse)
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
            .environmentObject(AppDelegate.instance.networkManager)
            .buttonStyle(BorderlessButtonStyle())
    }
}
