//
//  GroupMaker.swift
//  Bottles
//
//  Created by Vedant Gurav on 29/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct GroupMaker: View {
    @Binding var groupName:String
    @Binding var groupColor:Color
    
    
    
    
    
    var groupTitle:String
    var form = false
    
    var body: some View {
        
        let nameField = VStack(alignment: .leading) {
            Text("Name")
            TextField("Enter \(groupTitle) Name", text: $groupName)
                .font(.headline)
                .autocapitalization(.words)
            Spacer()
        }
        var colorField:some View {
            VStack {
                HStack() {
                    Text("Accent Color")
                    Spacer()
                }
                ColorPickerView(pickedColor: $groupColor)
                    .frame(height: 10)
                    .offset(x: 0, y: 0)
                    .padding(.vertical, 15)
            }
        }
        
        return Group {
//            let pickedColor = Binding<Color>(get: {
//                self.groupColor
//            }, set: {
//                self.groupColor = $0
//            })
            
            if self.form {
                Form {
                    nameField
//                    ColorPicker("Accent Color", selection: pickedColor)
                    colorField
                }
            } else {
                nameField
//                ColorPicker("Accent Color", selection: pickedColor)
                colorField
            }
        }
    }
    
    
}


//struct GroupMaker_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupMaker(groupName: $a, groupColor: $bColor.red, groupTitle: $c:String="C")
//    }
//}
