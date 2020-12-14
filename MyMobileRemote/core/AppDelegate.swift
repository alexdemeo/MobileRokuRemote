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
    @Published var array: [RemoteButton] = []
    @Published var buttonToImg: [String: Data?] = [:]

    func requestButtons() {
        AppDelegate.instance.networkManager.async(url: "\(AppDelegate.instance.settings.rokuBaseURL)/query/apps", method: "GET", header: nil, body: nil) { data, response, error in
            print("ObservedRokuButtons.requestButtons()")
            var apps: [RokuApp] = []
            if let data = data {
                let info = String(data: data, encoding: .utf8)
                apps = info!.matches(for: "<app.*<\\/app>").map({
                    RokuApp(line: $0)
                })
            }
            let buttons = apps.map({
                RemoteButton(forType: .roku, symbol: $0.name, endpoint: .launch, command: $0.id, associatedApp: $0)
            })
            self.array = buttons
            
            self.array.forEach({ remoteButton in
                let id = remoteButton.associatedApp!.id
                AppDelegate.instance.networkManager.async(url: "\(AppDelegate.instance.settings.rokuBaseURL)/query/icon/\(id)", method: "GET", header: nil, body: nil) { data, response, error in
                    guard let response = response else {
                        self.buttonToImg[id] = nil
                        return
                    }
                    if response.statusCode == 200 {
                        self.buttonToImg[id] = data!
                    }
                }
            })
        }
    }
}

class ObservedText: ObservableObject {
    @Published var text: String? = nil
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var settings: Settings = Settings.load()!
    var displaySettingsPane: DisplaySettingsPane = DisplaySettingsPane()
    var rokuChannelButtons: ObservedRokuButtons = ObservedRokuButtons()
    var text: ObservedText = ObservedText()
    var networkManager: NetworkManager = NetworkManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        if self.rokuChannelButtons.
        self.rokuChannelButtons.requestButtons()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
            DispatchQueue.main.async {
                if (granted) {
                    UIApplication.shared.registerForRemoteNotifications()
                } else{
                    print("Notification permissions not granted")
                }
            }
        })
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
    
    //Called when a notification is delivered to a foreground app.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler([.sound, .banner, .badge])
    }

    //Called to let your app know which action was selected by the user for a given notification.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        completionHandler()
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
    
    func updateTextFieldFor(character: String) {
        print("updateTextFieldFor(\(character)")
        self.text.text = character
    }
    
    
    func handleAsyncRokuResponseFrom(endpoint e: String, withResponse response: HTTPURLResponse) {
        print("Result from endpoint: \(e) statusCode: \(self.networkManager.latestResponse.response?.statusCode ?? -1)")

        if !e.matches(for: "^(?i)\\/(keypress)?\\/?volume\\/?(up|down)$").isEmpty
            && response.statusCode == 200 {
            // if it's a volume endpoint
            if e.lowercased().contains("up") {
            } else if e.lowercased().contains("down") {
            } else if e.lowercased().contains("Lit_") {
                let char = e.split(separator: "_")[1]
                self.updateTextFieldFor(character: String(char))
            }
        } else if !e.matches(for: "^/query/apps$").isEmpty {
//            self.rokuChannelButtons.set()
        }
    }
    
    func netSync(url: String, method: String) -> (Data?, HTTPURLResponse?, Error?)? {
        return self.networkManager.sync(url: url, method: method)
    }
    
    static var instance: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    static func sanitizeURL(url: String) -> String? {
        //        print(url)
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
            .environmentObject(AppDelegate.instance.networkManager.latestRequest)
            .environmentObject(AppDelegate.instance.networkManager.latestResponse)
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
            .environmentObject(AppDelegate.instance.networkManager)
            .buttonStyle(BorderlessButtonStyle())
    }
}
