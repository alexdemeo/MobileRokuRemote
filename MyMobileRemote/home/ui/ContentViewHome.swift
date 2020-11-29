//
//  ContentViewHome.swift
//  MyRemote
//
//  Created by Alex DeMeo on 11/25/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

let pi3URL = "http://pi3.local:5000/coffee"

enum CoffeeState: String {
    case on, off, uknown
}

struct ContentViewHome: View {
    @EnvironmentObject var coffeeMachine: ObservedCoffeeMachine
    
    var body: some View {
        let binding = Binding(
            get: { self.coffeeMachine.coffeeState == .on },
            set: {
                self.coffeeMachine.coffeeState = $0 ? .on : .off
                
            }
        )
        return VStack {
            Toggle(isOn: binding) {
                Text("Coffee: ")
            }
            .onReceive([binding].publisher.first()) {
                if self.coffeeMachine.coffeeState != nil {
                    print("request machine \($0)")
                    AppDelegate.instance.netAsync(url: "\(pi3URL)/\($0.wrappedValue ? "on" : "off")", method: "PUT", header: nil, body: nil, callback: {
                        data, response, error in
                    })
                } else {
//                    self.coffeeMachine.sendRefreshRequest()
                }
            }
            .toggleStyle(SwitchToggleStyle())
        }.padding(.all).frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height, alignment: .center)
    }
}


struct ContentViewHome_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewHome()
            .environmentObject(AppDelegate.instance.coffeeMachine)
            .buttonStyle(BorderlessButtonStyle())
    }
}
