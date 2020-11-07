//
//  Buttons.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/29/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import Foundation

struct Buttons {
    struct Roku {
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
        
        static let DEV_AVR          = RemoteButton(forType: .roku, symbol: "AVR", endpoint: .keypress, command: "InputHDMI1")
        static let DEV_PI2          = RemoteButton(forType: .roku, symbol: "pi2", endpoint: .keypress, command: "InputHDMI2")
        static let DEV_PC           = RemoteButton(forType: .roku, symbol: "PC", endpoint: .keypress, command: "InputHDMI3")
        
        static let CHAN_NETFLIX     = RemoteButton(forType: .roku, symbol: "Netflix", endpoint: .launch, command: "12")
        static let CHAN_HULU        = RemoteButton(forType: .roku, symbol: "Hulu", endpoint: .launch, command: "2285")
        static let CHAN_YOUTUBE     = RemoteButton(forType: .roku, symbol: "YouTube", endpoint: .launch, command: "837")
        static let CHAN_SPOTIFY     = RemoteButton(forType: .roku, symbol: "Spotify", endpoint: .launch, command: "19977")
    }
}
