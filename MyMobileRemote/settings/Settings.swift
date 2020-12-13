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

struct RemoteData: Codable, Equatable {
    var title: String
    var enabled: Bool
}

class Settings : ObservableObject { // this needs to be a reference type
    @Published var ipRoku: String
    @Published var volButtons: Bool
    @Published var remotes: [RemoteData]
    @Published var coffeeDefaultSchedTime: Date
    @Published var coffeeNotificationDelayMinutes: String
    
    var coffeeNotificationDelayMinutesDouble: Double {
        Double(self.coffeeNotificationDelayMinutes)!
    }
    
    private static let path = URL(fileURLWithPath: "settings.json")
    private static let firstTimeKey = "firstTime"
    
    var rokuBaseURL: String {
        "http://\(AppDelegate.instance.settings.ipRoku):8060"
    }
    
    init(ipRoku: String, volButtons: Bool, remotes: [RemoteData], coffeeDefaultSchedTime: Date, coffeeNotificationDelayMinutes: String) {
        self.ipRoku = ipRoku
        self.volButtons = volButtons
        self.remotes = remotes
        self.coffeeDefaultSchedTime = coffeeDefaultSchedTime
        self.coffeeNotificationDelayMinutes = coffeeNotificationDelayMinutes
        self.save()
    }
    
    func save() {
        print("saving settings...")
        self.printSettings()
        
        let defaults = UserDefaults.standard
        defaults.set(self.ipRoku, forKey: "ipRoku")
        defaults.set(self.volButtons, forKey: "volButtons")
        let remoteData: [String] = self.remotes.map { String(data: try! JSONEncoder().encode($0), encoding: .utf8)! }
        defaults.set(remoteData, forKey: "remotes")
        defaults.set(self.coffeeDefaultSchedTime, forKey: "coffeeDefaultSchedTime")
        defaults.set(self.coffeeNotificationDelayMinutes, forKey: "coffeeNotificationDelayMinutes")
    }
    
    func printSettings() {
        print("\tipRoku=\(self.ipRoku)")
        print("\tvolButtons=\(self.volButtons)")
        print("\tremotes=\(self.remotes)")
        print("\tcoffeeDefaultSchedTime=\(self.coffeeDefaultSchedTime)")
        print("\tcoffeeNotificationDelayMinutes=\(self.coffeeNotificationDelayMinutes)")
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
            let res = Settings(
                ipRoku:                 defaults.string(forKey: "ipRoku")!,
                volButtons:             defaults.bool(forKey: "volButtons"),
                remotes:                defaults.stringArray(forKey: "remotes")?.map {
                                            try? JSONDecoder().decode(RemoteData.self, from: $0.data(using: .utf8)!)
                                        } as? [RemoteData] ?? Constants.DEFAULT_SETTINGS.remotes,
                coffeeDefaultSchedTime: defaults.object(forKey: "coffeeDefaultSchedTime") as? Date ??  Constants.DEFAULT_SETTINGS.coffeeDefaultSchedTime,
                coffeeNotificationDelayMinutes: defaults.string(forKey: "coffeeNotificationDelayMinutes") ?? Constants.DEFAULT_SETTINGS.coffeeNotificationDelayMinutes
            )
            print("loaded=", res.ipRoku)
            res.printSettings()
            return res
        }
    }
}
