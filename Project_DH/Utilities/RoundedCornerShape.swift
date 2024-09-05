//
//  RoundedCornerShape.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/21/24.
//

import Foundation
import SwiftUI

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    /// This function creates a custom path with rounded corners
    /// - Parameters:
    ///     - rect: The rectangle object.
    /// - Returns: Path object.
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
