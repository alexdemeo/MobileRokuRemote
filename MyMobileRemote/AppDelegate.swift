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
        AppDelegate.instance.netAsync(url: "\(AppDelegate.instance.settings.rokuBaseURL)/query/apps", method: "GET")
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
//    var audioLevel = 0.0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.rokuChannelButtons.sendRefreshRequest()
        let audioSession = AVAudioSession.sharedInstance()
        do {
           try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.prior, NSKeyValueObservingOptions.initial], context: nil)
//            self.audioLevel = Double(audioSession.outputVolume)
        } catch {
           print("Error")
        }
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        guard let session = object as? AVAudioSession else {
//            return
//        }
        if keyPath == "outputVolume"{
            guard let dict = change else {
                return
            }
            guard let new = dict[NSKeyValueChangeKey.newKey] as? Float, let old = dict[NSKeyValueChangeKey.oldKey] as? Float else {
                return
            }
            print("\(old) => \(new)")
            if (old < new) {
                Buttons.Roku.VOLUME_UP.exec()
            } else if (old > new) {
                Buttons.Roku.VOLUME_DOWN.exec()
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
    
    func netAsync(url: String, method: String) {
//        print("net(url: \(url), method: \(method))")
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = method
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            DispatchQueue.main.async {
                self.latestRequest.request = req // this is here so status update changes on reply
                self.latestResponse.data = data
                self.latestResponse.response = response as? HTTPURLResponse
                self.latestResponse.error = error
                guard let endpoint = AppDelegate.sanitizeURL(url: url) else {
                    return
                }
                guard let response = self.latestResponse.response else {
                    return
                }
                self.handleAsyncRokuResponseFrom(endpoint: endpoint, withResponse: response)
            }
        }
        task.resume()
    }
    
    private func updateTextFieldFor(character: String) {
        print("updateTextFieldFor(\(character)")
        self.text.text = character
    }
    
    private func handleAsyncRokuResponseFrom(endpoint e: String, withResponse response: HTTPURLResponse) {
        print("Result from endpoint: \(e) statusCode: \(self.latestResponse.response?.statusCode ?? -1)")

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
            var apps: [RokuApp] = []
            if let data = self.latestResponse.data {
                let info = String(data: data, encoding: .utf8)
                apps = info!.matches(for: "<app.*<\\/app>").map({
                    RokuApp(line: $0)
                })
            }
            print("Made buttons for apps:\n\(apps.map({"\t\($0)"}).joined(separator: "\n"))")
            let buttons = apps.map({
                RemoteButton(forType: .roku, symbol: $0.name, endpoint: .launch, command: $0.id, associatedApp: $0)
            })
            self.rokuChannelButtons.updateFor(array: buttons)
        }
    }
    
    func netSync(url: String, method: String) -> (Data?, HTTPURLResponse?, Error?)? {
        let s = DispatchSemaphore(value: 0)
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = method
        var result: (Data?, HTTPURLResponse?, Error?) = (nil, nil, nil)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            result = (data, response as? HTTPURLResponse, error)
            s.signal()
        }
        task.resume()
        let waitResult = s.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(Constants.ROKU_APP_QUERY_TIMEOUT_SECONDS))
        return waitResult == .success ? result : nil
    }
    
    static var instance: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    static func sanitizeURL(url: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "^http.*[0-9]", options: .caseInsensitive) else {
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
            .buttonStyle(BorderlessButtonStyle())
    }
}
