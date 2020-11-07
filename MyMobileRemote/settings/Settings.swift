//
//  Settings.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/30/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import Foundation

enum KeyboardMode: String, Codable, CaseIterable {
    case off, roku, cec
}

enum CodingKeys: CodingKey {
    case ipRoku, ipPi, keyboardMode
}

class Settings : ObservableObject { // this needs to be a reference type
    @Published var ipRoku: String
    @Published var isRokuOnly: Bool
    @Published var volButtons: Bool
    
    private static let path = URL(fileURLWithPath: "settings.json")
    private static let firstTimeKey = "firstTime"

    var rokuBaseURL: String {
        "http://\(AppDelegate.instance.settings.ipRoku):8060"
    }
    
//    AppDelegate.instance().net(url: "http://\(AppDelegate.settings().ipRoku):8060\(self.commandStr)", method: "POST")

    init(ipRoku: String, isRokuOnly: Bool, volButtons: Bool) {
        self.ipRoku = ipRoku
        self.isRokuOnly = isRokuOnly
        self.volButtons = volButtons
        self.save()
    }
    
    func save() {
        print("saving settings...")
        self.printSettings()
        
        let defaults = UserDefaults.standard
        defaults.set(self.ipRoku, forKey: "ipRoku")
        defaults.set(self.isRokuOnly, forKey: "isRokuOnly")
        defaults.set(self.volButtons, forKey: "volButtons")
    }
    
    func printSettings() {
        print("\tipRoku=\(self.ipRoku)")
        print("\tisRokuOnly=\(self.isRokuOnly)")
    }
    
    static func load() -> Settings? {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: firstTimeKey) {
            defaults.set(true, forKey: firstTimeKey)
            print("First time, setting default settings")
            let res = Constants.DEFAULT_SETTINGS
            res.save()
            return res
        } else {
            let res = Settings(ipRoku:          defaults.string(forKey: "ipRoku")!,
                               isRokuOnly:      defaults.bool(forKey: "isRokuOnly"),
                               volButtons:      defaults.bool(forKey: "volButtons"))
            print("loaded=", res.ipRoku)
            res.printSettings()
            return res
        }
    }
}
