//
//  IconGenerator.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/19/26.
//

import SwiftUI
import UIKit

// MARK: - Icon Generator
/// Utility to generate a purple clock icon that can be used as app icon
class IconGenerator {
    static func generateClockIcon(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Background
            UIColor.white.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            
            // Clock circle
            let clockRect = CGRect(x: size.width * 0.15, 
                                   y: size.height * 0.15, 
                                   width: size.width * 0.7, 
                                   height: size.height * 0.7)
            
            UIColor(red: 0.7, green: 0.5, blue: 1.0, alpha: 1.0).setFill()
            context.cgContext.fillEllipse(in: clockRect)
            
            // Clock border
            UIColor(red: 0.6, green: 0.4, blue: 0.95, alpha: 1.0).setStroke()
            context.cgContext.setLineWidth(size.width * 0.04)
            context.cgContext.strokeEllipse(in: clockRect)
            
            // Clock center
            let centerX = size.width / 2
            let centerY = size.height / 2
            let center = CGPoint(x: centerX, y: centerY)
            
            let dotRadius = size.width * 0.06
            context.cgContext.fillEllipse(in: CGRect(x: center.x - dotRadius, 
                                                       y: center.y - dotRadius, 
                                                       width: dotRadius * 2, 
                                                       height: dotRadius * 2))
            
            // Hour hand (pointing to 10)
            UIColor.white.setStroke()
            context.cgContext.setLineWidth(size.width * 0.08)
            context.cgContext.setLineCap(.round)
            
            let hourLength = size.width * 0.18
            let hourAngle: CGFloat = 5 * .pi / 6 // 150 degrees (10 o'clock)
            let hourEnd = CGPoint(x: center.x + hourLength * sin(hourAngle),
                                 y: center.y - hourLength * cos(hourAngle))
            context.cgContext.move(to: center)
            context.cgContext.addLine(to: hourEnd)
            context.cgContext.strokePath()
            
            // Minute hand (pointing to 2)
            let minuteLength = size.width * 0.25
            let minuteAngle: CGFloat = .pi / 3 // 60 degrees (2 o'clock)
            let minuteEnd = CGPoint(x: center.x + minuteLength * sin(minuteAngle),
                                   y: center.y - minuteLength * cos(minuteAngle))
            context.cgContext.move(to: center)
            context.cgContext.addLine(to: minuteEnd)
            context.cgContext.strokePath()
        }
        
        return image
    }
}
