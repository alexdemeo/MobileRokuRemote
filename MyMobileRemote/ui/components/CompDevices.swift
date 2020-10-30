//
//  ComponentDeviceInputs.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/28/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ComponentDevices: View {
    var body: some View {
        VStack {
            HStack(spacing: Constants.REMOTE_CENTER_GAP_WIDTH * 2) {
                Button(action: Buttons.Roku.CHAN_NETFLIX.exec) {
                    Text(Buttons.Roku.CHAN_NETFLIX.symbol).alignmentGuide(.leading) { dimension in
                        dimension[.leading]
                    }
                }.scaleEffect(2.0)
                Button(action: Buttons.Roku.CHAN_HULU.exec) { Text(Buttons.Roku.CHAN_HULU.symbol) }
                    .scaleEffect(2.0).alignmentGuide(.trailing) { dimension in
                        dimension[.trailing]
                }
            }
            HStack(spacing: Constants.REMOTE_CENTER_GAP_WIDTH * 2) {
                Button(action: Buttons.Roku.CHAN_SPOTIFY.exec) { Text(Buttons.Roku.CHAN_SPOTIFY.symbol) }
                    .scaleEffect(2.0).alignmentGuide(.leading) { dimension in
                        dimension[.leading]
                }
                Button(action: Buttons.Roku.CHAN_YOUTUBE.exec ) { Text(Buttons.Roku.CHAN_YOUTUBE.symbol) }
                    .scaleEffect(2.0).alignmentGuide(.trailing) { dimension in
                        dimension[.trailing]
                }
            }
            HStack(spacing: Constants.REMOTE_CENTER_GAP_WIDTH) {
                Button(action: Buttons.Roku.DEV_PC.exec) { Text(Buttons.Roku.DEV_PC.symbol) }.scaleEffect(2.0)
                Button(action: Buttons.Roku.DEV_PI2.exec) { Text(Buttons.Roku.DEV_PI2.symbol) }.scaleEffect(2.0)
                Button(action: Buttons.Roku.DEV_AVR.exec) { Text(Buttons.Roku.DEV_AVR.symbol) }.scaleEffect(2.0)
            }.padding(.vertical)
        }
    }
}

struct ComponentDeviceInputs_Previews: PreviewProvider {
    static var previews: some View {
        ComponentDevices()
    }
}
