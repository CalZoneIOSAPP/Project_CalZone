//
//  MediaInputView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/21/24.
//


import SwiftUI
import PhotosUI
import Combine

struct MealInputView: View {
    @EnvironmentObject var control: ControllerModel
//    @StateObject var control = ControllerModel() // For preview only
    @StateObject var viewModel = MealInputViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var dashboardViewModel = DashboardViewModel()
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State private var pickedPhoto: Bool = false
    @State private var savePressed = false
    @State private var showingDatePicker = false
    @State private var originalDate: Date = Date()
    
    let saveToOtherDateTip = SaveToOtherDateTip()
    let addMealTip = AddMealPhotoTip()
    let mealTypeTip = MealTypeTip()
    let saveTip = SaveMealTip()
    
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    if viewModel.isProcessingMealInfo {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack {
                                    Image("cooking")
                                        .resizable()
                                        .frame(width: 260, height: 260)
                                        .clipShape(Circle())
                                        .opacity(0.5)
                                    ProgressView("Processing your food :-)")
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            ZStack { // Picture frame
                                FoodItemPictureView
                                CalorieTagOnImage
                            }
                            .onTapGesture{
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                isConfirmationDialogPresented = true
                            }
                            .confirmationDialog("Choose an option", isPresented: $isConfirmationDialogPresented) {
                                Button("Camera"){
                                    sourceType = .camera
                                    isImagePickerPresented = true
                                }
                                Button("Photo Library"){
                                    sourceType = .photoLibrary
                                    isImagePickerPresented = true
                                }
                            }
                            .fullScreenCover(isPresented: $isImagePickerPresented) {
                                if sourceType == .camera{
                                    FoodImagePicker(isPresented: $isImagePickerPresented, image: $viewModel.image, sourceType: .camera)
                                        .onDisappear {
                                            isImagePickerPresented = false
                                        }
                                }else{
                                    FoodPhotoPicker(selectedImage: $viewModel.image, pickedPhoto: $pickedPhoto)
                                        .onDisappear {
                                            isImagePickerPresented = false
                                        }
                                }
                            }
                            .padding(.bottom)
                            
                            TextField("What did you eat?", text: $viewModel.mealName)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Text("\(DateTools().formattedDate(viewModel.selectedDate))")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                                    .multilineTextAlignment(.center)
                                if !profileViewModel.isVIP {
                                    Text("Remaining Estimations: \(viewModel.remainingEstimations)")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                        .padding()
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            CalorieAmountPicker
                                .frame(width: 270)
                                .padding(.bottom, 30)
                            
                            DropDownMenu(selection: $viewModel.selectedMealType, hint: viewModel.determineMealType(), options: [.breakfast, .lunch, .dinner, .snack], anchor: .top)
                                .padding(.bottom, 40)
                                .disabled(viewModel.isProcessingMealInfo || savePressed)
                            
                            SaveMealButton
                            
                            ResetButton
                            
                        } // VStack (If not processing info)
                        .scrollIndicators(.hidden)
                        .disabled(viewModel.showMessageWindow)
                        .blur(radius: viewModel.showMessageWindow || viewModel.showInputError || viewModel.showUsageError ? 5 : 0)
                        .navigationTitle("Add a Meal")
                        .navigationBarTitleDisplayMode(.inline)
                        .disabled(savePressed)
                    } // Else Block
                    
                    if viewModel.showMessageWindow {
                        PopUpMessageView(messageTitle: NSLocalizedString("Success!", comment: ""), message: NSLocalizedString("Your food item is saved.", comment: ""), popupPositivity: .positive, isPresented: $viewModel.showMessageWindow)
                            .animation(.easeInOut, value: viewModel.showMessageWindow)
                            .padding(.horizontal, 30)
                    }
                    
                    if viewModel.showInputError {
                        PopUpMessageView(messageTitle: NSLocalizedString("Apologies", comment: ""), message: NSLocalizedString("Your image does not contain any food, please try again.", comment: ""), popupPositivity: .negative, isPresented: $viewModel.showInputError)
                            .animation(.easeInOut, value: viewModel.showInputError)
                            .padding(.horizontal, 30)
                    }
                    
                    if viewModel.showUsageError {
                        PopUpMessageView(messageTitle: NSLocalizedString("Apologies", comment: ""), message: NSLocalizedString("To be able to get unlimited usage, please join us and become a CalBite member!", comment: ""), popupPositivity: .negative, isPresented: $viewModel.showUsageError)
                            .animation(.easeInOut, value: viewModel.showUsageError)
                            .padding(.horizontal, 30)
                    }
                    
                    if viewModel.showEstimationError {
                        PopUpMessageView(messageTitle: NSLocalizedString("Apologies", comment: ""), message: NSLocalizedString("It seems that we are unable to predict the number of calories. You can re-upload or retake the photo.", comment: ""), popupPositivity: .negative, isPresented: $viewModel.showEstimationError)
                            .animation(.easeInOut, value: viewModel.showEstimationError)
                            .padding(.horizontal, 30)
                    }
                    
                    
                } // ZStack
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        CalendarView(selectedDate: $viewModel.selectedDate, originalDate: $originalDate, showingPopover: $showingDatePicker, viewModel: dashboardViewModel, fetchOnDone: false)
                            .disabled(viewModel.isProcessingMealInfo || savePressed)
                            .opacity(viewModel.isProcessingMealInfo || savePressed ? 0 : 1.0)
                    }
                })
                .onAppear {
                    Task {
                        try await profileViewModel.fetchUserSubscription()
                    }
                }
                
            } // Geometry Reader
            .ignoresSafeArea(.keyboard, edges: .all)
            .dismissKeyboardOnTap()
            .onAppear {
                if let user = profileViewModel.currentUser {
                    Task {
                        if !control.deletingAccount {
                            try await viewModel.getRemainingUsage(for: user)
                        }
                    }
                }
            }
            .onChange(of: profileViewModel.currentUser) { _, newValue in
                if let user = profileViewModel.currentUser {
                    Task {
                        try await viewModel.getRemainingUsage(for: user)
                    }
                }
            }
        } // End of Navigation Stack
        
    }// End of body
    
    
    var FoodItemPictureView: some View {
        FoodPictureView(image: viewModel.image ?? UIImage(resource: .addMeal))
            .onChange(of: viewModel.image) {
                if viewModel.image != UIImage(resource: .addMeal){
                    if let user = profileViewModel.currentUser {
                        Task {
                            do {
                                if profileViewModel.isVIP {
                                    print("VIP USER - GETTING VIP MEAL INFO.")
                                    try await viewModel.getMealInfoVIP()
                                } else {
                                    try await viewModel.getMealInfo(for: user)
                                }
                            } catch {
                                print("ERROR: Getting meal info.")
                            }
                        }
                    }
                }
            }
    }
    
    
    var CalorieTagOnImage: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    HStack {
                        Text("kCal: \(viewModel.calories ?? "0")")
                            .font(.title3)
                            .padding(.leading, 25)
                        
                        if let calories = viewModel.calories, calories != "0" {
                            Text("(\(String(Int(viewModel.sliderValue)))%)")
                        }
                        Spacer()
                    }
                    .frame(width: 200, height: 40)
                    .background((Color.white).opacity(0.9).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: 5))
                    .padding()
                    .opacity(viewModel.image == UIImage(resource: .addMeal) || viewModel.image == nil ? 0 : 1)
                }
                Spacer()
            }
        }
    }
    
    
    var CalorieAmountPicker: some View {
        HStack {
            Text("0%")
            Slider(value: $viewModel.sliderValue, in: 0...100, step: 1)
                            .frame(width: 170)
                            .disabled(!viewModel.imageChanged || viewModel.isProcessingMealInfo || savePressed)
                            .onChange(of: viewModel.sliderValue) {
                                viewModel.calorieIntakePercentage()
                            }
            Text("100%")
        }
    }
    
    
    var SaveMealButton: some View {
        // Save Meal Button
        Button {
            savePressed = true
            Task {
                defer {
                    savePressed = false
                }
                
                if let userId = profileViewModel.currentUser?.uid {
                    do {
                        // Save the food item
                        try await viewModel.saveFoodItem(image: viewModel.image!, userId: userId, date: viewModel.selectedDate) { error in
                            if let error = error {
                                print("ERROR: Save meal button \n\(error.localizedDescription)")
                            } else {
                                print("SUCCESS: Food Saved!")
                                control.refetchMeal = true
                                let calendar = Calendar.current
                                let today = calendar.dateComponents([.year, .month, .day], from: Date())
                                let selectedDate = calendar.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
                                if today == selectedDate {
                                    control.getMealSuggestion = true
                                }
                            }
                        }
                    } catch {
                        print("ERROR: Save meal button \n\(error.localizedDescription)")
                    }
                }
                viewModel.image = UIImage(resource: .addMeal)
                viewModel.imageChanged = false
            }
        } label: {
            Text(LocalizedStringKey("Save Meal                                                     "))
        }
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .frame(width: 180, height: 45)
        .background(.brandDarkGreen)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.bottom, 3)
        .shadow(radius: 3)
        .disabled(!viewModel.imageChanged || viewModel.isProcessingMealInfo || savePressed)
        .opacity(!viewModel.imageChanged || viewModel.isProcessingMealInfo || savePressed ? 0.6 : 1.0)
    }
    
    
    var ResetButton: some View {
        // Reset inputs
        Button {
            viewModel.clearInputs()
            savePressed = false
        } label: {
            Text(LocalizedStringKey("Cancel"))
                .foregroundStyle(.black)
                .frame(width: 180, height: 45)
        }
        .background((Color.white).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: 8))
        .disabled(savePressed || viewModel.isProcessingMealInfo)
        .opacity(savePressed || viewModel.isProcessingMealInfo ? 0.6 : 1.0)
        .padding(.bottom, 30)
    }

    
} // Struct


/// This is the view for displaying the image in a circular border.
struct FoodPictureView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable().scaledToFill()
            .frame(maxWidth: 500, maxHeight: 300)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .opacity(image == UIImage(resource: .addMeal) ? 0.5 : 1)
    }
}


#Preview {
    MealInputView()
        .environmentObject(ControllerModel())
}
