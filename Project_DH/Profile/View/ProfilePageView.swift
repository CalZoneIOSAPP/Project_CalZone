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
    
    // VIP Subscription Type
    @State private var subscriptionType: String? = nil // Monthly, Quarterly, Yearly
    
    private var user: User? {
        return viewModel.currentUser
    }
    
    var body: some View {
        NavigationStack {
            // TODO: Make this HeaderView
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
            fetchUserSubscription()
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
        .fullScreenCover(isPresented: $viewModel.showSubscriptionPage, content: {
            MembershipView(showSubscription: $viewModel.showSubscriptionPage, user: $viewModel.currentUser)
        })
        
    }
    
    
    var headerView: some View {
        
        ZStack {
            HStack(spacing: 30) {
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
                .padding(.leading, 45)
                
                Spacer()
            }
            
            HStack {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(user?.userName ?? "Username")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
    //                Button { // Show profile preview button
    //                    showingProfilePreview = true
    //                } label: {
    //                    Text(LocalizedStringKey("Profile Preview"))
    //                        .font(.footnote)
    //                        .fontWeight(.semibold)
    //                        .frame(width: 130, height: 25)
    //                        .foregroundStyle(.brandDarkGreen)
    //                        .background(Color(.systemGray6))
    //                        .clipShape(RoundedRectangle(cornerRadius: 10))
    //                }
                    HStack {
                        Text(NSLocalizedString("Membership:", comment: ""))
                            .font(.headline)
                            .foregroundStyle(.gray)
                        
                        if let type = subscriptionType {
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
                    
                    SubscriptionButton(showSubscribePage: $viewModel.showSubscriptionPage, user: user) // Add the subscription button here
                         .opacity(subscriptionType == nil ? 1 : 0) // Hide if already a VIP
                }
                .padding(.leading, 45)
            }
            
        }
    }
    
    
    /// Fetches subscription status for current user
    /// - Parameters:
    ///   - none
    private func fetchUserSubscription() {
        guard let userEmail = user?.email else {
            print("User email not available.")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("subscriptions").document(userEmail)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                if let type = data["type"] as? String {
                    self.subscriptionType = type.capitalized
                }
            } else {
                print("NOTE: No subscription found for user. Source: fetchUserSubscription()")
            }
        }
    }
}


#Preview {
    ProfilePageView()
}
