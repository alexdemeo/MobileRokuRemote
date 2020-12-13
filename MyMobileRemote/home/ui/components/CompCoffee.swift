//
//  SwiftUIView.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 12/1/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI


let defaultTime = "8:30"

func defaultSchedTime(calendar: Calendar) -> Date {
    var comps = DateComponents()
    let parts = defaultTime.split(separator: ":").map{ Int($0) }
    comps.hour = parts[0]
    comps.minute = parts[1]
    return calendar.date(from: comps)!
}


struct ComponentCoffee: View {
    @State var status: String = "🟡"
    @State var schedTime: Date = defaultSchedTime(calendar: Calendar.current)
    
    
    func sendRefreshRequest() {
        AppDelegate.instance.networkManager.async(url: "\(pi3URL)/coffee/status", method: "GET", header: nil, body: nil, callback: {
            data, response, error in
            guard let data = data else {
                return
            }
            let code = String(data: data, encoding: .utf8)
            switch code {
            case "on":
                self.status = "🟢"
            case "off":
                self.status = "🔴"
            default:
                self.status = "🟡"
            }
            print("machine is \(String(describing: code))")
        })
    }
    
    
    func command(cmd: String, callback: ((Data?,  HTTPURLResponse?, Error?) -> Void)?) {
        AppDelegate.instance.networkManager.async(url: "\(pi3URL)/coffee/\(cmd)", method: "PUT", header: nil, body: nil, callback: callback)
    }
    
    
    var body: some View {
        let time = Calendar.current.dateComponents([.hour, .minute], from: self.schedTime)
        return VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text(self.status)
                    .padding(.trailing, 45)
                Button("↻", action: self.sendRefreshRequest)
                Spacer()
                Button("⏽") {
                    self.command(cmd: "on") { data, response, error in
                        if let code = response?.statusCode, code == 201 {
                            self.status = "🟢"
                        }
                    }
                }
                Button("⭘") {
                    self.command(cmd: "off") { data, response, error in
                        if let code = response?.statusCode, code == 201 {
                            self.status = "🔴"
                        }
                    }
                }.padding(.leading, 60)
            }
            HStack {
                DatePicker("Schedule", selection: $schedTime, displayedComponents: .hourAndMinute).labelsHidden()
                Spacer()
                Button("✓") {
                    self.command(cmd: "schedule/\(time.hour!):\(time.minute!)", callback: nil)
                }
                Spacer(minLength: Constants.CELL_WIDTH / 5)
                Button("ⓧ") {
                    self.command(cmd: "schedule/cancel", callback: nil)
                }
            }
            VStack { // TODO: printer
                
            }
        }.padding(.all).frame(width: Constants.REMOTE_WIDTH / 2, height: Constants.REMOTE_HEIGHT, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ComponentCoffee_Previews: PreviewProvider {
    static var previews: some View {
        ComponentCoffee()
            .buttonStyle(BorderlessButtonStyle())
    }
}
