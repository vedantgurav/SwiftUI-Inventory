//
//  SwiftUIView.swift
//  Bottles
//
//  Created by Vedant Gurav on 30/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    
    @State var searchText = ""
    @State var searching = false
    
    var body: some View {
        NavigationView {
            Button( action: {
                
            }) {
                Text("New Bottle")
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.systemBackground))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                )
            }
//            List {
//                Text("Hi")
//            }
            .navigationBarTitle(Text("Search"))
//            .navigationBarItems(
//                leading:
//                    HStack {
//                        HStack {
//                            Image(systemName: "magnifyingglass")
//                                .foregroundColor(Color(.gray))
//                                .padding(.leading, 8)
//                            TextField("Search", text: $searchText) {
//                            }
//                            if !self.searchText.isEmpty {
//                                Image(systemName: "multiply.circle.fill")
//                                    .onTapGesture {
//                                        self.searchText = ""
//                                    }
//                                    .padding(.trailing, 8)
//                                    .foregroundColor(Color(.gray))
//                            }
//                        }
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                            .foregroundColor(Color(.tertiarySystemGroupedBackground))
//                            .frame(height: 36)
//                        )
//    //                    .padding(.trailing, 8)
//                        Button( action: {
//                            self.searchText = ""
//                            self.searching = false
//                        }) {
//                            Text("Cancel")
//                        }
//                    }
//                    .padding()
//                    .frame(width: UIScreen.screenWidth)
//            )

        }
    
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
            .environment(\.colorScheme,.dark)
    }
}

//extension View {
//    func navigationBarItems<L, C, T>(leading: L, center: C, trailing: T) -> some View where L: View, C: View, T: View {
//    self.navigationBarItems(leading:
//            HStack{
//                HStack {
//                    leading
//                }
//                .frame(width: 100, alignment: .leading)
//    Spacer()
//                HStack {
//                    center
//                }
//                .frame(width: 130, alignment: .center)
//    Spacer()
//                HStack {
//                    trailing
//                }
//                .frame(width: 100, alignment: .trailing)
//            }
//            .frame(width: UIScreen.main.bounds.size.width-32, height: 1000)
//        )
//    }
//}
