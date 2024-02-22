import Foundation
import SwiftUI

struct Message {
  var question: String
  var response: String
}

struct WineChatView: View {
  @State private var questionText = ""
  @State private var messages: [Message] = []  // Array para armazenar as mensagens
  @State private var isSendingQuestion = false  // Flag para indicar se está enviando uma pergunta

  var body: some View {
    VStack {
      ScrollView {
        VStack {
          ForEach(messages.indices, id: \.self) { index in
            MessageView(message: messages[index])
          }
        }
        .padding(.top, 10)
      }

      HStack {
        TextField("Faça uma pergunta...", text: $questionText)
          .foregroundColor(.white)
          .border(Color.purple)
          .textFieldStyle(RoundedBorderTextFieldStyle())

        Button(action: sendQuestion) {
          if isSendingQuestion {
            ProgressView()  // Indicador de atividade durante o envio
          } else {
            Image(systemName: "paperplane.fill")
              .foregroundColor(.purple)
              .padding(.horizontal)
          }
          
        }
      }
      .padding()
    }
    .background(
      Image("wine")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .opacity(0.1)
    )
  }

  func sendQuestion() {
    let newQuestion = Message(question: questionText, response: "")
    isSendingQuestion = true
    messages.append(newQuestion)

    makeGetRequest(question: questionText) { result in
      switch result {
      case .success(let json):
        print("JSON recebido:", json)
        do {
          if let content = json["content"] as? String {
            messages[messages.count - 1].response = content  // Atualiza a resposta da mensagem
            isSendingQuestion = false
            print("Conteúdo:", content)
          } else {
            print("O conteúdo não foi encontrado no JSON.")
          }
        } catch {
          print("Erro ao decodificar JSON:", error)
        }
      case .failure(let error):
        print("Erro ao fazer a solicitação:", error)
      }
    }

    questionText = ""
    hideKeyboard()
  }

  func hideKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }

  func makeGetRequest(
    question: String, completion: @escaping (Result<[String: Any], Error>) -> Void
  ) {
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
          "content":
            "Me responda como se fosse um sommelier de vinhos, bem educado e seja breve. responda as proxímas perguntas baseada na primeira, a não ser que a pessoa refaça a questão. \(question)",
        ]
      ],
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
        (200...209).contains(httpResponse.statusCode)
      else {
        print("Resposta inválida do servidor")
        let invalidResponseError = NSError(domain: "ServerResponseError", code: 0, userInfo: nil)
        completion(.failure(invalidResponseError))
        return
      }

      if let data = data {
        do {
          if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          {
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

struct MessageView: View {
  var message: Message

  var body: some View {
    VStack {
      if !message.question.isEmpty {
        Text(message.question)
          .padding(10)
          .background(Color.gray)
          .foregroundColor(.black)
          .cornerRadius(10)
          .multilineTextAlignment(.trailing)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .fixedSize(horizontal: false, vertical: true)
      }

      if !message.response.isEmpty {
        Text(message.response)
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
  }
}

// Aqui estão as variáveis ​​globais para o token da API e o ID da fonte
let apiToken = "sec_aFa3xj6hldU72HH2DJyqO7EHTuAsyQxp"
let sourceId = "src_Z9rHh9Pl87k3HiITJ8qOR"

