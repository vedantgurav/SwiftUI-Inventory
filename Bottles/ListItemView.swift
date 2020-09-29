//
//  ListItemView.swift
//  Bottles
//
//  Created by Vedant Gurav on 24/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct ListItemView: View {
    @State var name:String = "Glenmorangie"
    @State var desc:String = ""
    @State var showDesc:Bool = false
    @State var open:Bool = false
    @State var location:Location = Location()
    @State var category:Category = Category()
    @State var capacity:Int16 = 750
    @State var filterKey:Int = 3
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if self.filterKey != 5 || desc.isEmpty {
                    Text(name)
                        .font(.headline)
                        .lineLimit(1)
                }
                if ( self.showDesc || self.filterKey == 5 ) && !desc.isEmpty {
                    Text(desc)
                        .font( self.filterKey==5 ? .headline : .subheadline)
                        .lineLimit(1)
                }
            }
            Spacer()

            HStack(alignment: .center) {
                if filterKey != 0 {
                    CircleTextView(text: location.wName, color: Color(hex: location.wColor), radius: 25, padding: 8, fill: true)
                }
                if filterKey != 1 && filterKey != 5 {
                    CircleTextView(text: category.wName, color: Color(hex: category.wColor), radius: 25, padding: 8, fill: true)
                }
                CircleTextView(text: "\(capacity)", color: Color.primary, radius: 25, padding: 8, fill: !open)
                
            }
            .font(.footnote)
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView()
    }
}
