//
//  GroupItemView.swift
//  Bottles
//
//  Created by Vedant Gurav on 29/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct GroupItemView: View {
    var name:String
    var color:String
    var count:Int
    var editLocation = false
    var text="Bed Storage"
    
    var body: some View {
        HStack(alignment: .center) {
            Text(name)
                .font(.headline)
                .lineLimit(1)
            Spacer()
            CircleTextView(text: "\(count)", color: Color(hex: color), radius: 30, padding: 10, fill: true)
        }
    }
}

struct GroupItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                GroupItemView(name: "Whiskey", color: "#00FF00FF", count: 13)
                GroupItemView(name: "Vodka", color: "#00FF00FF", count: 1344)
                GroupItemView(name: "Whiskey", color: "#00FF00FF", count: 13)
                GroupItemView(name: "Whiskey", color: "#00FF00FF", count: 113)
                GroupItemView(name: "Whiskey", color: "#00FF00FF", count: 13)
                GroupItemView(name: "Whiskey", color: "#00FF00FF", count: 13)
            }
        }
        .environment(\.colorScheme, .dark)
    }
}
