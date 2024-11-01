//
//  MyCoachView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import SwiftUI


struct ChatSelectionView: View {
    
    @StateObject var viewModel = ChatSelectionViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    
    @State private var selectedChatId: ChatID? = nil
    @State private var showPopup: Bool = false
    @State private var deleteChat: Bool = false
    
    @State var chatToDelete: AppChat?
    
    let genAITip = GeneralAITip()
    let addChatTip = AddChatTip()
    
    var body: some View {
        ZStack {
            NavigationStack {
                Group {
                    switch viewModel.loadingState {
                    case .loading, .none:
                        Text("Loading Chats...")
                    case .noResults:
                        VStack {
                            Text("No Chats...")
                                .font(.headline)
                                .foregroundStyle(.gray)
                                .padding(.bottom, 20)
                            Image("chatbubble")
                                .resizable()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .opacity(0.5)
                        }
                    case .resultsFound:
                        List {
                            ForEach(viewModel.chats) { chat in
                                Button(action: {
                                    selectedChatId = ChatID(id: chat.id ?? "")
                                }) {
                                    HStack {
                                        Image("Logo_filled")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                            .padding(.trailing, 10)
                                        
                                        VStack(alignment: .leading) {
                                            Text(chat.topic ?? NSLocalizedString("AI Advisor - Cally", comment: ""))
                                                .font(.headline)
                                            
                                            Text(chat.lastMessageTimeAgo)
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                        }
                                        
                                        Spacer()
                                        // Text for displaying the model name
//                                            Spacer()
//                                            Text(chat.model?.rawValue ?? "")
//                                                .font(.caption2)
//                                                .fontWeight(.semibold)
//                                                .foregroundStyle(chat.model?.tintColor ?? .white)
//                                                .padding(6)
//                                                .background((chat.model?.tintColor ?? .white).opacity(0.1))
//                                                .clipShape(Capsule(style: .continuous))
                                    }
                                    .contentShape(Rectangle())
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onLongPressGesture {
                                    viewModel.curTitle = chat.topic ?? "New Chat"
                                    viewModel.curID = chat.id ?? ""
                                    viewModel.showEditWindow = true
                                }
                                .swipeActions { // Swipe to delete
                                    Button {
                                        showPopup = true
                                        deleteChat = false
                                        chatToDelete = chat
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                    .tint(Color.brandRed)
                                }
                            }
                        }
                        .disabled(viewModel.showEditWindow)
                    }
                } // End of Group
                .blur(radius: viewModel.showEditWindow ? 5 : 0)
                .navigationTitle("Health Advisor")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                do {
                                    _ = try await viewModel.createChat(user: profileViewModel.currentUser?.uid)
                                    await viewModel.fetchData(user: profileViewModel.currentUser?.uid)
                                } catch {
                                    print("ERROR: Failed to create chat \nSource: ChatSelectionView \n\(error.localizedDescription)")
                                }
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundStyle(.brandDarkGreen)
                        }
                    }
                })
                .sheet(item: $selectedChatId) { chatId in
                    ChatView(viewModel: .init(chatId: chatId.id))
                }
                .onAppear{
                    Task {
                        await viewModel.fetchData(user: profileViewModel.currentUser?.uid)
                    }
                }
                .onChange(of: deleteChat, { _, newValue in
                    if deleteChat == true {
                        Task {
                            await viewModel.deleteChat(chat: chatToDelete!)
                            deleteChat = false
                        }
                    }
                })
//                .navigationDestination(for: String.self, destination: { chatId in
//                    ChatView(viewModel: .init(chatId: chatId))
//                })
                

            }// End of Navigation Stack
            .blur(radius: showPopup ? 5 : 0)
            .disabled(showPopup)
            
            if viewModel.showEditWindow {
                editTitleView
            }
            
            if showPopup {
                PopUpConfirmationView(messageTitle: NSLocalizedString("Are you sure you want to delete this chat?", comment: ""), message: NSLocalizedString("Your chat and chat history will not be able to recover.", comment: ""), actionButtonText: NSLocalizedString("Delete", comment: ""), isPresented: $showPopup, actionBool: $deleteChat)
                    .padding(.horizontal, 30)
            }
            
        }
        .onDisappear {
            showPopup = false
            deleteChat = false
            selectedChatId = nil
            viewModel.loadingState = .none
        }
        
    } // End of body
    
    
    /// The view which shows a popup to edit the title of the AI Advisor chat.
    var editTitleView: some View {
        VStack {
            VStack {
                Text("Edit Title")
                    .font(.title3)
                    .padding(.top, 10)
                TextField("New Title", text: $viewModel.curTitle)
                Divider()
                HStack(alignment: .center, spacing: 50) {
                    Button {
                        viewModel.showEditWindow = false
                    } label: {
                        Text("Cancel")
                    }
                    Divider()
                    Button { // Save the title
                        viewModel.uploadChatTitle(chatId: viewModel.curID)
                        viewModel.showEditWindow = false
                    } label: {
                        Text("Save")
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: 300, height: 120)
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    
}


#Preview {
    ChatSelectionView()
}
