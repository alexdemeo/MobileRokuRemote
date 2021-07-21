//
//  SwiftUIView.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 12/1/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI


func schedTimeFor(_ time: String, calendar: Calendar) -> Date {
    var comps = DateComponents()
    let parts = time.split(separator: ":").map{ Int($0) }
    comps.hour = parts[0]
    comps.minute = parts[1]
    return calendar.date(from: comps)!
}

struct ComponentCoffee: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var networkManager: NetworkManager
    
    @State var status: String = "🟡"
    @State var schedTime: Date = AppDelegate.instance.settings.coffeeDefaultSchedTime
    @State var timeSeconds: Int = -1
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isActive = true
    
    func sendRefreshRequest() {
        self.networkManager.async(url: "\(pi3URL)/coffee/status", method: "GET", header: nil, body: nil, callback: {
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
    
    func updateOn() {
        self.command(cmd: "on") { data, response, error in
            if let code = response?.statusCode, code == 201 {
                self.status = "🟢"
                self.scheduleHeatNotification()
                self.timeSeconds = 0
            }
        }
    }
    
    func updateOff() {
        self.command(cmd: "off") { data, response, error in
            if let code = response?.statusCode, code == 201 {
                self.status = "🔴"
                self.timeSeconds = -1
            }
        }
    }
    
    
    func command(cmd: String, callback: ((Data?,  HTTPURLResponse?, Error?) -> Void)?) {
        self.networkManager.async(url: "\(pi3URL)/coffee/\(cmd)", method: "PUT", header: nil, body: nil, callback: callback)
    }
    
    func scheduleHeatNotification() {
        let minutes = self.settings.coffeeNotificationDelayMinutesDouble
        let content = UNMutableNotificationContent()
        let seconds = minutes * 60
        content.title = timeStr(Int(seconds))
        content.body = "Since the coffee machine was turned on"
        print("schedule: \(content.title)")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    var body: some View {
        let time = Calendar.current.dateComponents([.hour, .minute], from: self.settings.coffeeDefaultSchedTime)
        
        return VStack(alignment: .center, spacing: 20) {
//            if self.timeSeconds >= 0 {
//                Text(self.timeStr(self.timeSeconds))
//            }
            Text("Coffee machine").bold()
            HStack(alignment: .center) {
                Text(self.status)
                    .padding(.trailing, 45)
                Button("↻", action: self.sendRefreshRequest)
                Spacer()
                Button("⏽", action: self.updateOn)
                Button("⭘", action: self.updateOff).padding(.leading, 60)
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
 
        }.padding(.all).frame(width: Constants.REMOTE_WIDTH / 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .onReceive(timer) { time in
            if self.timeSeconds >= 0 {
                self.timeSeconds += 1
            }
        }
    }
    
    func secondsBreakdown(_ s: Int) -> (Int, Int, Int) {
        return (s / 3600, (s % 3600) / 60, (s % 3600) % 60)
    }

    func timeStr(_ s: Int) -> String {
        let (h, m, s) = secondsBreakdown(s)
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct ComponentCoffee_Previews: PreviewProvider {
    static var previews: some View {
        ComponentCoffee()
            .environmentObject(AppDelegate.instance.networkManager)
            .environmentObject(AppDelegate.instance.settings)
            .buttonStyle(BorderlessButtonStyle())
    }
}
