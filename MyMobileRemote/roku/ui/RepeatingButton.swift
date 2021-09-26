//
//  RepeatingButton.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 9/25/21.
//  Copyright © 2021 Alex DeMeo. All rights reserved.
//

import SwiftUI

let REPEAT_DELAY_SECONDS = 0.2
let LONG_PRESS_REPEAT_DELAY_SECONDS = 0.75

struct RepeatingButton: View {
    @State var timer: Timer?
    
    private var action: () -> Void
    @ViewBuilder private var label: () -> Text
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Text) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(action: {
            self.action()
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
        }, label: self.label)
        .simultaneousGesture(LongPressGesture(minimumDuration: LONG_PRESS_REPEAT_DELAY_SECONDS).onChanged { _ in
            timer = Timer.scheduledTimer(withTimeInterval: REPEAT_DELAY_SECONDS, repeats: true, block: { _ in
                self.action()
            })
        })
    }
}

struct RepeatingButton_Previews: PreviewProvider {
    static var previews: some View {
        RepeatingButton(action: {} ){ Text("") }
    }
}
