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
    @Published var ipPi: String
    @Published var keyboardMode: KeyboardMode
    @Published var volume: Int
    @Published var isRokuOnly: Bool
    
    private static let path = URL(fileURLWithPath: "settings.json")
    private static let firstTimeKey = "firstTime"

    var rokuBaseURL: String {
        "http://\(AppDelegate.instance.settings.ipRoku):8060"
    }
    
    var cecBaseURL: String {
        "http://\(AppDelegate.instance.settings.ipPi):5000"
    }
//    AppDelegate.instance().net(url: "http://\(AppDelegate.settings().ipRoku):8060\(self.commandStr)", method: "POST")

    init(ipRoku: String, ipPi: String, keyboardMode: KeyboardMode, volume: Int, isRokuOnly: Bool) {
        self.ipRoku = ipRoku
        self.ipPi = ipPi
        self.keyboardMode = keyboardMode
        self.volume = volume
        self.isRokuOnly = isRokuOnly
        self.save()
    }
    
    func save() {
        print("saving settings...")
        self.printSettings()
        
        let defaults = UserDefaults.standard
        defaults.set(self.ipRoku, forKey: "ipRoku")
        defaults.set(self.ipPi, forKey: "ipPi")
        defaults.set(self.keyboardMode.rawValue, forKey: "keyboardMode")
        defaults.set(self.volume, forKey: "volume")
        defaults.set(self.isRokuOnly, forKey: "isRokuOnly")
    }
    
    func printSettings() {
        print("\tipRoku=\(self.ipRoku)")
        print("\tipPi=\(self.ipPi)")
        print("\tkeyboardMode=\(self.keyboardMode)")
        print("\tvolume=\(self.volume)")
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
                               ipPi:            defaults.string(forKey: "ipPi")!,
                               keyboardMode:    KeyboardMode(rawValue: defaults.string(forKey: "keyboardMode")!)!,
                               volume:          defaults.integer(forKey: "volume"),
                               isRokuOnly:      defaults.bool(forKey: "isRokuOnly"))
            print("loaded=", res.ipRoku)
            res.printSettings()
            return res
        }
    }
}
