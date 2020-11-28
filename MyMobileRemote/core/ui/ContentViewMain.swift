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
    
    var body: some View {
        let command: String = AppDelegate.sanitizeURL(url: latestRequest.request?.url?.absoluteString ?? "") ?? "error"
        var success = latestResponse.error == nil
        if let resp = latestResponse.response {
            success = success && resp.statusCode == 200
        }
        let msg = success ? nil : latestResponse.error?.localizedDescription
        return ScrollView {
            ComponentStatus(command: command, msg: msg, success: success, statusCode: latestResponse.response?.statusCode ?? -1).padding(.bottom)
            
            ContentViewRoku()
            if self.displaySettingsPane.shown {
                VStack {
                    ContentViewSettings().padding([.top, .horizontal])
                    Button(action: {
                        self.settings.save()
                        self.displaySettingsPane.shown.toggle()
                        self.rokuChannelButtons.sendRefreshRequest()
                    }) {
                        Text("Save")
                    }
                }.padding(.bottom, 100)
            } else {
                HStack {
                    Button(action: {
                        self.displaySettingsPane.shown.toggle()
                    }) {
                        Text("⚙")
                    }
                }
            }
        }
        .padding(.top)
    }
}


struct ContentViewMain_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewMain()
            .environmentObject(AppDelegate.instance.displaySettingsPane)
            .environmentObject(AppDelegate.instance.latestRequest)
            .environmentObject(AppDelegate.instance.latestResponse)
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
            .environmentObject(AppDelegate.instance.text)
            .buttonStyle(BorderlessButtonStyle())
    }
}
