//
//  ChatViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import Foundation
import OpenAI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var chat: AppChat?
    @Published var messages: [AppMessage] = []
    @Published var messageText: String = ""
    @Published var selectedModel: ChatModel = .gpt3_5_turbo
    @Published var scrollToBottom = false
    @Published var calories: String?
    
    let chatId: String
    let db = Firestore.firestore()
    
    init(chatId: String) {
        self.chatId = chatId
    }
    
    // Get OpenAI API Key from config.plist (in gitignore)
    func loadConfig() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
            return config
        }
        return nil
    }
    
    
    func fetchData() {
        db.collection(Collection().chats).document(chatId).getDocument(as: AppChat.self) { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.chat = success
                }
            case .failure(let failure):
                print(failure)
            }
        }

        db.collection(Collection().chats).document(chatId).collection(Document().message).order(by: "createdAt").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, !documents.isEmpty else { return }
            
            self.messages = documents.compactMap({snapshot -> AppMessage? in
                do {
                    var message = try snapshot.data(as: AppMessage.self)
                    message.id = snapshot.documentID
                    self.scrollToBottom = true
                    print(1)
                    return message
                } catch {
                   return nil
                }
            })
        }
        
    }
    
    
    func sendMessage() async throws{
        var newMessage = AppMessage(id: UUID().uuidString, text: messageText, role: .user)
        
        do {
            let documentRef = try storeMessage(message: newMessage)
            newMessage.id = documentRef.documentID
        } catch {
            print(error.localizedDescription)
        }
        
        if messages.isEmpty {
            setupNewChat()
        } else {
            // do nothing at this point
        }
        
        await MainActor.run { [newMessage] in
            messages.append(newMessage)
            messageText = ""
        }
        
        try await generateResponse(for: newMessage)
    }
    
    
    private func storeMessage(message: AppMessage) throws -> DocumentReference {
        return try db.collection(Collection().chats).document(chatId).collection(Document().message).addDocument(from: message)
    }
    
    
    private func setupNewChat() {
        db.collection(Collection().chats).document(chatId).updateData([DataConst().model: selectedModel.rawValue])
        DispatchQueue.main.async { [weak self] in
            self?.chat?.model = self?.selectedModel
        }
    }
    
    
    func generateResponse(for message: AppMessage) async throws{
        guard let config = loadConfig(),
              let apiKey = config["OpenAI_API_KEY"] as? String else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }
        let openAI = OpenAI(apiToken: apiKey)
        // This gets the context of past messages by the user and GPT
        // FUTURE IMPROVEMENTS: Maybe limit the number of past messages to use as context query
        let queryMessages = messages.map { appMessage in
            ChatQuery.ChatCompletionMessageParam(role: appMessage.role, content: appMessage.text)!
        }
        // input text for the OpenAI model
        let query = ChatQuery(messages: queryMessages, model: chat?.model?.model ?? .gpt3_5Turbo)
        for try await result in openAI.chatsStream(query: query) {
            guard let newText = result.choices.first?.delta.content else { continue }
            await MainActor.run {
                if let lastMessage = messages.last, lastMessage.role != .user {
                    messages[messages.count-1].text += newText
                } else {
                    let newMessage = AppMessage(id: result.id, text: newText, role: .assistant)
                    messages.append(newMessage)
                }
            }
        }
        if let lastMessage = messages.last {
            _ = try storeMessage(message: lastMessage)
        }
    }
    
    
    // OpenAI API call for generating output based on image/text input
    // TODO: Camera-GPT-Input Implementation, refer to notion task
    func generateCalories(for image: UIImage) async throws{
        // Get API Key
        guard let config = loadConfig(),
              let apiKey = config["OpenAI_API_KEY"] as? String else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])
        }
        let openAI = OpenAI(apiToken: apiKey)
        
        
        var img_messages: [ChatQuery.ChatCompletionMessageParam] = [
            .user(.init(content: .string("Please calculate the calories of the provided image. Please only give me the calorie format in the number of calories without textual explanation."))),
            .user(.init(content: .string("Give me the calorie format in the number of calories without textual explanation.")))
        ]
        
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
                    let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: .vision([.chatCompletionContentPartImageParam(.init(imageUrl: .init(url: imageData, detail: .high)))]))
                    img_messages.append(.user(imgParam))
                }
        
        let query = ChatQuery(messages: img_messages, model: .gpt4_o)
        
        for try await result in openAI.chatsStream(query: query) {
            guard let newText = result.choices.first?.delta.content else { continue }
            await MainActor.run {
                self.calories = newText
            }
        }
    }
    
    
}


// This is the struct of an message for GPT query
struct AppMessage: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var text: String
    let role: ChatQuery.ChatCompletionMessageParam.Role
    var createdAt: FirestoreDate = FirestoreDate()
}

