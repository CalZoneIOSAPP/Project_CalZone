//
//  ProgressBarView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/15/24.
//

import SwiftUI

/// Shows a progress bar for calorie tracking.
struct ProgressBarView: View {
    var user: User
    // Progress bar
    var currentCalories: Int
    var lineWidth: CGFloat = 18
    var color: Color = .brandDarkGreen
    var rotationAngle: CGFloat = 153
    
    var body: some View {
        VStack {
            if let targetCalories = user.targetCalories, Int(targetCalories) ?? 0 > 0 {
                if  let _ = user.weight, let _ = user.weightTarget {
                    if user.loseWeight() {
                        Text("Calorie Limit: \(targetCalories)")
                            .font(.title2)
                            .padding(.bottom, 10)
                            .foregroundStyle(color)
                    } else if !user.loseWeight() {
                        Text("Target Calories: \(targetCalories)")
                            .font(.title2)
                            .padding(.bottom, 10)
                            .foregroundStyle(color)
                    } else if user.keepWeight() {
                        Text("Target Calories: \(targetCalories)")
                            .font(.title2)
                            .padding(.bottom, 10)
                            .foregroundStyle(color)
                    }
                } else {
                    Text("Target Calories: \(targetCalories)")
                        .font(.title2)
                        .padding(.bottom, 10)
                        .foregroundStyle(color)
                }
                
                
                if currentCalories > Int(targetCalories)! {
                    semiCircleBar(curCal: Int(targetCalories)!, targetCal: Int(targetCalories)!)
                    .padding(.horizontal, 90)
                    .padding(.top, 20)
                }
                else {
                    semiCircleBar(curCal: currentCalories, targetCal: Int(targetCalories)!)
                    .padding(.horizontal, 90)
                    .padding(.top, 20)
                }
                
            } else {
                Text("You Consumed \(currentCalories) Calories Today")
                    .font(.title)
                    .padding(.top, 10)
                
                semiCircleBar(curCal: 0, targetCal: 100)
                .padding(.horizontal, 80)
                .padding(.top, 20)
            }
        }
        .padding()
    }
    
    
    /// This function creates the semi circular progress bar.
    /// - Parameters:
    ///     - curCal: current calories
    ///     - targetCal: target calories
    /// - Returns: the progress bar
    func semiCircleBar(curCal: Int, targetCal: Int ) -> some View {
        ZStack {
            // Background Circle
            Circle()
                .trim(from: 0.0, to: 0.65)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .opacity(0.2)
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: rotationAngle))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x:0, y:2)

            // Progress Circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Double(curCal) / Double(targetCal), 1.0)) * 0.65)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("brandLightGreen"), Color("brandDarkGreen")]), startPoint: .trailing, endPoint: .leading))
                .rotationEffect(Angle(degrees: rotationAngle)) // Start from the top
                .animation(.linear, value: Double(curCal) / Double(targetCal))

            // Progress Text
            if let _ = user.targetCalories {
                VStack(spacing: 16) {
                    
                    Text("\(curCal)Cal")
                        .font(.custom("cal", size: 25.0))
                        .foregroundColor(color)
                    
                    Divider()
                        .frame(minHeight: 3)
                        .overlay(Color.brandDarkGreen)
                        .opacity(0.4)
                        .padding(.horizontal, 40)
                    
                    Text(String(format: "%.0f%%", min(Double(curCal) / Double(targetCal), 1.0) * 100.0))
                        .font(.title2)
                        .foregroundColor(color)
                }
                .padding(.bottom, 20)
            } else {
                VStack {
                    Text("Target not setup.")
                        .font(.title2)
                        .foregroundColor(color)
                }
            }
        }
    }
    
    
    
}


#Preview {
    ProgressBarView(user: User.MOCK_USER, currentCalories: 100)
}
