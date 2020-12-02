//
//  ContentViewHome.swift
//  MyRemote
//
//  Created by Alex DeMeo on 11/25/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

let pi3URL = "http://pi3.local:5000"

struct ContentViewHome: View {

    var body: some View {
        ComponentCoffee()
    }
}


struct ContentViewHome_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewHome()
            .buttonStyle(BorderlessButtonStyle())
    }
}
