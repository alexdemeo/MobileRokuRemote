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
//            guard let response = response else {
//                return
//            }
//            guard let e = response.url?.absoluteString else {
//                return
//            }
//            print("Result from endpoint: \(e) statusCode: \(response.statusCode)")
//            if !e.matches(for: "^(?i)\\/(keypress)?\\/?volume\\/?(up|down)$").isEmpty
//                && response.statusCode == 200 {
//                // if it's a volume endpoint
//                if e.lowercased().contains("up") {
//                } else if e.lowercased().contains("down") {
//                } else if e.lowercased().contains("Lit_") {
//                    let char = e.split(separator: "_")[1]
//                    AppDelegate.instance.updateTextFieldFor(character: String(char))
//                }
//            } else if !e.matches(for: "^/query/apps$").isEmpty {
//                print("here")
//                var apps: [RokuApp] = []
//                if let data = data {
//                    let info = String(data: data, encoding: .utf8)
//                    apps = info!.matches(for: "<app.*<\\/app>").map({
//                        RokuApp(line: $0)
//                    })
//                }
//                print("Made buttons for apps:\n\(apps.map({"\t\($0)"}).joined(separator: "\n"))")
//                let buttons = apps.map({
//                    RemoteButton(forType: .roku, symbol: $0.name, endpoint: .launch, command: $0.id, associatedApp: $0)
//                })
//                AppDelegate.instance.rokuChannelButtons.updateFor(array: buttons)
//            }
        }
    }
}
