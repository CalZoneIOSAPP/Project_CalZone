//
//  ProfilePageView.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import SwiftUI
import Firebase

struct ProfilePageView: View {
    @EnvironmentObject var control: ControllerModel
    @StateObject var viewModel = ProfileViewModel()
    @State private var showingProfileInfo: Bool = false
    @State private var showingProfilePreview: Bool = false
    @State private var selectedView: ProfileOptions?
    
    
    private var user: User? {
        return viewModel.currentUser
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                headerView
                    .padding(.vertical, 20)
                
                HStack(spacing: 10) {
                    Spacer()
                    if let bmi = viewModel.currentUser?.bmi {
                        InfoCellView(title: NSLocalizedString("BMI", comment: ""), info: String(bmi))
                    } else {
                        InfoCellView(title: NSLocalizedString("BMI", comment: ""), info: "-")
                    }
                    
                    if let weight = viewModel.currentUser?.weight, weight > 0.0 {
                        InfoCellView(title: NSLocalizedString("Weight", comment: ""), info: String(weight), unit: NSLocalizedString("Kg", comment: ""))
                    } else {
                        InfoCellView(title: NSLocalizedString("Weight", comment: ""), info: "-")
                    }
                    
                    if let weightTarget = viewModel.currentUser?.weightTarget, weightTarget > 0.0 {
                        InfoCellView(title: NSLocalizedString("Target \nWeight", comment: ""), info: String(weightTarget), unit: NSLocalizedString("Kg", comment: ""))
                    } else {
                        InfoCellView(title: NSLocalizedString("Target \nWeight", comment: ""), info: "-")
                    }
                    
                    if let achievementDate = viewModel.currentUser?.achievementDate, let targetCal = viewModel.currentUser?.targetCalories, targetCal != "" {
                        let days = viewModel.daysFromDate(date: achievementDate)
                        InfoCellView(title: NSLocalizedString("Remaining \nDays", comment: ""), info: String(days), unit: NSLocalizedString("Days", comment: ""))
                    } else {
                        InfoCellView(title: NSLocalizedString("Remaining \nDays", comment: ""), info: "-")
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
                
                
                List {
                    Section { // Choices
                        ForEach(ProfileOptions.allCases){ option in
                            Button {
                                self.selectedView = option
                            } label: {
                                Text(option.title)
                                    .foregroundStyle(Color(.black))
                                    .font(.system(size: Fontsize().brand_button))
                            }
                            .padding(.vertical, 20)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 35, bottom: 0, trailing: 0))
                    .listRowBackground(RoundedRectangle(cornerRadius: 12).fill(Color(.white)).padding(.vertical, 5).padding(.horizontal, 10))
                    
                                        
                    Section {
                        Button {
                            AuthServices.sharedAuth.signOut()
                        } label: {
                            Text("Log Out")
                                .foregroundStyle(.brandDarkGreen)
                                .font(.system(size: Fontsize().brand_button, weight: .bold))
                        }
                        .listRowInsets(.init(top: 0, leading: 30, bottom: 0, trailing: 0))
                        .listRowBackground(RoundedRectangle(cornerRadius: 12).fill(Color(.white)).padding(.horizontal, 10))
                    }
                }
                .background(Color(.white).opacity(0.13))
                .shadow(color: Color.brandDarkGreen.opacity(0.2), radius: 2)
                .environment(\.defaultMinListRowHeight, 50)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .clipShape(RoundedCornerShape(radius: 20, corners: [.topLeft, .topRight]))
                .modifier(TopShadow()) // Apply the top
                .ignoresSafeArea(edges: .bottom)
                
                
            }
            .background(Color(.brandLightGreen).opacity(0.65))

        } // END OF NAVIGATION STACK
        .onAppear {
            Task {
                try await viewModel.fetchUserSubscription()
            }
        }
        .onChange(of: viewModel.currentUser) { _, newUser in
            Task {
                try await viewModel.fetchUserSubscription()
            }
        }
        .fullScreenCover(isPresented: $showingProfileInfo, content: {
            EditProfileView(showingProfileInfo: $showingProfileInfo)
                .environmentObject(viewModel)
        })
        .fullScreenCover(item: $selectedView) { viewCase in
            switch viewCase {
            case .myStatistics:
                StatsChartView(user: $viewModel.currentUser) // Show the StatsChartView
            // TODO: Handle other cases in the future!
            case .meals:
                MealOverviewView()
                    .environmentObject(control)
                    .onDisappear {
                        control.refetchMeal = true
                    }
            case .friends:
                FriendsView()
            case .settings:
                SettingsView()
                    .environmentObject(control)
            }
        }
        .sheet(isPresented: $viewModel.showSubscriptionPage) {
            SubscriptionView()
        }
        
    }
    
    
    var headerView: some View {
        HStack {
            
            Button { // Move to EditProfileView
                showingProfileInfo = true
//                        .toolbar(.hidden, for: .tabBar)
            } label: {
                if let _ = user?.profileImageUrl{
                    CircularProfileImageView(user: user, width: 80, height: 80, showCircle: true)
                } else {
                    ZStack{
                        Circle()
                            .foregroundColor(.gray)
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color(.systemGray4))
                    }
                }
            }
            .padding(.leading, 30)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text(user?.userName ?? "Username")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(NSLocalizedString("Membership:", comment: ""))
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    if let type = viewModel.subscriptionType {
                        Text(type)
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                    else {
                        Text(NSLocalizedString("BETA", comment: ""))
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                
                SubscriptionButton(showSubscribePage: $viewModel.showSubscriptionPage, user: user, subscriptionType: viewModel.subscriptionType)
                    .padding(.horizontal, 10)
                    // .opacity(viewModel.subscriptionType == nil ? 1 : 0) // Hide if already a VIP
            }
            .padding(.trailing, 25)
            
            Spacer()
        }
    }
    
}


#Preview {
    ProfilePageView()
}
