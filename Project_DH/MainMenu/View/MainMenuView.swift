//
//  MainMenuView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI


/// The view which handles all major tabs of the application. The logic for the bottom tabs.
struct MainMenuView: View {
    @State private var isShowingInfoCollection: Bool = true
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var infoViewModel = InfoCollectionViewModel()
    @StateObject var controller = ControllerModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                DashboardView()
                    .environmentObject(controller)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.crop.rectangle.fill")
                            Text("Dashboard")
                        }
                    }
                    .tag(0)
                
                ChatSelectionView()
                    .tabItem {
                        VStack {
                            Image(systemName: "face.smiling.fill")
                            Text("Cally")
                        }
                    }
                    .tag(1)
                
                MealInputView()
                    .environmentObject(controller)
                    .tabItem {
                        VStack {
                            Image(systemName: "plus.app.fill")
                            Text("Add")
                        }
                        .frame(width: 70)
                        
                    }
                    .tag(2)
                
                VStack {
                    Text("You will soon be able to share your stories!")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    Image(.community)
                        .resizable()
                        .frame(width: 260, height: 260)
                        .clipShape(Circle())
                        .opacity(0.5)
                }
                .tabItem {
                    VStack {
                        Image(systemName: "safari.fill")
                        Text("Explore")
                    }
                }
                .tag(3)
                
                ProfilePageView()
                    .environmentObject(controller)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Me")
                        }
                        
                    }
                    .tag(4)
            }
            .tint(.brandDarkGreen)
            
            // Custom border line above the tab icons
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray)
                    .frame(height: 1)
                    .padding(.bottom, 49)
            }
            .edgesIgnoringSafeArea(.bottom) // Ensures the Divider is aligned with the tab bar
            
            if isShowingInfoCollection && checkFirstTimeLogIn(){
                InfoCollectionView(isShowing: $isShowingInfoCollection)
                    .environmentObject(infoViewModel)
            }
            
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            Task{
                try await UserServices.sharedUser.fetchCurrentUserData()
            }
        }
        
    }
    
    
    /// Checks whether the user signed in for the first time.
    /// - Parameters: none
    /// - Returns: none
    func checkFirstTimeLogIn() -> Bool{
        if let firstTimeUser = profileViewModel.currentUser?.firstTimeUser {
            //print(profileViewModel.currentUser?.uid as Any)
            //print("FIRST TIME USER: \(firstTimeUser)")
            return firstTimeUser
        }
        return false
    }
}


#Preview {
    MainMenuView()
}
