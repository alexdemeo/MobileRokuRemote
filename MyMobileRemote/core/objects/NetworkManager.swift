//
//  NetworkManager.swift
//  MyRemote
//
//  Created by Alex DeMeo on 10/29/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

class NetworkManager: ObservableObject {
    @ObservedObject var latestRequest: Request = Request()
    @ObservedObject var latestResponse: Response = Response()
    
    private static var instance: NetworkManager? = nil
    
    static var shared: NetworkManager {
        if instance == nil {
            instance = NetworkManager()
        }
        return instance!
    }
    
    public func async(url: String, method: String, header: [String: String]?, body: [String: String]?, callback: ((Data?,  HTTPURLResponse?, Error?) -> Void)?) {
        print("async(url: \(url), method: \(method), header: \(String(describing: header)), body: \(String(describing: body))")
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = method
        if let bodyParams = body {
            if method == "GET" {
                print("Error: supplied body for HTTP GET")
                return
            }
            var components = URLComponents()
            components.queryItems = bodyParams.map {
                URLQueryItem(name: $0, value: $1)
            }
            req.httpBody = components.query?.data(using: .utf8)
        }
        if let h = header {
            req.allHTTPHeaderFields = h
        }
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            DispatchQueue.main.async {
                self.latestRequest.request = req // this is here so status update changes on reply
                self.latestResponse.data = data
                self.latestResponse.response = response as? HTTPURLResponse
                self.latestResponse.error = error
                guard let endpoint = NetworkManager.sanitizeURL(url: url) else {
                    return
                }
                guard let response = self.latestResponse.response else {
                    return
                }
                if let error = error {
                    print("Error: async callback \(error.localizedDescription)")
                }
//                if let data = data {
//                    print("Result from: \(url) statusCode: \(self.latestResponse.response?.statusCode ?? -1), data=\(String(data: data, encoding: .utf8) ?? "none")")
//                }
                if let c = callback {
                    c(data, response, error)
                } else {
                    self.handleAsyncRokuResponseFrom(endpoint: endpoint, withResponse: response) // ik this is bad programming, currently too lazy to fix it
                }
            }
        }
        task.resume()
    }
    
    public func sync(url: String, method: String) -> (Data?, HTTPURLResponse?, Error?)? {
        let s = DispatchSemaphore(value: 0)
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = method
        var result: (Data?, HTTPURLResponse?, Error?) = (nil, nil, nil)
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            result = (data, response as? HTTPURLResponse, error)
            s.signal()
        }
        task.resume()
        let waitResult = s.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(Constants.ROKU_APP_QUERY_TIMEOUT_SECONDS))
        return waitResult == .success ? result : nil
    }
    
    
    
    private func handleAsyncRokuResponseFrom(endpoint e: String, withResponse response: HTTPURLResponse) {
        print("Result from endpoint: \(e) statusCode: \(self.latestResponse.response?.statusCode ?? -1)")

        if !e.matches(for: "^(?i)\\/(keypress)?\\/?volume\\/?(up|down)$").isEmpty
            && response.statusCode == 200 {
            // if it's a volume endpoint
            if e.lowercased().contains("up") {
            } else if e.lowercased().contains("down") {
            } else if e.lowercased().contains("Lit_") {
                let char = e.split(separator: "_")[1]
                AppDelegate.instance.updateTextFieldFor(character: String(char))
            }
        } else if !e.matches(for: "^/query/apps$").isEmpty {
            var apps: [RokuApp] = []
            if let data = self.latestResponse.data {
                let info = String(data: data, encoding: .utf8)
                apps = info!.matches(for: "<app.*<\\/app>").map({
                    RokuApp(line: $0)
                })
            }
            print("Made buttons for apps:\n\(apps.map({"\t\($0)"}).joined(separator: "\n"))")
            let buttons = apps.map({
                RemoteButton(forType: .roku, symbol: $0.name, endpoint: .launch, command: $0.id, associatedApp: $0)
            })
            AppDelegate.instance.rokuChannelButtons.updateFor(array: buttons)
        }
    }
    
    static func sanitizeURL(url: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "^http:\\/\\/([0-9]|\\.|:)*", options: .caseInsensitive) else {
            return nil
        }
        return regex.stringByReplacingMatches(in: url, options: [], range: NSRange(location: 0, length:  url.count), withTemplate: "")
    }
}
