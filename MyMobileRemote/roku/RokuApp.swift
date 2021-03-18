//
//  RokuApp.swift
//  MyRemote
//
//  Created by Alex DeMeo on 7/8/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI


struct SingleDeviceView: View {
    @EnvironmentObject var observedRokuButtons: ObservedRokuButtons
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var settings: Settings
    
    let app: RokuApp
    let imgData: Data?
    let labeled: Bool
    init(app: RokuApp, imgData: Data?, labeled: Bool) {
        self.labeled = labeled
        self.imgData = imgData
        self.app = app
    }
    
    init(app: RokuApp, imgData: Data?) {
        self.init(app: app, imgData: imgData, labeled: false)
    }
    
    var imgView: AnyView {
        AnyView(Image(uiImage: UIImage(data: self.imgData!)!)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.CELL_WIDTH, height: Constants.CELL_HEIGHT)
            .scaleEffect(2))
    }
    
    var body: some View {
        if self.imgData == nil {
            return AnyView(Text("Error"))
        } else if labeled {
            return AnyView(VStack(spacing: -4) {
                self.imgView
                Text(self.app.name)
            })
        } else {
            return self.imgView
        }
    }
}

class RokuApp {
    let id: String
    let type: String
    let version: String
    let name: String
    
    init(line: String) {
        let parts = line.replacingOccurrences(of: "\"", with: "").split(separator: " ")
        self.id = String(parts[1].split(separator: "=")[1])
        self.type = String(parts[2].split(separator: "=")[1])
        self.version = String(parts[3].split(separator: "=")[1].split(separator: ">")[0])
        var name = line
        name.removeSubrange(name.startIndex...name.firstIndex(of: ">")!)
        name.removeSubrange(name.firstIndex(of: "<")!..<name.endIndex)
        self.name = String(name)
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

struct RokuApp_Previews: PreviewProvider {
    static var previews: some View {
        ComponentRokuDevices()
            .environmentObject(AppDelegate.instance.rokuChannelButtons)
    }
}
