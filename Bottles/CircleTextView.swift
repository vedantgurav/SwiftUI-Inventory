//
//  CircleTextView.swift
//  Bottles
//
//  Created by Vedant Gurav on 31/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct CircleTextView: View {
    var text:String
    var color:Color
    var radius:CGFloat
    var padding:CGFloat
    var fill:Bool
    
    var body: some View {
        Group {
            if fill {
                Text("\(self.text)")
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(Color(.systemBackground))
                    .padding(.horizontal, padding)
                    .background(
                        RoundedRectangle(cornerRadius: radius)
                            .frame(minWidth: radius, minHeight: radius)
                            .foregroundColor(color)
                    )
            } else {
                Text("\(self.text)")
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(color)
                    .padding(.horizontal, padding)
                    .background(
                        RoundedRectangle(cornerRadius: radius)
                            .strokeBorder(color, lineWidth: 1)
                            .frame(minWidth: radius, minHeight: radius)
                    )
            }
        }
    }
}

struct CircleTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .trailing) {
            CircleTextView(text: "2", color: Color(hex: "#FF0000FF"), radius: 30, padding: 10, fill: false)
            .padding(4)
            CircleTextView(text: "23", color: Color(hex: "#FF0000FF"), radius: 30, padding: 10, fill: true)
            .padding(4)
            CircleTextView(text: "233", color: Color(hex: "#FF0000FF"), radius: 30, padding: 10, fill: true)
            .padding(4)
            CircleTextView(text: "11111233", color: Color(hex: "#FF0000FF"), radius: 30, padding: 10, fill: true)
            .padding(4)
        }
    }
}
