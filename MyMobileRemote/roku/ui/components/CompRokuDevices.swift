//
//  ComponentRokuDevices.swift
//  MyRemote
//
//  Created by Alex DeMeo on 7/14/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ComponentRokuDevices: View {
    @EnvironmentObject var rokuChannelButtons: ObservedRokuButtons
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        let inputs = self.rokuChannelButtons.array.filter({ $0.associatedApp?.type == "tvin" })
        let channels = self.rokuChannelButtons.array.filter({ $0.associatedApp?.type == "appl" })
        let w =  Constants.CELL_WIDTH / 1.5
        let h = Constants.CELL_HEIGHT + Constants.SPACING_VERTICAL * 1.75
        return AnyView(VStack {
            ComponentGroupedView(inputs.map({ btn in
                AnyView(Button(action: btn.exec) {
                    SingleDeviceView(
                        app: btn.associatedApp!,
                        imgData: self.rokuChannelButtons.buttonToImg[btn.associatedApp!.id] as? Data,
                        labeled: true
                    ).frame(width: w, height: h).scaledToFit()
                })
            }))
            ComponentGroupedView(channels.map({ btn in
                AnyView(Button(action: btn.exec) {
                    SingleDeviceView(
                        app: btn.associatedApp!,
                        imgData: self.rokuChannelButtons.buttonToImg[btn.associatedApp!.id] as? Data
                    ).frame(width: w, height: h).scaledToFit()
                })
            }))
        })
    }
}

struct ComponentRokuDevices_Previews: PreviewProvider {
    static var previews: some View {
        ComponentRokuDevices()
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
    }
}
