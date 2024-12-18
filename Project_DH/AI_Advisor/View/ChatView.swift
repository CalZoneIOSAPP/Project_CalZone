//
//  ChatView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import SwiftUI
import Kingfisher


struct ChatView: View {
    
    @StateObject var viewModel: ChatViewModel
    @StateObject var profileViewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private var user: User? {
        return profileViewModel.currentUser
    }
    
    var body: some View {
        VStack {
            Text(viewModel.isTyping ? "AI Advisor - Cally (Typing...)" : "AI Advisor - Cally")
                .font(.title3)
                .bold()
                .padding(.top, 15)
                .padding(.bottom, 20)
            
            // Model Selection
//            modelSelectionView
//                .padding(.bottom, 10)
            
            ScrollViewReader { scrollView in
                List(viewModel.messages) { message in
                    messageView(for: message)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .id(message.id)
                        .padding(.vertical, 5)
                        .onChange(of: viewModel.messages) { oldValue, newValue in
                            scrollToBottom(scrollView: scrollView)
                        }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .listStyle(.plain)
                .onChange(of: viewModel.scrollToBottom) { error, scroll in // When scrollToBottom variable changes to true, scroll to bottom
                    if scroll {
                        scrollToBottom(scrollView: scrollView)
                    }
                }
            }
            
            messageInputView
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.brandDarkGreen)
                    }
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.hideKeyboard()  // Dismiss the keyboard on any tap
        }
        .onAppear {
            viewModel.fetchData()
        }
        
        
        
    }// End of body view
    
    
    /// This view shows the AI model selection bar on the top.
    var modelSelectionView: some View {
        Group {
            if let model = viewModel.chat?.model?.rawValue {
                Text(model)
                    .font(.subheadline)
            } else {
                Picker(selection: $viewModel.selectedModel) {
                    ForEach(ChatModel.allCases, id: \.self) { model in
                        Text(model.rawValue)
                    }
                } label: {
                    Text("")
                }
                .pickerStyle(.segmented)
                .padding()
            }
        }
    }
    
    
    /// This view shows the user input elements, including the message enter, and message sending button.
    var messageInputView: some View {
        HStack {
            TextField("Send a message...", text: $viewModel.messageText)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onSubmit {
                    sendMessage()
                }
            Button {
                sendMessage()
            } label: {
                Text("Send")
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.brandDarkGreen)
                    .bold()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(viewModel.messageText == "" ? 0.7 : 1)
            }
            .disabled(viewModel.messageText == "")
        }
        .padding()
    }
    
    
    /// This function shows the view for displaying the messages inside the chat.
    /// - Parameters:
    ///     - for: the massage to display
    /// - Returns: the view to show
    func messageView(for message: AppMessage) -> some View {
        HStack {
            if (message.role == .user) {
                Spacer()
            }
            if (message.role == .assistant) {
                VStack {
                    Image("Logo_filled")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                    Spacer()
                }
            }
            Text(message.text)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .foregroundStyle(message.role == .user ? .white : .black)
                .background(message.role == .user ? .brandDarkGreen : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            if (message.role == .user) {
                VStack {
                    if let imageUrl = user?.profileImageUrl {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.leading, 10)
                            .padding(.top, 10)

                    } else {
                        Image(systemName: "person.crop.square")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color(.systemGray4))
                            .padding(.leading, 10)
                            .padding(.top, 10)
                            
                    }
                    Spacer()
                }
            }
            
            if (message.role == .assistant) {
                Spacer()
            }
        }
    }
    
    
    /// This function allows the selected chat to automatically scroll to the bottom once opened.
    /// - Parameters:
    ///     - scrollView: The ScrollViewProxy
    /// - Returns: none
    func scrollToBottom(scrollView: ScrollViewProxy) {
        guard !viewModel.messages.isEmpty, let lastMessage = viewModel.messages.last else {
            return
        }
        withAnimation {
            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    
    /// This function handles the user action for sending the message.
    /// - Parameters: none
    /// - Returns: none
    func sendMessage() {
        if let userId = profileViewModel.currentUser?.uid {
            Task {
                do {
                    if profileViewModel.isVIP {
                        try await viewModel.sendMessageVIP(userId: userId)
                    } else {
                        try await viewModel.sendMessage(userId: userId)
                    }
                } catch {
                    print("ERROR: Sending message in ChatView \n\(error.localizedDescription)\n")
                }
            }
        }
    }
    
}


#Preview {
    ChatView(viewModel: .init(chatId: ""))
}
