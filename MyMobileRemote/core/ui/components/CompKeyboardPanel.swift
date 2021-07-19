//
//  CompKeyboardPanel.swift
//  MyMobileRemote
//
//  Created by Alex DeMeo on 10/5/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ListeningTextField: UIViewRepresentable {
    let keyboardType: UIKeyboardType
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = self.keyboardType
        textField.delegate = context.coordinator
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
        textField.text = " "
        _ = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ListeningTextField
        
        init(_ textField: ListeningTextField) {
            self.parent = textField
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty {
                self.onKey(textField, key: "backspace")
            } else if string == "\n" {
                textField.resignFirstResponder()
            } else {
                self.onKey(textField, key: string)
            }
            return false
        }
        
        func onKey(_ textField: UITextField, key: String) {
//            if key != "\n" {
//                print("onKey(\(key))")
//            } else {
//                print("onKey(return)")
//            }
            let allowedKeys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%,.<>/?;:'"
            if key.count == 1 && allowedKeys.contains(key) {
                RemoteButton(forType: .roku, symbol: key, endpoint: .keypress, command: "Lit_\(key)").exec()
            } else if key == " " {
                RemoteButton(forType: .roku, symbol: key, endpoint: .keypress, command: "Lit_%20").exec()
            } else if key == "backspace" {
                RemoteButton(forType: .roku, symbol: key, endpoint: .keypress, command: "Backspace").exec()
            }
        }
    }
}
struct ComponentKeyboardPanel: View {
    var body: some View {
        AnyView(ListeningTextField(keyboardType: .default))
    }
}

struct CompKeyboardPanel_Previews: PreviewProvider {
    static var previews: some View {
        ComponentKeyboardPanel()
    }
}
