//
//  FoodCard.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/8/24.
//

import SwiftUI
import Kingfisher

struct FoodCard: View {
    let imageURL: String
    let title: String
    let user: User
    let likeCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main image
            HStack {
                Spacer()
                KFImage(URL(string: imageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 180)
                    .cornerRadius(10)
                Spacer()
            }
            
            // Title / Description
            Text(title)
                .font(.headline)
                .opacity(0.8)
                .lineLimit(2)
                .padding(.bottom, 4)
            
            // User information
            HStack {
                // User profile image
                if let profileImageUrl = user.profileImageUrl {
                    Image(profileImageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                }
                
                
                // Username
                Text(user.userName ?? "Cool Person")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .opacity(0.7)
                
                Spacer()
                
                // Like count with heart icon
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(likeCount)")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}


#Preview {
    FoodCard(imageURL: "", title: "Food Item Name", user: User.MOCK_USER, likeCount: 5)
}
