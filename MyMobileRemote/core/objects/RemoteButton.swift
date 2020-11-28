//
//  Net.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/30/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import Foundation

struct RemoteButton : Identifiable {
    let type: RemoteType
    let symbol: String
    let endpoint: CommandEndpoint
    let command: String
    let id: String
    let associatedApp: RokuApp?
    
    init(forType type: RemoteType, symbol: String, endpoint: CommandEndpoint, command: String) {
        self.init(forType: type, symbol: symbol, endpoint: endpoint, command: command, associatedApp: nil)
    }
    
    init(forType type: RemoteType, symbol: String, endpoint: CommandEndpoint, command: String, associatedApp: RokuApp?) {
        self.type = type
        self.symbol = symbol
        self.endpoint = endpoint
        self.command = command
        self.id = symbol
        self.associatedApp = associatedApp
    }
    
    private var commandStr: String {
        "/\(self.endpoint)/\([self.command].joined(separator: "/"))"
    }
    
    func exec() {
        switch self.type {
        case .roku:
            self.roku()
        }
    }
    
    private func roku() {
//        if (self.endpoint == .keypress) {
//            if self.command == "VolumeUp" && AppDelegate.settings.volume >= Constants.VOL_MAX {
//                AppDelegate.settings.volume = Constants.VOL_MAX
//                return
//            }
//            if self.command == "VolumeDown" && AppDelegate.settings.volume <= 0 {
//                AppDelegate.settings.volume = 0
//                return
//            }
//        }
        AppDelegate.instance.netAsync(url: "\(AppDelegate.instance.settings.rokuBaseURL)\(self.commandStr)", method: "POST", header: nil, body: nil, callback: nil)
    }
}
