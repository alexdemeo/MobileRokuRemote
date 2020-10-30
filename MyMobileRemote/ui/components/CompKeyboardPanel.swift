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
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .roundedRect
        textField.keyboardType = self.keyboardType
        textField.delegate = context.coordinator
        textField.placeholder = "Type:"
        textField.textAlignment = .center
        _ = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField)
            .compactMap {
                guard let field = $0.object as? UITextField else {
                    return ""
                }
                return field.text
            }
            .sink {
                self.text = $0
            }
        
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
//            let hash = String(describing: string.first?.hexDigitValue)
//            print("range=\(range) string=0x\(hash)")
            self.onKey(textField, key: string)
            if string.isEmpty {
                self.onKey(textField, key: "backspace")
            } else if string == "\n" {
                textField.text = nil
                textField.resignFirstResponder()
            } else {
//                textField.text = nil
            }
            return true
        }
        
        func onKey(_ textField: UITextField, key: String) {
//            if key == "\n" {
//                print("onKey(\(key))")
//            } else {
//                print("onKey(return)")
//            }
            let allowedKeys = "abcdefghijklmnopqrstuvwxyzABCDEFHIJKLMNOPQRSTUVWXYZ1234567890"
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
    @State var text = ""
    
    var body: some View {
        AnyView(ListeningTextField(keyboardType: .default, text: $text))
    }
}

struct CompKeyboardPanel_Previews: PreviewProvider {
    static var previews: some View {
        ComponentKeyboardPanel()
    }
}
