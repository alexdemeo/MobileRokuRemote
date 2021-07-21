//
//  CompPrinterStation.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 7/20/21.
//  Copyright © 2021 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ComponentPrinterStation: View {
    @EnvironmentObject var networkManager: NetworkManager
    
    @State var lightsStatus = "🟡"
    @State var printerStatus = "🟡"
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("3D printer station").bold()
            HStack(alignment: .center, spacing: 40) {
                VStack(alignment: .center, spacing: 30){
                    Text("lights \(self.lightsStatus)").fontWeight(.light)
                    Button("⚪️") {
                        self.command(cmd: "lights/on") { data, response, error in
                            if let code = response?.statusCode, code == 201 {
                                self.lightsStatus = "🟢"
                            }
                        }
                    }
                    Button("⚫️") {
                        self.command(cmd: "lights/off") { data, response, error in
                            if let code = response?.statusCode, code == 201 {
                                self.lightsStatus = "🔴"
                            }
                        }
                    }
                    Button("↻") {
                        self.networkManager.async(url: "\(pi2URL)/station/lights/status", method: "GET", header: nil, body: nil, callback: {
                            data, response, error in
                            guard let data = data else {
                                return
                            }
                            let code = String(data: data, encoding: .utf8)
                            switch code {
                            case "on":
                                self.lightsStatus = "🟢"
                            case "off":
                                self.lightsStatus = "🔴"
                            default:
                                self.lightsStatus = "🟡"
                            }
                            print("lights are \(String(describing: code))")
                        })
                    }
                }
                VStack(alignment: .center, spacing: 30){
                    Text("printer \(self.printerStatus)").fontWeight(.light)
                    Button("🌝") {
                        self.command(cmd: "printer/on") { data, response, error in
                            if let code = response?.statusCode, code == 201 {
                                self.printerStatus = "🟢"
                            }
                        }
                    }
                    Button("🌚") {
                        self.command(cmd: "printer/off") { data, response, error in
                            if let code = response?.statusCode, code == 201 {
                                self.printerStatus = "🔴"
                            }
                        }
                    }
                    Button("↻") {
                        self.networkManager.async(url: "\(pi2URL)/station/printer/status", method: "GET", header: nil, body: nil, callback: {
                            data, response, error in
                            guard let data = data else {
                                return
                            }
                            let code = String(data: data, encoding: .utf8)
                            switch code {
                            case "on":
                                self.printerStatus = "🟢"
                            case "off":
                                self.printerStatus = "🔴"
                            default:
                                self.printerStatus = "🟡"
                            }
                            print("printer is \(String(describing: code))")
                        })
                    }
                }
            }
        }.padding(.all).frame(width: Constants.REMOTE_WIDTH / 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
    func command(cmd: String, callback: ((Data?,  HTTPURLResponse?, Error?) -> Void)?) {
        self.networkManager.async(url: "\(pi2URL)/station/\(cmd)", method: "PUT", header: nil, body: nil, callback: callback)
    }
}

struct ComponentPrinterStation_Previews: PreviewProvider {
    static var previews: some View {
        ComponentPrinterStation()
    }
}
