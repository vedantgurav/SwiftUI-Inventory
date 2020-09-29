//
//  Searcher test.swift
//  Bottles
//
//  Created by Vedant Gurav on 08/04/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct Searcher_test: View {
    
    var test = ["1","2","3","4","5","6","7"]
    @State private var showSearch:Bool = false
    @State private var searchText = ""
    var offt:CGFloat = 146
    
    var body: some View {
        NavigationView {
            Group {
                GeometryReader { geo in
                    Group {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.gray))
                            TextField("Search", text: self.$searchText) {
                            }
                            if !self.searchText.isEmpty {
                                Image(systemName: "multiply.circle.fill")
                                    .onTapGesture {
                                        self.searchText = ""
                                    }
                                    .foregroundColor(Color(.gray))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(.tertiarySystemGroupedBackground))
                            .frame(width: 350, height: 40)
                        )
                        .padding(.horizontal, 8)
                    }
                    .padding()
                    .frame(width: UIScreen.screenWidth, height: 50)
                    .background(Blur())
                    .offset(y: geo.frame(in: .named("Custom")).minY + self.offt > 0 ? -geo.frame(in: .named("Custom")).minY + self.offt: self.offt )
                }
                .frame(height: 50)
                List {
                    Text("lol")
                    Text("lol")
                    Text("lol")
                    Text("lol")
                    Text("lol")
                }
                .coordinateSpace(name: "Custom")
            }
            .gesture(
                            DragGesture()
                            .onChanged({ (value) in
            //                    self.dragOffset = value.translation
            //                    self.startLocation = value.startLocation.x
                                self.showSearch = true
                            })
                            .onEnded({ (value) in
    //                            self.showSearch = true
                            })
                        )
            .navigationBarTitle(Text("hi"))
        }
    }
}

struct Searcher_test_Previews: PreviewProvider {
    static var previews: some View {
        Searcher_test()
//        .environment(\.colorScheme, .dark)
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
