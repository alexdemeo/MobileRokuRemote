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
            ComponentTop(buttonVolumeUp: Buttons.Roku.VOLUME_UP,
                         buttonVolumeDown: Buttons.Roku.VOLUME_DOWN,
                         buttonPower: Buttons.Roku.POWER,
                         buttonMute: Buttons.Roku.MUTE)
            HStack {
                Button(action: Buttons.Roku.BACK.exec) {
                    Text(Buttons.Roku.BACK.symbol).padding(.trailing, 3)
                }.scaleEffect(/*@START_MENU_TOKEN@*/2.0/*@END_MENU_TOKEN@*/)
                Spacer().frame(width: Constants.CELL_WIDTH)
                Button(action: Buttons.Roku.HOME.exec) {
                    Text(Buttons.Roku.HOME.symbol).padding(.bottom, 4)
                }.scaleEffect(/*@START_MENU_TOKEN@*/2.0/*@END_MENU_TOKEN@*/)
            }.padding(.top)
            ComponentArrows(buttonUp: Buttons.Roku.UP,
                            buttonDown: Buttons.Roku.DOWN,
                            buttonLeft: Buttons.Roku.LEFT,
                            buttonRight: Buttons.Roku.RIGHT,
                            buttonOK: Buttons.Roku.OK)
            HStack {
                Button(action: Buttons.Roku.REFRESH.exec) { Text(Buttons.Roku.REFRESH.symbol) }
                    .scaleEffect(2.0)
                Spacer().frame(width: Constants.CELL_WIDTH)
                Button(action: Buttons.Roku.ASTERISK.exec) { Text(Buttons.Roku.ASTERISK.symbol) }.scaleEffect(2.0)
            }.padding(.bottom)
            HStack(spacing: Constants.REMOTE_CENTER_GAP_WIDTH) {
                Button(action: Buttons.Roku.REWIND.exec) { Text(Buttons.Roku.REWIND.symbol) }.scaleEffect(2.0)
                Button(action: Buttons.Roku.PLAY_PLAUSE.exec) { Text(Buttons.Roku.PLAY_PLAUSE.symbol) }.scaleEffect(2.0)
                Button(action: Buttons.Roku.FORWARD.exec) { Text(Buttons.Roku.FORWARD.symbol) }.scaleEffect(2.0)
            }.padding(.bottom)
        }.padding(.top)
    }
}

struct ContentViewRoku_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewRokuButtons()
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
            .buttonStyle(BorderlessButtonStyle())
    }
}
