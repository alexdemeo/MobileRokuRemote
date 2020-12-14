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
    
    func exec() { // This is a dumb paradigm, I'm too lazy to fix it rn.
        switch self.type {
        case .roku:
            self.roku()
        case .home:
            self.home()
        }
    }
    
    private func home() {
    }
    
    private func roku() {
        let url = "\(AppDelegate.instance.settings.rokuBaseURL)\(self.commandStr)"
        AppDelegate.instance.networkManager.async(url: url, method: "POST", header: nil, body: nil) {
            data, response, error in
            guard let endpoint = NetworkManager.sanitizeURL(url: url) else {
                return
            }
            AppDelegate.instance.handleAsyncRokuResponseFrom(endpoint: endpoint, withResponse: response!) // ik this is bad programming, currently too lazy to fix it
        }
    }
}
