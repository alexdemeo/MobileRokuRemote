//
//  RokuApp.swift
//  MyRemote
//
//  Created by Alex DeMeo on 7/8/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct RokuApp {
    let id: String
    let type: String
    let version: String
    let name: String
    
    var viewLabelless: some View {
        if let imgData = AppDelegate.instance.netSync(url: "\(AppDelegate.instance.settings.rokuBaseURL)/query/icon/\(self.id)", method: "GET") {
            guard let resp = imgData.1 else {
                return AnyView(Text(self.name))
            }
            if resp.statusCode == 200 {
                return AnyView(Image(uiImage: UIImage(data: imgData.0!)!)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.CELL_WIDTH, height: Constants.CELL_HEIGHT)
                    .scaleEffect(2))
            }
        }
        // currently same error text if reply fails or reply has bad statusCode. Should probably separate these
        return AnyView(Text("ERROR"))
    }
    
    var viewLabeled: some View {
        VStack(spacing: -4) {
            self.viewLabelless
            Text(self.name)
        }
    }
    
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
        //        HStack {
        //            ForEach(RemoteButton.getRokuButtons()) { btn in
        //                HStack {
        //                    Button(action: btn.exec) {
        //                        btn.associatedApp!.view
        //                    }
        //                }
        //            }
        //        }
    }
}
