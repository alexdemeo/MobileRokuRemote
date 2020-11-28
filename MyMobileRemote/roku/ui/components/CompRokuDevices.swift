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
    
    var body: some View {
        if self.rokuChannelButtons.array.isEmpty {
            return AnyView(Text("Couldn't load roku apps. Check IP"))
        } else {
            let inputs = self.rokuChannelButtons.array.filter({ $0.associatedApp?.type == "tvin" })
            let channels = self.rokuChannelButtons.array.filter({ $0.associatedApp?.type == "appl" })
            let w =  Constants.CELL_WIDTH / 1.5
            let h = Constants.CELL_HEIGHT + Constants.SPACING_VERTICAL * 1.75
            return AnyView(VStack {
                ComponentGroupedView(inputs.map({ btn in
                    AnyView(Button(action: btn.exec) {
                        btn.associatedApp!.viewLabeled.frame(width: w, height: h).scaledToFit()
                    })
                }))
                ComponentGroupedView(channels.map({ btn in
                    AnyView(Button(action: btn.exec) {
                        btn.associatedApp!.viewLabelless.frame(width: w, height: h).scaledToFit()
                    })
                }))
            })
        }
    }
}

struct ComponentRokuDevices_Previews: PreviewProvider {
    static var previews: some View {
        ComponentRokuDevices()
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
    }
}
