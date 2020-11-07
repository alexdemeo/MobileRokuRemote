//
//  ContentViewSettings.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/25/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ContentViewSettings: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Roku IP")
                TextField(settings.ipRoku, text: $settings.ipRoku)
//                    .border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Volume buttons")
                Toggle("", isOn: $settings.volButtons)
            }
        }
    }
}

struct ContentViewSettings_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewSettings()
            .environmentObject(Settings.load()!)
    }
}
