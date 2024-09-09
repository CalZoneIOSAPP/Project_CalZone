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
    
    // For sharing only
    @State private var sharedImages: [UIImage] = []
    @State private var isLoadingShare = false
    
    
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
                            socialMediaShareSection
                                .padding(.bottom)
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
    
    
    // Dashboard Healder Section
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
    
    
    // FoodItem Section
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
    
    
    // Social Media Share Section
    var socialMediaShareSection: some View {
        HStack {
            Spacer()
            Button(action: {
                isLoadingShare = true
                Task {
                    await fetchImagesFromURLs()  // Fetch images first
                    shareDailyMeals()  // Share both text and images
                    isLoadingShare = false
                }
            }) {
                if isLoadingShare {
                    ProgressView()  // Show loading spinner
                } else {
                    Label("Share Daily Meals", systemImage: "square.and.arrow.up")
                }
            }
        }
        .padding(.trailing)
    }

    
    // Fetch images asynchronously from FoodItem URLs
    func fetchImagesFromURLs() async {
        sharedImages = []
        let allItems = viewModel.breakfastItems + viewModel.lunchItems + viewModel.dinnerItems + viewModel.snackItems
        for foodItem in allItems {
            if let url = URL(string: foodItem.imageURL) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        sharedImages.append(image)
                    }
                } catch {
                    print("Failed to load image from \(foodItem.imageURL): \(error)")
                }
            }
        }
    }

    
    // Share daily meals using UIActivityViewController
    func shareDailyMeals() {
        let content = prepareSharingContent()  // Get the text content
        var activityItems: [Any] = [content]
        activityItems.append(contentsOf: sharedImages)  // Add images

        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    /// The function prepare the shareing content on social media
    /// - Parameters:
    ///     - none
    /// - Returns: String of shareing text content
    /// Prepare the share content with food items
    func prepareSharingContent() -> String {
        var breakfastContent = ""
        var lunchContent = ""
        var dinnerContent = ""
        var snackContent = ""
        
        if !viewModel.breakfastItems.isEmpty {
            breakfastContent = "Breakfast 🥞: " + viewModel.breakfastItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        if !viewModel.lunchItems.isEmpty {
            lunchContent = "Lunch 🍲: " + viewModel.lunchItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        if !viewModel.dinnerItems.isEmpty {
            dinnerContent = "Dinner 🍛: " + viewModel.dinnerItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        if !viewModel.snackItems.isEmpty {
            snackContent = "Snacks 🍪: " + viewModel.snackItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        
        let totalCalories = viewModel.sumCalories
        
        return """
        🍽️ Today's Meal Recap 🍽️

        \(breakfastContent)\(lunchContent)\(dinnerContent)\(snackContent)
        ✨ Total Calories: \(totalCalories) kcal

        Enjoy every bite while balancing nutrition and health! 🍽️💪
        """
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
