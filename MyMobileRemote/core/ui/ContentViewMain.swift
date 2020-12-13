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
                self.rokuChannelButtons.set()
            }) {
                Text("Save")
            }.buttonStyle(DefaultButtonStyle())
        }
    }
    
    var body: some View {
//        let command: String = AppDelegate.sanitizeURL(url: latestRequest.request?.url?.absoluteString ?? "") ?? "error"
        let command: String = latestRequest.request?.url?.absoluteString ?? "error"
        var success = latestResponse.error == nil
        if let resp = latestResponse.response {
            let statusCode = resp.statusCode
            success = success && (200 <= statusCode) && (statusCode < 300)
        }
        let msg = success ? nil :
            latestResponse.data == nil ? latestResponse.error?.localizedDescription : String(data: latestResponse.data!, encoding: .utf8)
        return VStack {
            Spacer(minLength: Constants.CELL_HEIGHT / 2)
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
                            ScrollView {
                                ContentViewRoku()
                                    .tabItem {
                                        Text("Roku")
                                    }.onTapGesture {
                                        self.currentRemote = .roku
                                    }.tag(RemoteType.roku)
                            }
                        } else if remote.title == "Home" {
                            ScrollView {
                                ContentViewHome()
                                    .tabItem {
                                        Text("Home")
                                    }.onTapGesture {
                                        self.currentRemote = .home
                                    }.tag(RemoteType.home)
                            }
                        }
                    }
                }
            }.tabViewStyle(PageTabViewStyle())
        }
        .padding(.top).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
