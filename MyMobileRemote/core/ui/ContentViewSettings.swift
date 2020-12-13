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
        VStack(alignment: .center, spacing: 10) {
            ComponentRemotePicker()
            HStack {
                Text("Roku IP")
                TextField(settings.ipRoku, text: $settings.ipRoku)
//                    .border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Default coffee schedule")
                Spacer()
                DatePicker("", selection: $settings.coffeeDefaultSchedTime, displayedComponents: .hourAndMinute).labelsHidden()
            }
            HStack {
                Text("Heat notification delay")
                TextField("", text: $settings.coffeeNotificationDelayMinutes)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .labelsHidden()
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
