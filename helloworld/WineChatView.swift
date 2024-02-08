//
//  WineChatView.swift
//  helloworld
//
//  Created by Alan Ramalho on 06/02/24.
//

import SwiftUI
import Foundation


struct WineChatView: View {
    @State private var questionText = ""
    @State private var responseText = ""
    
    var body: some View {
        VStack {

            Spacer()
            Text(responseText)
            
            Spacer()
            TextField("Seja bem influênciado...", text: $questionText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                //.background(Color.gray.opacity(0.2))
                .overlay(
                    Button(action: sendQuestion) {
                        Text(Image(systemName: "wineglass"))
                            .padding()
                            .foregroundColor(.purple)
                            //.background(Color.gray.opacity(0))
                            .cornerRadius(10)
                            .padding(.trailing, 8)
                    }
                        .padding(.trailing, 8)
                    ,alignment: .trailing
                )
        }
        .padding()
        .background(
            Image("wine")
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
        )
    }

    func sendQuestion() {
        print("Mensagem enviada: \(questionText)")
        //responseText = questionText
        makeGetRequest(question: "\(questionText)")
        questionText = ""
    }
    
    func makeGetRequest(question: String) {
        guard let url = URL(string: "https://cep.awesomeapi.com.br/json/\(question)") else {
            print("URL invalida")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) {
            (data, response, error) in
            
            if let error = error {
                print("Erro: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...209).contains(httpResponse.statusCode) else {
                print("Resposta invalida do servidor")
                return
            }
            
            if let data = data {
                responseText = "\(data)"
                print("Dados recebidos \(data)")
            }
            
        }
        task.resume()
    }


    
}

#Preview {
    WineChatView()
}
