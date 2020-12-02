//
//  ComponentArrows.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/26/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ComponentArrows: View {
    var buttonUp: RemoteButton
    var buttonDown: RemoteButton
    var buttonLeft: RemoteButton
    var buttonRight: RemoteButton
    var buttonOK: RemoteButton
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.SPACING_VERTICAL * 1.5) {
            HStack(alignment: .top) {
                Spacer().frame(width: Constants.CELL_WIDTH)
                Button(action: buttonUp.exec ) { Text(buttonUp.symbol) }.scaleEffect(2.0)
                Spacer().frame(width: Constants.CELL_WIDTH)
            }
            HStack(spacing: Constants.SPACING_VERTICAL * 1.75) {
                Button(action: buttonLeft.exec) { Text(buttonLeft.symbol) }.scaleEffect(2.0)
                Button(action: buttonOK.exec) { Text(buttonOK.symbol) }.scaleEffect(2.0)
                Button(action: buttonRight.exec) { Text(buttonRight.symbol) }.scaleEffect(2.0)
            }
            HStack(alignment: .bottom) {
                Spacer().frame(width: Constants.CELL_WIDTH)
                Button(action: buttonDown.exec) { Text(buttonDown.symbol) }.scaleEffect(2.0)
                Spacer().frame(width: Constants.CELL_WIDTH)
            }
        }
    }
}

struct ComponentArrows_Previews: PreviewProvider {
    static var previews: some View {
        ComponentArrows(
            buttonUp: Buttons.UP,
            buttonDown: Buttons.DOWN,
            buttonLeft: Buttons.LEFT,
            buttonRight: Buttons.RIGHT,
            buttonOK: Buttons.OK
        ).buttonStyle(BorderlessButtonStyle())
    }
}
