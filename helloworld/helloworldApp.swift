//
//  helloworldApp.swift
//  helloworld
//
//  Created by Alan Ramalho on 05/02/24.
//

import SwiftUI

@main
struct helloworldApp: App {
    var body: some Scene {
            WindowGroup {
                TabView {
                    ContentView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    WineChatView()
                        .tabItem {
                            Label("Chat", systemImage: "wineglass")
                        }
                    
                }
            }
        }
}
