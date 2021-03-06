//
//  ContentView.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/25/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ContentViewMain: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var displaySettingsPane: DisplaySettingsPane
    @EnvironmentObject var latestRequest: Request
    @EnvironmentObject var latestResponse: Response
    @EnvironmentObject var rokuChannelButtons: ObservedRokuButtons
    @EnvironmentObject var text: ObservedText
    @EnvironmentObject var networkManager: NetworkManager
    @State var currentRemote: RemoteType? = nil

    var settingsView: some View {
        VStack {
            ContentViewSettings().padding(.vertical)
            Button(action: {
                self.settings.save()
                self.displaySettingsPane.shown.toggle()
            }) {
                Text("Save")
            }.buttonStyle(DefaultButtonStyle())
        }
    }
    
    var body: some View {
        var hostAbbrev: String = "UNKNOWN";
        let host = latestRequest.request?.url?.host
        // this sometimes multiline status was shifting things down
        // so this is a hacky fix for that. Should get a more wholesome
        // scalable solution in the future
        if (host == settings.ipRoku) {
            hostAbbrev = "ROKU"
        } else if (pi3URL.contains(host ?? "FORCE_FAIL")) {
            hostAbbrev = "COFFEE"
        }  else if (pi2URL.contains(host ?? "FORCE_FAIL")) {
            hostAbbrev = "PRINTER"
        }
        let command: String = hostAbbrev + (latestRequest.request?.url?.path ?? "/error")
        var success = latestResponse.error == nil
        if let resp = latestResponse.response {
            let statusCode = resp.statusCode
            success = success && (200 <= statusCode) && (statusCode < 300)
        }
        let msg = success ? nil :
            latestResponse.data == nil ? latestResponse.error?.localizedDescription : String(data: latestResponse.data!, encoding: .utf8)
        return VStack {
            if self.displaySettingsPane.shown {
                self.settingsView
            } else {
                ComponentStatus(command: command, msg: msg, success: success, statusCode: latestResponse.response?.statusCode ?? -1).padding(.bottom)
                    .onTapGesture {
                        self.currentRemote = RemoteType.init(rawValue: self.settings.remotes.first?.title ?? "Roku")
                        self.displaySettingsPane.shown.toggle()
                    }
            }
            TabView(selection: $currentRemote) {
                ForEach(self.settings.remotes, id: \.title) { remote in
                    if remote.enabled {
                        if remote.title == "Roku" {
                            ScrollView(.vertical, showsIndicators: false) {
                                ContentViewRoku()
                            }.tabItem {
                                Text("Roku")
                            }.tag(RemoteType.roku)
                        } else if remote.title == "Home" {
                            ScrollView(.vertical, showsIndicators: false) {
                                ContentViewHome()
                            }.tabItem {
                                Text("Home")
                            }.tag(RemoteType.home)
                        }
                    }
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)).id(self.currentRemote?.rawValue ?? "null")
        }
        .padding(.top)
    }
}

struct ContentViewMain_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewMain()
            .environmentObject(AppDelegate.instance.displaySettingsPane)
            .environmentObject(AppDelegate.instance.networkManager.latestRequest)
            .environmentObject(AppDelegate.instance.networkManager.latestResponse)
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
            .environmentObject(AppDelegate.instance.text)
            .environmentObject(AppDelegate.instance.settings)
            .buttonStyle(BorderlessButtonStyle())
    }
}
