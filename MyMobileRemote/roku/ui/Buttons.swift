//
//  Buttons.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/29/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import Foundation

struct Buttons {
    static let POWER            = RemoteButton(forType: .roku, symbol: "⏻", endpoint: .keypress, command: "Power")
    static let MUTE             = RemoteButton(forType: .roku, symbol: "⁌", endpoint: .keypress, command: "VolumeMute")
    static let VOLUME_DOWN      = RemoteButton(forType: .roku, symbol: "−", endpoint: .keypress, command: "VolumeDown")
    static let VOLUME_UP        = RemoteButton(forType: .roku, symbol: "＋", endpoint: .keypress, command: "VolumeUp")
    static let DOWN             = RemoteButton(forType: .roku, symbol: "↓", endpoint: .keypress, command: "Down")
    static let UP               = RemoteButton(forType: .roku, symbol: "↑", endpoint: .keypress, command: "Up")
    static let LEFT             = RemoteButton(forType: .roku, symbol: "←", endpoint: .keypress, command: "Left")
    static let RIGHT            = RemoteButton(forType: .roku, symbol: "→", endpoint: .keypress, command: "Right")
    static let OK               = RemoteButton(forType: .roku, symbol: "OK", endpoint: .keypress, command: "Select")
    static let BACK             = RemoteButton(forType: .roku, symbol: "↲", endpoint: .keypress, command: "Back")
    static let HOME             = RemoteButton(forType: .roku, symbol: "⌂", endpoint: .keypress, command: "Home")
    static let REFRESH          = RemoteButton(forType: .roku, symbol: "↻", endpoint: .keypress, command: "InstalReplay")
    static let DO_NOT_DISTURB   = RemoteButton(forType: .roku, symbol: "☽", endpoint: .keypress, command: "?")
    static let ASTERISK         = RemoteButton(forType: .roku, symbol: "✱", endpoint: .keypress, command: "Info")
    static let REWIND           = RemoteButton(forType: .roku, symbol: "⦉⦉", endpoint: .keypress, command: "Rev")
    static let PLAY_PLAUSE      = RemoteButton(forType: .roku, symbol: "▻⫾⫾", endpoint: .keypress, command: "Play")
    static let FORWARD          = RemoteButton(forType: .roku, symbol: "⦊⦊", endpoint: .keypress, command: "Fwd")
}
