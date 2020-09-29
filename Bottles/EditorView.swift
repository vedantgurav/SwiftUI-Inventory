//
//  EditorView.swift
//  Bottles
//
//  Created by Vedant Gurav on 24/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI
import Introspect

struct EditorView: View {
    var bottles:FetchedResults<Bottle>
    var locations:FetchedResults<Location>
    var categories:FetchedResults<Category>
    @State var name: String = ""
    @State var desc: String = ""
    @State var selectedLocation: Int = 0
    @State var selectedCategory: Int = 0
    @State var selectedOpen: Int = 0
    @State var capacity: Int = 750
    @State var edit: Bool = false
    @State var selectedBottle: Int = 0
    var wishlist = false
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode:Binding<PresentationMode>
    
    var keyboard:KeyboardResponder
//    @Binding var isPresented: Bool
    @Environment (\.modalMode) var isPresented
    
    @State private var offsetValue: CGFloat = 0.0
    
//    @FetchRequest(fetchRequest: Bottle.getAll()) var bottles:FetchedResults<Bottle>
//    @FetchRequest(fetchRequest: Location.getAll()) var locations:FetchedResults<Location>
//    @FetchRequest(fetchRequest: Category.getAll()) var categories:FetchedResults<Category>
    
    @State private var open: Bool = false
    
    @State private var multiple: Int = 1
    
    @State var locationSectionState: Bool = false
    @State var categorySectionState: Bool = false
    @State var locationAdderPopover: Bool = false
    @State var categoryAdderPopover: Bool = false
    
    @State var newLocationName:String = ""
    @State var newLocationColor:Color = Color(red:0,green:1,blue:0)
    @State var newCategoryName:String = ""
    @State var newCategoryColor:Color = Color(red:1,green:0,blue:0)

    let openBool = [false,true]
    let opens = ["Sealed","Open"]
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading) {
                    Text("Name")
                    .modifier(DismissingKeyboard())
                    TextField("Enter Name", text: $name)
                        .font(.headline)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.words/*@END_MENU_TOKEN@*/)
//                        .introspectTextField { textField in
//                            if !self.locationSectionState && !self.categorySectionState && !self.locationAdderPopover && !self.categoryAdderPopover && self.name.isEmpty {
//                                textField.becomeFirstResponder()
//                            }
//                        }
                }
                
                VStack(alignment: .leading) {
                    Text("Description")
                    .modifier(DismissingKeyboard())
                    TextField("Enter Description", text: $desc)
                        .font(.headline)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.words/*@END_MENU_TOKEN@*/)
                }
                
                Group {
                    HStack(alignment: .center) {
                        HStack {
                            Text("Location ")
                            if locations.count==0 {
                                Spacer()
                            }
                            Text("\(locationAdderPopover ? "Cancel" : "Add New")")
                                .foregroundColor(Color.blue)
                        }
                        .onTapGesture {
                            if self.locationAdderPopover {
                                self.dismissKeyboard()
                            }
                            self.locationAdderPopover.toggle()
                            self.locationSectionState = false
                        }
                        
                        Spacer()
                        if locations.count>0 {
                            Group {
                                Text("\(locations[selectedLocation].wName)")
                                    .font(.headline)
                                    .padding(.leading, 10)
                                Image(systemName: locationSectionState ? "chevron.up" : "chevron.down")
                            }
                            .onTapGesture {
                                if self.locationAdderPopover {
                                    self.dismissKeyboard()
                                }
                                self.locationAdderPopover = false
                                self.locationSectionState.toggle()
                            }
                            .foregroundColor(locationSectionState ? Color.blue : Color.primary)
                        }
                    }
                    if locationAdderPopover {
                        GroupMaker(groupName: self.$newLocationName, groupColor: self.$newLocationColor, groupTitle: "Location")
                    } else if (locationSectionState && locations.count>0) {
                        Picker("Location",selection: $selectedLocation) {
                            ForEach(0 ..< locations.count) {
                                Text(self.locations[$0].wName)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(height: 150)
                        .padding()
                    }
                }
                
                Group {
                    HStack(alignment: .center) {
                        HStack {
                            Text("Category")
                            if categories.count==0 {
                                Spacer()
                            }
                            Text("\(categoryAdderPopover ? "Cancel" : "Add New")")
                                .foregroundColor(Color.blue)
                        }
                        .onTapGesture {
                            if self.categoryAdderPopover {
                                self.dismissKeyboard()
                            }
                            self.categoryAdderPopover.toggle()
                            self.categorySectionState = false
                        }
                        Spacer()
                        if categories.count>0 {
                            Group {
                                Text("\(categories[selectedCategory].wName)")
                                    .font(.headline)
                                    .padding(.leading, 10)
                                Image(systemName: categorySectionState ? "chevron.up" : "chevron.down")
                            }
                            .onTapGesture {
                                if self.categoryAdderPopover {
                                    self.dismissKeyboard()
                                }
                                self.categoryAdderPopover = false
                                self.categorySectionState.toggle()
                            }
                            .foregroundColor(categorySectionState ? Color.blue : Color.primary)
                        }
                    }
                    if categoryAdderPopover {
                        GroupMaker(groupName: self.$newCategoryName, groupColor: self.$newCategoryColor, groupTitle: "Category")
                    } else if (categorySectionState && categories.count>0) {
                        Picker("Category",selection: $selectedCategory) {
                            ForEach(0 ..< categories.count) {
                                Text(self.categories[$0].wName)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(height: 150)
                        .padding()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Bottle is")
                    .modifier(DismissingKeyboard())
                    Picker("Bottle is", selection: $selectedOpen) {
                        ForEach(0 ..< 2) {
                            Text(self.opens[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, -5)
                }
                
                StepperField(value: $capacity, range: 500...1000, step: 250, hint: "Capacity", unit: "ml")
                
                if !edit {
                    StepperField(value: $multiple, range: 1...1000, step: 1, hint: "Add", unit: "Bottle", plural: true)
                }
            }
//            .padding(.bottom, self.keyboard.currentHeight)
            .navigationBarTitle(Text("\( edit ? "Edit" : "Add" ) \(name)"))
            .navigationBarItems(leading:
                Button(action: {
                    self.dismissKeyboard()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing:
                Button(action: {
                    if !self.name.isEmpty {
                        self.dismissKeyboard()
                        if !self.edit {
                            if self.multiple>0 {
                                for _ in (1...self.multiple) {
                                    let newBottle = Bottle(context: self.context)
                                    
                                    newBottle.name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                                    newBottle.desc = self.desc.trimmingCharacters(in: .whitespacesAndNewlines)
                                    newBottle.capacity = Int16(self.capacity)
                                    newBottle.open = self.openBool[self.selectedOpen]
                                    
                                    if self.locationAdderPopover {
                                        newBottle.location = Location(context: self.context)
                                        newBottle.location?.name = self.newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        newBottle.location?.color = self.newLocationColor.description
                                    } else {
                                        newBottle.location = self.locations[self.selectedLocation]
                                    }
                                    
                                    if self.categoryAdderPopover {
                                        newBottle.category = Category(context: self.context)
                                        newBottle.category?.name = self.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        newBottle.category?.color = self.newCategoryColor.description
                                    } else {
                                        newBottle.category = self.categories[self.selectedCategory]
                                    }
                                }
//                                try? self.context.save()
//                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            self.bottles[self.selectedBottle].name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            self.bottles[self.selectedBottle].desc = self.desc.trimmingCharacters(in: .whitespacesAndNewlines)
                            self.bottles[self.selectedBottle].capacity = Int16(self.capacity)
                            self.bottles[self.selectedBottle].open = self.openBool[self.selectedOpen]
                            
                            if self.locationAdderPopover {
                                self.bottles[self.selectedBottle].location = Location(context: self.context)
                                self.bottles[self.selectedBottle].location?.name = self.newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
                                self.bottles[self.selectedBottle].location?.color = self.newLocationColor.description
                            } else {
                                self.bottles[self.selectedBottle].location = self.locations[self.selectedLocation]
                            }
                            
                            if self.categoryAdderPopover {
                                self.bottles[self.selectedBottle].category = Category(context: self.context)
                                self.bottles[self.selectedBottle].category?.name = self.newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                                self.bottles[self.selectedBottle].category?.color = self.newCategoryColor.description
                            } else {
                                self.bottles[self.selectedBottle].category = self.categories[self.selectedCategory]
                            }
                        }
                        try? self.context.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
                        .disabled( self.name.isEmpty || !(self.multiple>0) || (!self.locationAdderPopover && self.locations.count==0) || (self.locationAdderPopover && self.newLocationName.isEmpty) || (!self.categoryAdderPopover && self.categories.count==0) || (self.categoryAdderPopover && self.newCategoryName.isEmpty) )
                }
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func dismissKeyboard() {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.endEditing(true)
    }
}

//extension UIApplication {
//    var isKeyboardPresented: Bool {
//        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
//            self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
//            return true
//        } else {
//            return false
//        }
//    }
//}
