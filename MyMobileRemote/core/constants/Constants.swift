//
//  Constants.swift
//  MyRemote
//
//  Created by Alex DeMeo on 6/25/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import CoreGraphics


//{
//  "Left" : "Left",
//  "Right": "Right",
//  "Up" : "Up",
//  "Down": "Down",
//
//  "Select":"Return",
//  "Power" : "/",
//  "Backspace" : "Backspace",
//  "Back" : "`",
//
//  "Play" : "Tab",
//  "Rev" : ",",
//  "Fwd" : ".",
//  "Info" : "\\",
//
//  "VolumeUp" : "=",
//  "VolumeDown" : "-",
//  "VolumeMute" : "0",
//  "Home" : "Esc"
//}


struct Constants {
    /**************** Defined constants ******************/
    
    static let WINDOW_WIDTH: CGFloat                = 540 * 2//340 * 2
    static let WINDOW_HEIGHT: CGFloat               = 720
    
    static let ROWS: Int                            = 17
    static let COLS: Int                            = 3
    
    static let PADDING_EDGE_BUTTON: CGFloat         = 75
    
    static let DEFAULT_KEYBINDS_ROKU                = [
                                                            "leftArrow"     : Buttons.Roku.LEFT,
                                                            "rightArrow"    : Buttons.Roku.RIGHT,
                                                            "upArrow"       : Buttons.Roku.UP,
                                                            "downArrow"     : Buttons.Roku.DOWN,
                                                            
                                                            "returnKey"     : Buttons.Roku.OK,
                                                            "/"             : Buttons.Roku.POWER,
                                                    //        "backspace"     : Buttons.Roku.?
                                                            "`"             : Buttons.Roku.BACK,
                                                            
                                                            "tab"           : Buttons.Roku.PLAY_PLAUSE,
                                                            ","             : Buttons.Roku.REWIND,
                                                            "."             : Buttons.Roku.FORWARD,
                                                            "\\"            : Buttons.Roku.ASTERISK,
                                                            
                                                            "="             : Buttons.Roku.VOLUME_UP,
                                                            "-"             : Buttons.Roku.VOLUME_DOWN
                                                    //        "0"             : Buttons.Roku.MUTE,
                                                    //        "escape"        : Buttons.Roku.?
                                                    ]
    
    static let VOL_MAX = 100
    
    static let DEFAULT_SETTINGS: Settings           = Settings(ipRoku: "",
                                                               volButtons: true,
                                                               remotes: [
                                                                RemoteData(title: "Roku", enabled: true),
                                                                RemoteData(title: "Home", enabled: true)
                                                               ])
    
    static let ROKU_APP_QUERY_TIMEOUT_SECONDS: Int  = 5
        
    /**************** Inferred constants ******************/
    
    static let REMOTE_WIDTH: CGFloat                = WINDOW_WIDTH / 2.0                                    // 380
    static let REMOTE_HEIGHT: CGFloat               = WINDOW_HEIGHT                                         // 640
    
    static let CELL_WIDTH: CGFloat                  = Constants.REMOTE_WIDTH / CGFloat(Constants.COLS)      // 127
    static let CELL_HEIGHT: CGFloat                 = Constants.REMOTE_HEIGHT / CGFloat(Constants.ROWS)     // 37.5
    
    static let OFFSET_EDGE_BUTTON: CGFloat          = CELL_WIDTH - PADDING_EDGE_BUTTON                      // 100

    static let SPACING_VERTICAL: CGFloat            = CELL_HEIGHT / 2                                       //  

    static let REMOTE_CENTER_GAP_WIDTH: CGFloat     = CELL_WIDTH / 2
}


