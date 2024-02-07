//
//  ContentView.swift
//  helloworld
//
//  Created by Alan Ramalho on 05/02/24.
//

import SwiftUI

var titulo = Text("Seja bem-vindo! 🍷");

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("\(titulo)")
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            
        }
        .padding()
        .background(
            Image("wine")
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
        )
    }
}

#Preview {
    ContentView()
}
