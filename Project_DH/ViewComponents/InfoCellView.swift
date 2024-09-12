//
//  InfoCellView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/12/24.
//

import SwiftUI

struct InfoCellView: View {
    var title: String
    var info: String?
    var unit: String?
    
    var body: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString(title, comment: ""))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray)
                .shadow(radius: 0)
            Spacer()
            Divider()
                .frame(minHeight: 4)
                .overlay(Color.brandDarkGreen)
                .opacity(0.7)
                .padding(.horizontal, 10)
            Spacer()
            
            if let info = info, info != ""{
                Text(" " + info +  " " + NSLocalizedString(unit ?? "", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(.brandDarkGreen)
                    .foregroundStyle(Color.gray)
                    .shadow(radius: 0)
                    
            } else {
                Text("-")
                    .font(.subheadline)
                    .foregroundStyle(.brandDarkGreen)
                    .foregroundStyle(Color.gray)
                    .shadow(radius: 0)
            }
            Spacer()
        }
        .frame(height: 140)
        .background(.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    InfoCellView(title: "BMI", info: "-" )
}
