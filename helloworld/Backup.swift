//
//  WineChatView.swift
//  helloworld
//
//  Created by Alan Ramalho on 06/02/24.
//

import SwiftUI
import Foundation

struct Backup: View {
    // Estados para armazenar o texto da pergunta, texto da resposta e tokens de API
    @State private var questionText = ""
    @State private var questionText2 = ""
    @State private var responseText = ""
    @State private var apiToken = "sec_aFa3xj6hldU72HH2DJyqO7EHTuAsyQxp"
    @State private var sourceId = "src_Z9rHh9Pl87k3HiITJ8qOR"
    
    var body: some View {
        VStack {
            // Texto da resposta e da pergunta exibido como um chat
            ScrollView {
                VStack {
                    
                    // Pergunta
                    if !questionText2.isEmpty {
                        Text(questionText2)
                            .padding(10)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .multilineTextAlignment(.trailing)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Resposta
                    if !responseText.isEmpty {
                        Text(responseText)
                            .padding(10)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    
                }
                .padding(.top, 10)
            }
            
            // Campo de entrada de texto para a pergunta
            HStack {
                TextField("Seja bem influenciado...", text: $questionText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendQuestion) {
                    Image(systemName: "paperplane.fill") // Ícone de enviar
                        .foregroundColor(.purple)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(
            Image("wine") // Imagem de fundo
                .resizable()
                .aspectRatio(contentMode: .fill) // Preencher o espaço disponível
                .opacity(0.1) // Opacidade reduzida
        )
    }

    // Função para enviar a pergunta
    func sendQuestion() {
        print("Mensagem enviada: \(questionText)")
        questionText2 = questionText
        responseText = "Carregando..." // Exibindo mensagem de carregamento enquanto espera pela resposta
        
        // Chamando a função para fazer a solicitação de API
        makeGetRequest(question: "\(questionText)") { result in
            switch result {
            case .success(let json):
                print("JSON recebido:", json)
                do {
                    // Tentativa de obter o conteúdo da resposta da API
                    if let content = json["content"] as? String {
                        responseText = content
                        print("Conteúdo:", content)
                    } else {
                        print("O conteúdo não foi encontrado no JSON.")
                    }
                }
                catch {
                    print("Erro ao decodificar JSON:", error)
                }
            case .failure(let error):
                print("Erro ao fazer a solicitação:", error)
                // Lide com o erro de acordo com sua lógica de negócios
            }
        }

        questionText = "" // Limpar o campo de texto da pergunta após enviar
    }
    
    // Função para fazer a solicitação de API
    func makeGetRequest(question: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "https://api.chatpdf.com/v1/chats/message") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiToken, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "sourceId": sourceId,
            "messages": [
                [
                    "role": "user",
                    "content": "Me responda como se fosse um sommelier de vinhos, bem educado e seja breve. \(question)"
                ]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Erro ao converter os dados para JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Erro: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...209).contains(httpResponse.statusCode) else {
                print("Resposta inválida do servidor")
                let invalidResponseError = NSError(domain: "ServerResponseError", code: 0, userInfo: nil)
                completion(.failure(invalidResponseError))
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(.success(json))
                    }
                } catch {
                    print("Erro ao fazer parsing do JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

