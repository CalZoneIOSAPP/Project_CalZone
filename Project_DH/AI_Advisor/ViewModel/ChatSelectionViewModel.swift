//
//  ChatSelectionViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import OpenAI


class ChatSelectionViewModel: ObservableObject {
    
    @Published var chats: [AppChat] = []
    @Published var loadingState: ChatListState = .none
    @Published var showEditWindow = false
    
    // Current Chat Info
    @Published var curTitle = ""
    @Published var curID = ""
    
    private let db = Firestore.firestore()
    
    
    /// This function fetches all chats which belong to the user.
    /// - Parameters:
    ///     - user: the user that the function's search is based on
    /// - Returns: none
    @MainActor
    func fetchData(user: String?) async {
        guard loadingState == .none else { return }

        loadingState = .loading

        do {
            let querySnapshot = try await db.collection(Collection().chats)
                .whereField("owner", isEqualTo: user ?? "")
                .getDocuments()

            let documents = querySnapshot.documents
            if documents.isEmpty {
                loadingState = .noResults
                return
            }

            chats = documents.compactMap { snapshot -> AppChat? in
                return try? snapshot.data(as: AppChat.self)
            }
            .sorted(by: { $0.lastMessageSent > $1.lastMessageSent })

            loadingState = .resultsFound
        } catch {
            print("ERROR: Error fetching chats: \(error.localizedDescription)")
            loadingState = .noResults
        }
    }

    
    /// This function creates a new chat and saves it to the Firebase.
    /// - Parameters:
    ///     - user: The user which the chat is saved to.
    /// - Returns: The document id where the chat is saved to.
    @MainActor
    func createChat(user: String?) async throws -> String {
        let chatData: [String: Any] = [
            "lastMessageSent": Date(),
            "owner": user ?? ""
        ]
        
        let document = try await db.collection(Collection().chats).addDocument(data: chatData)
        
        // Create a new AppChat object manually and append it to the chats array
        let newChat = AppChat(id: document.documentID, topic: nil,
                              lastMessageSent: FirestoreDate(),
                              owner: user ?? "")

        chats.append(newChat)
        
        // Sort the chats array after adding the new chat
        chats.sort(by: { $0.lastMessageSent > $1.lastMessageSent })

        loadingState = .resultsFound

        return document.documentID
    }
    
    
    /// This function deletes the selected chat.
    /// - Parameters:
    ///     - chat: The chat to delete.
    /// - Returns: none
    func deleteChat(chat: AppChat) {
        guard let id = chat.id else {return}
        db.collection(Collection().chats).document(id).delete()
    }
    
    
    @MainActor
    func deleteChat(chat: AppChat) async {
        guard let id = chat.id else { return }

        do {
            // Delete the chat document from Firestore
            try await db.collection(Collection().chats).document(id).delete()

            // Remove the chat from the local array
            if let index = chats.firstIndex(where: { $0.id == id }) {
                chats.remove(at: index)
            }

            // Handle case when no more chats are available
            if chats.isEmpty {
                loadingState = .noResults
            }
        } catch {
            print("ERROR: Error deleting chat: \(error.localizedDescription)")
        }
    }
    
    /// This function uploads the chat title to Firebase.
    /// - Parameters:
    ///     - chatId: The chat which the user wants to change the title for.
    /// - Returns: none
    func uploadChatTitle(chatId: String) {
        db.collection(Collection().chats).document(chatId).updateData(["topic": curTitle])
    }
    
    
}


/// The states of the chat list.
enum ChatListState {
    case none
    case loading
    case noResults
    case resultsFound
}


/// The Chat Structure.
struct AppChat: Codable, Identifiable {
    @DocumentID var id: String?
    let topic: String?
    var model: ChatModel?
    let lastMessageSent: FirestoreDate
    let owner: String
    
    /// The time when last message was sent or received.
    var lastMessageTimeAgo: String {
        let now = Date()
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: lastMessageSent.date, to: now)
        
        let timeUnits: [(value: Int?, unit: String)] = [
            (components.year, NSLocalizedString("year", comment: "")),
            (components.month, NSLocalizedString("month", comment: "")),
            (components.day, NSLocalizedString("day", comment: "")),
            (components.hour, NSLocalizedString("hour", comment: "")),
            (components.minute, NSLocalizedString("minute", comment: "")),
            (components.second, NSLocalizedString("second", comment: ""))
        ]
        
        for timeUnit in timeUnits {
            if let value = timeUnit.value, value > 0 {
                return "\(value) \(timeUnit.unit) " + NSLocalizedString("ago", comment: "")
            }
        }
        
        return NSLocalizedString("just now", comment: "")
        
    }
}


/// The chat id structure.
struct ChatID: Identifiable {
    let id: String
    var ident: String { id }
}


/// Returns the SwiftUI Color depending on the model selected
enum ChatModel: String, Codable, CaseIterable, Hashable {
    case gpt3_5_turbo = "GPT 3.5 Turbo"
    case gpt4 = "GPT 4"
    case gpt4_o = "GPT 4o"
    
    /// The text color for corresponding model name.
    var tintColor: Color {
        switch self {
        case .gpt3_5_turbo:
            return .green
        case .gpt4:
            return .purple
        case .gpt4_o:
            return .blue
        }
    }
    
    
    /// Returns the model which will be used as a parameter value for OpenAI api call
    var model: Model {
        switch self {
        case .gpt3_5_turbo:
            return .gpt3_5Turbo
        case .gpt4:
            return .gpt4
        case .gpt4_o:
            return .gpt4_o
        }
    }
}


/// The date format which is accepted by Firebase Firestore.
struct FirestoreDate: Codable, Hashable, Comparable {
    
    var date: Date
    
    
    init(_ date: Date = Date()) {
        self.date = date
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let timestamp = try container.decode(Timestamp.self)
        date = timestamp.dateValue()
    }
    
    
    /// This function customizes how an instance of a type is encoded into an external representation.
    /// - Parameters:
    ///     - encoder: The encoder which we want to encode the struct.
    /// - Returns: none
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let timestamp = Timestamp(date: date)
        try container.encode(timestamp)
    }
    
    
    /// Compare two FirestoreDate instances by checking if their id properties are the same
    /// - Parameters:
    ///     - lhs: The id of firestore date 1.
    ///     - rhs: The id of firestore date 2.
    /// - Returns:
    ///     - if the two ids are the same.
    static func < (lhs: FirestoreDate, rhs: FirestoreDate) -> Bool {
        lhs.date < rhs.date
    }
    
    
    
}

