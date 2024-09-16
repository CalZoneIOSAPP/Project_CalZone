//
//  WheelPicker.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/14/24.
//

import SwiftUI

struct WheelPicker: View {
    
    var config: Config
    
    @Binding var value: CGFloat
    @State private var isLoaded: Bool = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.width / 2
            
            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) { index in
                        let remainder = index % config.steps
                        Divider()
                            .background(remainder == 0 ? Color.primary : .gray)
                            .frame(width: 0, height: remainder == 0 ? 20 : 10, alignment: .center)
                            .frame(maxHeight: 20, alignment: .bottom)
                            .rotationEffect(config.vertical ? .degrees(180) : .degrees(0))
                            .overlay(alignment: config.vertical ? .top : .bottom) {
                                if remainder == 0 && config.showsText {
                                    Text("\((index/config.steps) * config.multiplier)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .textScale(.secondary)
                                        .fixedSize()
                                        .offset(x: config.vertical ? -25 : 0, y: config.vertical ? 0 : 20)
                                        .rotationEffect(config.vertical ? .degrees(90) : .degrees(0))
                                }
                            }
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? (Int(value) * config.steps) / config.multiplier : nil
                return position
            }, set: { newValue in
                if let newValue {
                    value = (CGFloat(newValue) / CGFloat(config.steps)) * CGFloat(config.multiplier)
                }
            }))
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 1), trigger: value)
            .overlay(alignment: .center, content: {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: config.indicatorThickness, height: config.indicatorLength)
                    .padding(.bottom, config.vertical ? 60 : 40)
                    .rotationEffect(config.vertical ? .degrees(180) : .degrees(0))
                
            })
            .safeAreaPadding(.horizontal, horizontalPadding)
            .onAppear {
                if !isLoaded {
                    isLoaded = true
                }
            }
        }
        .rotationEffect(config.vertical ? .degrees(-90) : .degrees(0))
    }
    
    struct Config: Equatable {
        var count: Int
        var steps: Int = 10
        var spacing: CGFloat = 5
        var multiplier: Int = 10
        var showsText: Bool = true
        var vertical: Bool = false
        var indicatorThickness: CGFloat = 4
        var indicatorLength: CGFloat = 40
    }
}

#Preview {
    WheelPicker(config: WheelPicker.Config.init(count: 30), value: .constant(30))
}
