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

let defaultTime = "8:30"

func defaultSchedTime(calendar: Calendar) -> Date {
    var comps = DateComponents()
    let parts = defaultTime.split(separator: ":").map{ Int($0) }
    comps.hour = parts[0]
    comps.minute = parts[1]
    return calendar.date(from: comps)!
}

struct ContentViewHome: View {
    @EnvironmentObject var coffeeMachine: ObservedCoffeeMachine
    @State var schedTime: Date = defaultSchedTime(calendar: Calendar.current)
    
    var body: some View {
        let binding = Binding(
            get: { self.coffeeMachine.coffeeState == .on },
            set: {
                self.coffeeMachine.coffeeState = $0 ? .on : .off
                
            }
        )
        let time = Calendar.current.dateComponents([.hour, .minute], from: self.schedTime)
        return VStack {
            VStack(alignment: .center, spacing: Constants.SPACING_VERTICAL) {// coffee
                Toggle(isOn: binding) {
                    Text("Coffee")
                }.toggleStyle(SwitchToggleStyle()).onReceive([binding].publisher.first()) {
                    print("request machine: \($0)")
                    AppDelegate.instance.netAsync(url: "\(pi3URL)/\($0.wrappedValue ? "on" : "off")", method: "PUT", header: nil, body: nil, callback: nil)
                }
                HStack {
                    DatePicker("Schedule", selection: $schedTime, displayedComponents: .hourAndMinute).labelsHidden()
                    Spacer()
                    Button("✓") {
                        AppDelegate.instance.netAsync(url: "\(pi3URL)/schedule/\(time.hour!):\(time.minute!)", method: "PUT", header: nil, body: nil, callback: nil)
                    }
                    Spacer(minLength: Constants.CELL_WIDTH / 5)
                    Button("ⓧ") {
                        AppDelegate.instance.netAsync(url: "\(pi3URL)/schedule/cancel", method: "PUT", header: nil, body: nil, callback: nil)
                    }
                }
            }
            VStack { // TODO: printer
                
            }
        }.padding(.all).frame(width: Constants.REMOTE_WIDTH / 2, height: Constants.REMOTE_HEIGHT, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}


struct ContentViewHome_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewHome()
            .environmentObject(AppDelegate.instance.coffeeMachine)
            .buttonStyle(BorderlessButtonStyle())
    }
}
