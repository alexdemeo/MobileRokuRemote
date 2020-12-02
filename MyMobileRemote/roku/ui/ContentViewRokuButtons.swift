//
//  ContentViewRoku.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/25/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ContentViewRokuButtons: View {
    @EnvironmentObject var rokuChannelButtons: ObservedRokuButtons
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.SPACING_VERTICAL) {
            ComponentTop(buttonVolumeUp: Buttons.VOLUME_UP,
                         buttonVolumeDown: Buttons.VOLUME_DOWN,
                         buttonPower: Buttons.POWER,
                         buttonMute: Buttons.MUTE)
            HStack {
                Button(action: Buttons.BACK.exec) {
                    Text(Buttons.BACK.symbol).padding(.trailing, 3)
                }.scaleEffect(/*@START_MENU_TOKEN@*/2.0/*@END_MENU_TOKEN@*/)
                Spacer().frame(width: Constants.CELL_WIDTH)
                Button(action: Buttons.HOME.exec) {
                    Text(Buttons.HOME.symbol).padding(.bottom, 4)
                }.scaleEffect(/*@START_MENU_TOKEN@*/2.0/*@END_MENU_TOKEN@*/)
            }.padding(.top)
            ComponentArrows(buttonUp: Buttons.UP,
                            buttonDown: Buttons.DOWN,
                            buttonLeft: Buttons.LEFT,
                            buttonRight: Buttons.RIGHT,
                            buttonOK: Buttons.OK)
            HStack {
                Button(action: Buttons.REFRESH.exec) { Text(Buttons.REFRESH.symbol) }
                    .scaleEffect(2.0)
                Spacer().frame(width: Constants.CELL_WIDTH)
                Button(action: Buttons.ASTERISK.exec) { Text(Buttons.ASTERISK.symbol) }.scaleEffect(2.0)
            }.padding(.bottom)
            HStack(spacing: Constants.REMOTE_CENTER_GAP_WIDTH) {
                Button(action: Buttons.REWIND.exec) { Text(Buttons.REWIND.symbol) }.scaleEffect(2.0)
                Button(action: Buttons.PLAY_PLAUSE.exec) { Text(Buttons.PLAY_PLAUSE.symbol) }.scaleEffect(2.0)
                Button(action: Buttons.FORWARD.exec) { Text(Buttons.FORWARD.symbol) }.scaleEffect(2.0)
            }.padding(.bottom)
        }.padding(.top)
    }
}

struct ContentViewRokuButtons_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewRokuButtons()
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
            .buttonStyle(BorderlessButtonStyle())
    }
}
