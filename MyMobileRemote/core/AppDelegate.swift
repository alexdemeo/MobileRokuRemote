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
    @Published var buttonsView: AnyView = AnyView(Text("Couldn't load roku apps. Check IP"))
//    var buttonView: AnyView = AnyView(Text("Couldn't load roku apps. Check IP"))
    
    private static func getButtons() -> [RemoteButton] {
        if let (data, _, _) = AppDelegate.instance.netSync(url: "\(AppDelegate.instance.settings.rokuBaseURL)/query/apps", method: "GET") {
            print("here")
            var apps: [RokuApp] = []
            if let data = data {
                let info = String(data: data, encoding: .utf8)
                apps = info!.matches(for: "<app.*<\\/app>").map({
                    RokuApp(line: $0)
                })
            }
            print("Made buttons for apps:\n\(apps.map({"\t\($0)"}).joined(separator: "\n"))")
            let buttons = apps.map({
                RemoteButton(forType: .roku, symbol: $0.name, endpoint: .launch, command: $0.id, associatedApp: $0)
            })

            return buttons
        } else {
            return []
        }
    }
    
    func set() {
        self.buttonsView = ObservedRokuButtons.getGroupedButtonView_slow(array: ObservedRokuButtons.getButtons())
    }
    
    private static func getGroupedButtonView_slow(array: [RemoteButton]) -> AnyView {
        let inputs = array.filter({ $0.associatedApp?.type == "tvin" })
        let channels = array.filter({ $0.associatedApp?.type == "appl" })
        let w =  Constants.CELL_WIDTH / 1.5
        let h = Constants.CELL_HEIGHT + Constants.SPACING_VERTICAL * 1.75
        return AnyView(VStack {
            ComponentGroupedView(inputs.map({ btn in
                AnyView(Button(action: btn.exec) {
                    btn.associatedApp!.viewLabeled.frame(width: w, height: h).scaledToFit()
                })
            }))
            ComponentGroupedView(channels.map({ btn in
                AnyView(Button(action: btn.exec) {
                    btn.associatedApp!.viewLabelless.frame(width: w, height: h).scaledToFit()
                })
            }))
        })
    }
}

class ObservedText: ObservableObject {
    @Published var text: String? = nil
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var settings: Settings = Settings.load()!
    var displaySettingsPane: DisplaySettingsPane = DisplaySettingsPane()
    var rokuChannelButtons: ObservedRokuButtons = ObservedRokuButtons()
    var text: ObservedText = ObservedText()
    var networkManager: NetworkManager = NetworkManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.rokuChannelButtons.set()
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
            self.rokuChannelButtons.set()
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
