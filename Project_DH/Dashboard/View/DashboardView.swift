//
//  DashboardView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import SwiftUI


struct DashboardView: View {

    @Environment(\.openURL) var openURL
    @ObservedObject var viewModel = DashboardViewModel()
    @State private var originalDate: Date = Date()
    @State private var showingPopover = false
    @State private var isGreetingVisible: Bool = true
    @State private var loadedFirstTime = false
    @State private var showEditPopup = false
    @State private var selectedFoodItem: FoodItem?
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if viewModel.isLoading && loadedFirstTime == false {
                        ProgressView("Loading...")
                            .padding()
                            .onAppear {
                                loadedFirstTime = true
                            }
                        
                    } else if viewModel.meals.isEmpty {
                        dashboardHeader
                        
                        Spacer()
                        
                        Text("Start by adding a meal...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Image("noMeal")
                            .resizable()
                            .frame(width: 250, height: 250)
                            .padding(.bottom, 30)
                            .clipShape(Circle())
                            .opacity(0.5)
                        
                        Spacer()
                        
                    } else {
                        ScrollView {
                            dashboardHeader
                                .padding(.bottom, 50)
//                            socialMediaShareSection
//                                .padding(.bottom, 50)
                            mealSections
                        }
                        .refreshable { // Pull down to refresh
                            loadedFirstTime = true
                            viewModel.isRefreshing = true
                            viewModel.sumCalories = 0
                            Task {
                                if let uid = viewModel.profileViewModel.currentUser?.uid {
                                    try await viewModel.fetchMeals(for: uid, with: true, on: viewModel.selectedDate)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("CalBite")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        CalendarView(selectedDate: $viewModel.selectedDate, originalDate: $originalDate, showingPopover: $showingPopover, viewModel: viewModel, fetchOnDone: true)
                    }
                })
                .onAppear { // Fetch meal items when view appears.
                    print("NOTE: Fetching in Dashboard View On Appear.")
                    viewModel.sumCalories = 0
                    viewModel.selectedDate = Date()
                    Task {
                        if let uid = viewModel.profileViewModel.currentUser?.uid {
                            try await viewModel.fetchMeals(for: uid, with: true)
                        }
                    }
                    viewModel.selectedDate = Date()
                }
                // Fetch meal items when uid changes.
                .onChange(of: viewModel.profileViewModel.currentUser?.uid) { _, newValue in
                    print("NOTE: Fetching in Dashboard View On Change.")
                    viewModel.sumCalories = 0
                    viewModel.selectedDate = Date()
                    Task {
                        if let uid = viewModel.profileViewModel.currentUser?.uid {
                            try await viewModel.fetchMeals(for: uid, with: true)
                        }
                    }
                    viewModel.selectedDate = Date()
                }
            } // End of Navigation Stack
            
            if showEditPopup {
                FoodItemEditView(foodItem: $selectedFoodItem, foodItemList: $viewModel.selectedFoodList, isPresented: $showEditPopup, calorieNum: $viewModel.sumCalories, allItems: false, deletable: false, viewModel: viewModel)
            }
        } // End of ZStack
    }
    
    
    var dashboardHeader: some View {
        // Show sum of calories
        VStack(alignment: .center) {
            ProgressBarView(user: viewModel.profileViewModel.currentUser ?? User.MOCK_USER, currentCalories: viewModel.sumCalories)
                .padding(.bottom, -30)
        
            if viewModel.exceededCalorieTarget {
                if let user = viewModel.profileViewModel.currentUser {
                    if user.loseWeight() {
                        Text(LocalizedStringKey("Be careful, you exceeded your calorie limit!"))
                            .foregroundStyle(Color.brandRed)
                            .font(.subheadline)
                    } else if !user.loseWeight() {
                        Text(LocalizedStringKey("Congratulations, you reached your calorie target!"))
                            .foregroundStyle(Color.brandRed)
                            .font(.subheadline)
                    } else if user.keepWeight() {
                        Text(LocalizedStringKey("You reached your recommended calorie limit."))
                            .foregroundStyle(Color.brandRed)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
    
    
    var mealSections: some View {
        VStack {
            if !viewModel.breakfastItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: "Breakfast", foodItems: $viewModel.breakfastItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
            if !viewModel.lunchItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: "Lunch", foodItems: $viewModel.lunchItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
            if !viewModel.dinnerItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: "Dinner", foodItems: $viewModel.dinnerItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
            if !viewModel.snackItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: "Snack", foodItems: $viewModel.snackItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
        }
    }
    
    
    var socialMediaShareSection: some View {
        HStack {
            Text("Share on: ")
                .bold()
                .foregroundColor(.black)
            Button (action: shareToInstagram) {
                Image("instagramImage")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            Button (action: shareFaceBook) {
                Image("facebookImage")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
            Button (action: shareTwitter) {
                Image("twitterImage")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }
        }
    }

    
    /// The function starts a timer with a 5-second interval.
    /// - Parameters:
    ///     - _date: The date object.
    /// - Returns: String of the formatted date.
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 1.0)) {
                isGreetingVisible.toggle()
            }
        }
    }
    
    /// The function prepare the shareing content on social media
    /// - Parameters:
    ///     - none
    /// - Returns: String of shareing text content
    func prepareSharingContent() -> String {
        var breakfastContent = ""
        var lunchContent = ""
        var dinnerContent = ""
        var snackContent = ""
        
        if !viewModel.breakfastItems.isEmpty {
            breakfastContent = "I had " + viewModel.breakfastItems[0].foodName + " for breakfast!"
        }
        if !viewModel.lunchItems.isEmpty {
            lunchContent = "I had " + viewModel.lunchItems[0].foodName + " for lunch!"
        }
        if !viewModel.dinnerItems.isEmpty {
            dinnerContent = "I had " + viewModel.dinnerItems[0].foodName + " for dinner!"
        }
        if !viewModel.snackItems.isEmpty {
            snackContent = "I had " + viewModel.snackItems[0].foodName + " for snack!"
        }
        let content:String = (breakfastContent + lunchContent + dinnerContent + snackContent)
        // let content:String = (breakfastContent + lunchContent + dinnerContent + snackContent).replacingOccurrences(of: " ", with: "%20")
        return content
    }
    
    
    /// The function handle the shareing on Facebook
    /// - Parameters:
    ///     - none
    /// - Returns: none
    func shareFaceBook() {
        let content = prepareSharingContent()
        let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let facebookUrl = "https://www.facebook.com/sharer/sharer.php?u=\(encodedContent)"
        if let url = URL(string: facebookUrl) {
            openURL(url)
        } else {
            print("Invalid Facebook URL")
        }
    }
    
    /// The function handle the shareing on Facebook
    /// - Parameters:
    ///     - none
    /// - Returns: none
    func shareToInstagram() {
        let content = prepareSharingContent()
        var activityItems: [Any] = [content] // Start with the text
        
        /*
        if let image = image {
            activityItems.append(image) // Append the image if it exists
        }
         */
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Present the Activity View Controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    /// The function handle the shareing on Twitter
    /// - Parameters:
    ///     - none
    /// - Returns: none
    func shareTwitter() {
        let content = prepareSharingContent()
        let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let twitterUrl = "https://twitter.com/intent/tweet?text=" + encodedContent + "&url="
        if let url = URL(string: twitterUrl) {
                openURL(url)
        } else {
            print("Invalid Twitter URL")
        }
    }
}


/// A function used to print greetings according to system time
/// - Parameters: 
///     - none
/// - Returns: String of the greeting.
func getGreeting() -> String {
    let hour = Calendar.current.component(.hour, from: Date())

    switch hour {
    case 0..<12:
        return "Good morning"
    case 12..<17:
        return "Good afternoon"
    case 17..<24:
        return "Good evening"
    default:
        return "Hello"
    }
}


#Preview("English") {
    DashboardView()
}


#Preview("Chinese") {
    DashboardView()
        .environment(\.locale, Locale(identifier: "zh-Hans"))
}
