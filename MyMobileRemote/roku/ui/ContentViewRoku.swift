//
//  ContentViewRoku.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 11/27/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ContentViewRoku: View {
    var body: some View {
        ComponentKeyboardPanel().frame(width: Constants.CELL_WIDTH * 1.5)
        ContentViewRokuButtons().padding(.bottom)
        ComponentRokuDevices().padding(.bottom)
    }
}

struct ContentViewRoku_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewRoku()
    }
}
