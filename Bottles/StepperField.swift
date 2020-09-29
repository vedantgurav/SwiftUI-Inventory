//
//  StepperField.swift
//  Bottles
//
//  Created by Vedant Gurav on 31/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct StepperField: View {
    @Binding var value:Int
    var range:ClosedRange<Int>
    var step:Int
    var hint:String=""
    var unit:String=""
    var plural:Bool=false
    var body: some View {
        
        let valueString = Binding<String>(get: {
            "\(self.value > 0 ? "\(self.value)" : "")"
        }, set: {
            self.value = ($0 as NSString).integerValue
        })
        
        return Group {
            Stepper(value: self.$value, in: self.range, step: self.step, label: {
                HStack(alignment: .center) {
                    Text(self.hint)
                    Spacer()
                    TextField(self.hint, text: valueString)
                        .font(.headline)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                    Text(self.unit + (plural && self.value>1 ? "s" : ""))
                        .font(.headline)
                }
            })
        }
    }
}
