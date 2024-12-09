//
//  DashboardView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import SwiftUI


struct DashboardView: View {
    @EnvironmentObject var control: ControllerModel
    
    @Environment(\.openURL) var openURL
    @StateObject var viewModel = DashboardViewModel()
    
    @State private var originalDate: Date = Date()
    @State private var showingPopover = false
    @State private var isGreetingVisible: Bool = true
    @State private var loadedFirstTime = false
    @State private var showEditPopup = false
    @State private var selectedFoodItem: FoodItem?
    @State private var showWeightEdit: Bool = false
    
    // For sharing only
    @State private var sharedImages: [UIImage] = []
    @State private var isLoadingShare = false
    
    
    let welcomeTip = WelcomeTip()
    let selectDateTip = SelectDateTip()
    let currentCalTip = CurrentCaloriesTip()
    let changeWeightTip = ChangeWeightTip()
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                GeometryReader { _ in
                    VStack {
                        if viewModel.isLoading && loadedFirstTime == false {
                            ProgressView("Loading...")
                                .padding()
                                .onAppear {
                                    loadedFirstTime = true
                                }
                            
                        } else if viewModel.meals.isEmpty {
                            ScrollView{
                                dashboardHeader
                                
                                Spacer()
                                
                                dashboardUtilitiesSection
                                    .padding(.bottom, 20)
                                
                                Image("noMeal")
                                    .resizable()
                                    .frame(width: 250, height: 250)
                                    .clipShape(Circle())
                                    .opacity(0.5)
                                
                                Text("Start by adding a meal...")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                                
                                Image(systemName: "arrow.down")
                                    .resizable()
                                    .frame(width: 25, height: 40)
                                    .opacity(0.5)
                                    .padding(.top, 20)
                                
                                Spacer()
                            }
                            
                        } else {
                            ScrollView {
                                dashboardHeader
                                dashboardUtilitiesSection
                                    .padding(.bottom)
                                mealSuggestion
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                mealSections
                            }
                            .scrollIndicators(.hidden)
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
                    .onChange(of: control.refetchMeal, { _, newValue in
                        if control.refetchMeal == true {
                            Task {
                                viewModel.sumCalories = 0
                                if let uid = viewModel.profileViewModel.currentUser?.uid {
                                    try await viewModel.fetchMeals(for: uid, with: true)
                                    control.refetchMeal = false
                                    if control.getMealSuggestion == true {
                                        Task {
                                            await viewModel.getMealSuggestion()
                                            control.getMealSuggestion = false
                                        }
                                    }
                                }
                            }
                        }
                    })
                    // Fetch meal items when uid changes.
                    .onChange(of: viewModel.profileViewModel.currentUser?.uid) { _, newValue in
                        print("NOTE: Fetching in Dashboard View On Change.")
                        Task {
                            viewModel.sumCalories = 0
                            if let uid = viewModel.profileViewModel.currentUser?.uid {
                                try await viewModel.fetchMeals(for: uid, with: true)
                            }
                            if let suggestion = viewModel.profileViewModel.currentUser?.mealSuggestion {
                                viewModel.mealSuggestion = suggestion // Load meal suggestion
                            }
                        }
                    }
                    .onDisappear {
                        if !DateTools().isToday(viewModel.selectedDate) {
                            control.refetchMeal = true
                            viewModel.selectedDate = Date()
                        }
                    }
                    
                }// Geometry Reader
                .ignoresSafeArea(.keyboard, edges: .all)

                
            } // End of Navigation Stack
            .blur(radius: showWeightEdit || showEditPopup ? 3 : 0)
            .disabled(showWeightEdit)
            
            if showEditPopup {
                FoodItemEditView(viewModel: viewModel, foodItem: $selectedFoodItem, foodItemList: $viewModel.selectedFoodList, isPresented: $showEditPopup, calorieNum: $viewModel.sumCalories, allItems: false, deletable: false)
            }
            
            if showWeightEdit {
                InfoEditView(showWindow: $showWeightEdit)
                    .padding(.horizontal, 30)
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
    
    
    // Meal Suggestion Section
    var mealSuggestion: some View {
        VStack {
            HStack {
                Text("Cally's Recommendation")
                    .foregroundStyle(.brandDarkGreen)
                    .padding(.leading)
                    .bold()
                Spacer()
            }
            .padding(.top)
            
            Spacer()
            HStack {
                Spacer()
                Text(viewModel.mealSuggestion)
                    .multilineTextAlignment(.center)
                    .bold()
                    .foregroundStyle(Color.gray)
                Spacer()
        }
            Spacer()
        }
        .frame(minHeight: 140)
        .background(.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    
    // FoodItem Section
    var mealSections: some View {
        VStack {
            if !viewModel.breakfastItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: NSLocalizedString("Breakfast", comment: ""), foodItems: $viewModel.breakfastItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                    .environmentObject(control)
            }
            if !viewModel.lunchItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: NSLocalizedString("Lunch", comment: ""), foodItems: $viewModel.lunchItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                    .environmentObject(control)
            }
            if !viewModel.dinnerItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: NSLocalizedString("Dinner", comment: ""), foodItems: $viewModel.dinnerItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                    .environmentObject(control)
            }
            if !viewModel.snackItems.isEmpty {
                MealSectionView(viewModel: viewModel, title: NSLocalizedString("Snack", comment: ""), foodItems: $viewModel.snackItems, calorieNum: $viewModel.sumCalories, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
                    .environmentObject(control)
            }
        }
    }
    
    
    // Social Media Share Section
    var dashboardUtilitiesSection: some View {
        HStack {
            
            Button {
                // Show weight edit view
                showWeightEdit = true
            } label: {
                Label("Update Weight", systemImage: "plus.circle")
            }

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
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .disabled(viewModel.meals.isEmpty)
        }
        .padding(.horizontal)
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
            breakfastContent = NSLocalizedString("Breakfast ", comment: "") + "🥞: " + viewModel.breakfastItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        if !viewModel.lunchItems.isEmpty {
            lunchContent = NSLocalizedString("Lunch ", comment: "") + "🍲: " + viewModel.lunchItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        if !viewModel.dinnerItems.isEmpty {
            dinnerContent = NSLocalizedString("Dinner ", comment: "") + "🍛: " + viewModel.dinnerItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        if !viewModel.snackItems.isEmpty {
            snackContent = NSLocalizedString("Snacks ", comment: "") + "🍪: " + viewModel.snackItems.map { $0.foodName }.joined(separator: ", ") + "\n"
        }
        
        let totalCalories = viewModel.sumCalories
        
        return """
            🍽️ \(NSLocalizedString("Today's Meal Recap", comment: "")) 🍽️

            \(breakfastContent)\(lunchContent)\(dinnerContent)\(snackContent)
            ✨ \(NSLocalizedString("Total Calories", comment: "")): \(totalCalories) kcal

            \(NSLocalizedString("Enjoy every bite while balancing nutrition and health!", comment: ""))
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
        let activityItems: [Any] = [content] // Start with the text
        
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
        return NSLocalizedString("Good morning", comment: "")
    case 12..<17:
        return NSLocalizedString("Good afternoon", comment: "")
    case 17..<24:
        return NSLocalizedString("Good evening", comment: "")
    default:
        return NSLocalizedString("Hello", comment: "")
    }
}


#Preview("English") {
    DashboardView()
        .environmentObject(ControllerModel())
}


#Preview("Chinese") {
    DashboardView()
        .environment(\.locale, Locale(identifier: "zh-Hans"))
        .environmentObject(ControllerModel())
}
