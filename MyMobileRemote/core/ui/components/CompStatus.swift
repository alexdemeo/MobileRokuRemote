//
//  ComponentStatus.swift
//  MyRemote
//
//  Created by Alex DeMeo on 7/8/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ComponentStatus: View {
    var command: String
    var msg: String?
    var success: Bool
    var statusCode: Int
    
    var body: some View {
        var str = self.command
        if !self.success {
            str += ": \(self.msg ?? "unknown")" // theoretically if success is false then msg has to be non-null...
        }
        return VStack {
            HStack {
                if self.statusCode != -1 {
                    Text("\(self.statusCode)")
                }
                Circle().fill(self.success && self.statusCode != -1 ? Color.green : Color.red).frame(width: 25, height: 25)
                if !command.isEmpty {
                    Text(str)
                }
            }
        }
    }
}

struct ComponentStatus_Previews: PreviewProvider {
    static var previews: some View {
        ComponentStatus(command: "/keypress/volumeup", msg: nil, success: true, statusCode: 200)
    }
}
