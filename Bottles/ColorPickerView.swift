//
//  ColorPickerView.swift
//  ColorPicker
//
//  Created by Brandon Baars on 1/12/20.
//  Copyright © 2020 Brandon Baars. All rights reserved.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var pickedColor: Color
    
    // 1
    @State private var isDragging: Bool = false
    @State private var startLocation: CGFloat = .zero
    @State private var dragOffset: CGSize = .zero
    
    init(pickedColor: Binding<Color>) {
        self._pickedColor = pickedColor
    }
    
    private var colors: [Color] = {
        let hueValues = Array(0...359)
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 359.0,saturation: 1.0,brightness: 1.0,alpha: 1.0))
        }
    }()
    
    // 2
    private var circleWidth: CGFloat {
        isDragging ? 35 : 15
    }
    
    var linearGradientHeight: CGFloat = 10
    var linearGradientWidth: CGFloat = 320
    
    /// Get the current color based on our current translation within the view
    private var currentColor: Color {
        Color(UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: 1.0, alpha: 1.0))
    }
    
    private var currentColorHex: Color {
        Color(hex: UIColor.init(hue: self.normalizeGesture() / linearGradientWidth, saturation: 1.0, brightness: 1.0, alpha: 1.0).toHex(alpha: true)!)
    }
    
    /// Normalize our gesture to be between 0 and 200, where 200 is the height.
    /// At 0, the users finger is on top and at 200 the users finger is at the bottom
    private func normalizeGesture() -> CGFloat {
        let offset = startLocation + dragOffset.width // Using our starting point, see how far we've dragged +- from there
        let maxX = max(0, offset) // We want to always be greater than 0, even if their finger goes outside our view
        let minX = min(maxX, linearGradientWidth) // We want to always max at 200 even if the finger is outside the view.
        
        return minX
    }
    
    var body: some View {
        // 3
        ZStack(alignment: .leading) {
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .leading,
                           endPoint: .trailing)
                .frame(width: linearGradientWidth, height: linearGradientHeight)
                .cornerRadius(5)
                .shadow(radius: 8)
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            self.dragOffset = value.translation
                            self.startLocation = value.startLocation.x
                            self.pickedColor = self.currentColorHex
                            self.isDragging = true // 4
                        })
                        // 5
                        .onEnded({ (_) in
                            self.isDragging = false
                        })
            )
            
            // 6
            Circle()
                .foregroundColor(self.currentColor)
                .frame(width: self.circleWidth, height: self.circleWidth)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: self.circleWidth / 2.0).stroke(Color.white, lineWidth: 2.0)
                )
                .offset(x: self.normalizeGesture() - self.circleWidth / 2, y: self.isDragging ? -self.circleWidth : 0.0)
                .animation(Animation.spring().speed(2))
        }
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
         ColorPickerView(pickedColor: Binding.constant(Color.white))
    }
}
