//
//  EditProfileView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 5/10/24.
//

import SwiftUI
import PhotosUI


struct EditProfileView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    @Binding var showingProfileInfo: Bool
    
    @State private var image: UIImage?
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: SourceType = .camera
    @State private var pickedPhoto: Bool = false
    @State private var showSavingPopup: Bool = false
    
    var currentEditTab = ""
    
    enum SourceType {
        case camera
        case photoLibrary
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                HStack {
                    Button {
                        showingProfileInfo = false
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.brandDarkGreen)
                        }
                    }.padding(.leading, 30)
                    
                    Spacer()
                    

                    Button { // Save the photo to the Firebase
                        Task {
                            viewModel.processingSaving = true
                            defer {
                                viewModel.processingSaving = false
                                showSavingPopup = true
                            }
                            try await viewModel.updateProfilePhoto()
                            pickedPhoto = false
                        }
                    } label: {
                        Text(LocalizedStringKey("Save"))
                            .foregroundStyle(.brandDarkGreen)
                            .opacity(!pickedPhoto ? 0 : 1)
                    }
                    .padding(.trailing, 30)
                    .disabled(!pickedPhoto || viewModel.processingSaving)
                    
                }
                .disabled(viewModel.showEditWindow)
                
                // Profile Photo
                VStack(spacing: 15) {
                    ZStack {
                        if let image = viewModel.profileImage { // An image is selected, but not yet uploaded
                            ProfileImageView(image: image)
                        }
                        else{
                            CircularProfileImageView(user: viewModel.currentUser, width: 100, height: 100, showCircle: true)
                        }
                    }
                    .padding(.bottom, 5)
                    .padding(.top, 30)
                    .onTapGesture{
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
                            ImagePicker(isPresented: $isImagePickerPresented, image: $image, sourceType: .camera)
                        }else{
                            PhotoPicker(selectedImage: $image, pickedPhoto: $pickedPhoto)
                                .environmentObject(viewModel)// Binding image, the returned image is sent back to this view
                        }
                    }
                    
                    Text(viewModel.currentUser?.userName ?? "Username")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 30)
                }
                .disabled(viewModel.showEditWindow)
                
                List {
                    
                    Section(header: Text("Account Info")){
                        ForEach(AccountOptions.allCases){ option in
                            HStack {
                                Text(option.title)
                                Spacer()
                                Text(viewModel.getUserDisplayStrInfo(with: option))
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.systemGray2))
                            }
                            .onTapGesture {
                                viewModel.firebaseFieldName = option.firebaseFieldName
                                viewModel.curStateAccount = option
                                viewModel.editInfoWindowTitle = option.title
                                viewModel.editInfoWindowPlaceHolder = option.placeholder
                                viewModel.showEditWindow = true
                                viewModel.inputType = option.inputStyle
                            }
                        }
                    }
                    
                    Section(header: Text("Dietary Info")){
                        ForEach(DietaryInfoOptions.allCases){ option in
                            HStack {
                                Text(option.title)
                                Spacer()
                                Text(viewModel.getUserDietaryInfo(with: option))
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.systemGray2))
                            }
                            .onTapGesture {
                                viewModel.firebaseFieldName = option.firebaseFieldName
                                viewModel.curStateDietary = option
                                viewModel.editInfoWindowTitle = option.title
                                viewModel.editInfoWindowPlaceHolder = option.placeholder
                                viewModel.showEditWindow = true
                                viewModel.inputType = option.inputStyle
                                viewModel.options = option.options?.options
                                viewModel.optionMaxWidth = option.options?.maxWidth ?? 220
                            }
                        }
                    }
                    
                }
                .disabled(viewModel.showEditWindow)
            }
            .blur(radius: viewModel.showEditWindow || showSavingPopup ? 5 : 0)
            
            if showSavingPopup {
                PopUpMessageView(messageTitle: "Success!", message: "Your profile image is updated.", popupPositivity: .positive, isPresented: $showSavingPopup)
                    .animation(.easeInOut, value: showSavingPopup)
                    .padding(.horizontal, 30)
            }
            
            if viewModel.showEditWindow {
                EditInfoView
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 5)
                    .frame(maxWidth: 300, maxHeight: viewModel.editInfoWindowTitle == "Activity Level" ? 420 : viewModel.inputType == .pickerStyle ? 350 : 200)
                
            }
        }// End of Z Stack
        
    }
    
    /// The view to show a popup for editing user info.
    var EditInfoView: some View {
        VStack {
            Text(viewModel.editInfoWindowTitle)
                .font(.title3)
                .padding(.top, 20)
            
            Spacer()
            
            VStack {
                switch viewModel.inputType {
                case .fullText:
                    TextField(viewModel.editInfoWindowPlaceHolder, text: $viewModel.strToChange)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 15)
                case .numPad:
                    TextField(viewModel.editInfoWindowPlaceHolder, text: $viewModel.strToChange)
                        .keyboardType(.numberPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 15)
                case .decimalsPad:
                    TextField(viewModel.editInfoWindowPlaceHolder, text: $viewModel.strToChange)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 15)
                case .dropDown:
                    VStack {
                        DropDownMenu(selection: $viewModel.optionSelection, hint: viewModel.editInfoWindowPlaceHolder, options: viewModel.options!, maxWidth: viewModel.optionMaxWidth)
                            .padding(.top, 20)
                        Spacer()
                        Image(viewModel.editInfoWindowTitle == "Activity Level" ? "sport" : "gender")
                            .resizable()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .opacity(0.5)
                        Spacer()
                        clearButton
                    }
                case .pickerStyle:
                    DatePicker(
                        viewModel.editInfoWindowPlaceHolder,
                        selection: $viewModel.dateToChange,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .frame(minWidth: 280)
                    .onAppear {
                        if viewModel.firebaseFieldName == "achievementDate" {
                            viewModel.dateToChange = Date()
                        } else if viewModel.firebaseFieldName == "birthday" {
                            viewModel.dateToChange = viewModel.currentUser?.birthday ?? Date()
                        }
                    }
                    clearButton
                }
            }
            .zIndex(10000.0) // Making sure that the drop down will list will be on top.
            
            Spacer()
            
            Divider()
            
            HStack(alignment: .center, spacing: 50) {
                Button {
                    resetFields()
                    viewModel.showEditWindow = false
                } label: {
                    Text("Cancel")
                }
                Divider()
                Button {
                    Task {
                        let doubleInfo = infoToDouble()
                        
                        try await viewModel.updateInfo(with: viewModel.curStateAccount, with: viewModel.curStateDietary, strInfo: viewModel.strToChange, optionStrInfo: viewModel.optionSelection, dateInfo: viewModel.dateToChange, doubleInfo: doubleInfo)
                        try await viewModel.calculateAndSaveTargetCalories()
                        resetFields()
                    }
                    viewModel.showEditWindow = false
                    
                } label: {
                    Text("Save")
                }
            }
            .frame(height: 50)
        } // VStack
    }
    
    
    var clearButton: some View {
        Button {
            Task {
                try await UserServices.sharedUser.deleteFieldValue(field: viewModel.firebaseFieldName!)
                resetFields()
                viewModel.showEditWindow = false
            }
        } label: {
            Text(LocalizedStringKey("Clear"))
                .foregroundStyle(.black)
                .frame(width: 180, height: 45)
        }
        .background((Color.white).shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: 8))
        .padding(.bottom, 30)
    }
    
    
    /// This function changes certian fields to double.
    /// - Parameters: none
    /// - Returns: The value changed to double.
    /// - Note: We collect user input in string, but some firebase values are stored in Double.
    func infoToDouble() -> Double{
        if let state = viewModel.curStateDietary {
            if state == .height || state == .weight || state == .weightTarget {
                if viewModel.strToChange != "" {
                    return Double(viewModel.strToChange)!
                } else {
                    return 0.0
                }
            }
        }
        return 0.0
    }
    
    
    /// This function resets the published variables which are tied to the user inputs.
    /// - Parameters: none
    /// - Returns: none
    func resetFields() {
        viewModel.strToChange = ""
        viewModel.curStateAccount = nil
        viewModel.curStateDietary = nil
        viewModel.options = nil
        viewModel.dateToChange = Date()
        viewModel.firebaseFieldName = nil
        viewModel.optionSelection = nil
    }
    
    
    
}


/// The view to show the profile picture.
struct ProfileImageView: View {
    var image: Image
   
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .foregroundColor(.gray)
                .frame(width: 100, height: 100)
            image
               .resizable().scaledToFill()
               .frame(width: 100, height: 100)
               .clipShape(Circle())
        }
   }
}


#Preview {
    EditProfileView(showingProfileInfo: .constant(true))
        .environmentObject(ProfileViewModel())
}






