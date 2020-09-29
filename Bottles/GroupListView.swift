//
//  GroupListView.swift
//  Bottles
//
//  Created by Vedant Gurav on 31/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

struct GroupListView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: Bottle.getAll()) var bottles:FetchedResults<Bottle>
    @FetchRequest(fetchRequest: Location.getAll()) var locations:FetchedResults<Location>
    @FetchRequest(fetchRequest: Category.getAll()) var categories:FetchedResults<Category>
    var filter:Bool=false
    var filterKey:Int=0
    var filterValue:String=""
    var groupIndex:Int=0
    var showDesc:Bool=false
    var similar:String=""
    var keyboard:KeyboardResponder
    
    @FetchRequest(fetchRequest: Settings.getSettings()) var settingsArray:FetchedResults<Settings>
    
    @State var editName:String = ""
    @State var editDesc:String = ""
    @State var selectedLocation:Int = 0
    @State var selectedCategory:Int = 0
    @State var selectedOpen:Int = 0
    @State var capacity:Int = 750
    @State var selectedBottle:Int = 0
    
    @State private var bottleAdd=false
    @State private var bottleEdit=false
    
    @State private var showMoveShortcuts=true
    
    @State private var searchText : String = ""
    @State private var searchEnabled : Bool = false
    
    var body: some View {
        
        var settings:Settings {
            return settingsArray[0]
        }
        
        var preFilteredBottles: [Bottle] {
            var preFilter: [Bottle]
            preFilter = []
            if filter {
                if filterKey == 0 {
                    preFilter = self.bottles.filter { $0.location?.wName == filterValue && ( !settings.hiding || $0.hidden == false ) }
                } else if filterKey == 1 {
                    preFilter = self.bottles.filter { $0.category?.wName == filterValue && ( !settings.hiding || $0.hidden == false ) }
                }
                if filterKey == 2 {
                    preFilter = self.bottles.filter { $0.open == false && ( !settings.hiding || $0.hidden == false ) }
                } else if filterKey == 3 {
                    preFilter = self.bottles.filter { $0.open == true && ( !settings.hiding || $0.hidden == false ) }
                } else if filterKey == 4 {
                    preFilter = self.bottles.filter { $0.hidden == true }
                } else if filterKey == 5 {
                    preFilter = self.bottles.filter { $0.wName == filterValue && ( !settings.hiding || $0.hidden == false ) }
                }
            } else {
                preFilter = self.bottles.filter { !settings.hiding || $0.hidden == false }
            }
            return preFilter
        }
        
        var filteredBottles: [Bottle] {
            preFilteredBottles.filter {
                self.searchText.isEmpty || !self.searchEnabled ? true : $0.wDesc.lowercased().contains(self.searchText.lowercased()) || $0.wName.lowercased().contains(self.searchText.lowercased())
            }
        }
        
        return Group {
            if !self.searchEnabled && filteredBottles.count == 0 {
                Button( action: {
                    self.bottleAdd = true
                    self.bottleEdit.toggle()
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
            } else {
                
                if !filter && settings.searching && self.searchEnabled {
                    Section(header:
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(.gray))
                                    .padding(.leading, 8)
                                TextField("Search", text: $searchText) {
                                }
                                .introspectTextField { textField in
                                    if self.searchText.isEmpty {
                                        textField.becomeFirstResponder()
                                    }
                                }
                                if !self.searchText.isEmpty {
                                    Image(systemName: "multiply.circle.fill")
                                        .onTapGesture {
                                            self.searchText = ""
                                        }
                                        .padding(.trailing, 8)
                                        .foregroundColor(Color(.gray))
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(Color(.tertiarySystemGroupedBackground))
                                .frame(height: 36)
                            )
                            Button( action: {
                                self.searchText = ""
                                let keyWindow = UIApplication.shared.connectedScenes
                                    .filter({$0.activationState == .foregroundActive})
                                    .map({$0 as? UIWindowScene})
                                    .compactMap({$0})
                                    .first?.windows
                                    .filter({$0.isKeyWindow}).first
                                keyWindow?.endEditing(true)
                                self.searchEnabled = false
                            }) {
                                Text("Cancel")
                                    .font(.body)
                                    .fontWeight(.regular)
                            }
                        }
                        .animation(.default)
                        .padding()
                        .frame(width: UIScreen.screenWidth)
                    ) {
                        EmptyView()
                    }
                }
                
                List {
                    ForEach(filteredBottles, id: \.self) { bottle in
                        ListItemView(
                            name: bottle.name!,
                            desc: bottle.wDesc,
                            showDesc: self.showDesc,
                            open: bottle.open,
                            location: bottle.location ?? Location(),
                            category: bottle.category ?? Category(),
                            capacity: bottle.capacity,
                            filterKey: self.filter ? self.filterKey : -1
                        )
                        .contextMenu {
                            Button(action: {
                                let index = self.bottles.firstIndex(of: bottle)
                                self.toggleBottleOpen(at: [index!])
                            }) {
                                if bottle.open {
                                    Text("Seal")
                                    Image(systemName: "tray.and.arrow.down.fill")
                                        .imageScale(.small)
                                } else {
                                    Text("Open")
                                    Image(systemName: "tray.and.arrow.up.fill")
                                        .imageScale(.small)
                                }
                            }
                            Button(action: {
                                self.bottleAdd = false
                                self.editName = bottle.name!
                                self.editDesc = bottle.wDesc
                                self.selectedLocation = self.locations.firstIndex(of: bottle.location!)!
                                self.selectedCategory = self.categories.firstIndex(of: bottle.category!)!
                                self.selectedOpen = bottle.open ? 1 : 0
                                self.capacity = Int(bottle.capacity)
                                self.selectedBottle = self.bottles.firstIndex(of: bottle) ?? 0
                                self.bottleEdit.toggle()
                            }) {
                                Text("Edit")
                                Image(systemName: "pencil")
                                    .imageScale(.small)
                            }
                            if !self.filter && settings.searching {
                                Button(action: {
                                    self.searchText = bottle.name!
                                    self.searchEnabled = true
                                }) {
                                    Text("Search By")
                                    Image(systemName: "magnifyingglass")
                                        .imageScale(.small)
                                }
                            }
                            Button(action: {
                                let bottle2 = Bottle(context: self.context)
                                bottle2.name = bottle.name
                                bottle2.desc = bottle.desc
                                bottle2.location = bottle.location
                                bottle2.category = bottle.category
                                bottle2.capacity = bottle.capacity
                                bottle2.open = bottle.open
                                bottle2.hidden = bottle.hidden
                                try? self.context.save()
                            }) {
                                Text("Duplicate")
                                Image(systemName: "plus.square.on.square")
                                    .imageScale(.small)
                            }
                            if self.showMoveShortcuts {
                                ForEach(self.locations, id: \.self) { location in
                                    Group {
                                        if bottle.location?.wName != location.wName {
                                            Button(action: {
                                                bottle.location = location
                                                try? self.context.save()
                                            }) {
                                                Text("Move to \(location.wName)")
                                                    .foregroundColor(Color(hex: location.wColor))
                                                Image(systemName: "folder")
                                                    .imageScale(.small)
                                            }
                                        }
                                    }
                                }
                            }
                            if settings.hiding {
                                Button(action: {
                                    bottle.hidden.toggle()
                                }) {
                                    if bottle.hidden {
                                        Text("Unhide")
                                        Image(systemName: "eye")
                                            .imageScale(.small)
                                    } else {
                                        Text("Hide")
                                        Image(systemName: "eye.slash")
                                            .imageScale(.small)
                                    }
                                }
                            }
                            Button(action: {
                                let index = self.bottles.firstIndex(of: bottle)
                                self.deleteBottle(at: [index!])
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                                    .imageScale(.small)
                            }
                        }
                    }
//                    .onDelete(perform: deleteBottle)
                    if filteredBottles.count>0 {
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Text("\( self.filterKey==5 ? filteredBottles[0].category!.wName+" - " : "")\(filteredBottles.count ) Bottle\(filteredBottles.count==1 ? "" : "s")")
                                    .font(.footnote)
                            }
                            Spacer()
                        }
                    }
                }
                .id(UUID())
                .listStyle(PlainListStyle())

                
            }
        }
        .navigationBarItems(
            leading:
            HStack {
                if !filter && settings.searching && ( filteredBottles.count > 0 || self.searchEnabled ) {
                    HStack {
                        Button( action: {
                            self.searchText = ""
                            let keyWindow = UIApplication.shared.connectedScenes
                                .filter({$0.activationState == .foregroundActive})
                                .map({$0 as? UIWindowScene})
                                .compactMap({$0})
                                .first?.windows
                                .filter({$0.isKeyWindow}).first
                            keyWindow?.endEditing(true)
                            self.searchEnabled.toggle()
                        }) {
                            Image(systemName: self.searchEnabled ? "magnifyingglass.circle" : "magnifyingglass.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
//                        .padding(.trailing, 8)
                        
                    }
                }
                if !self.filter {
                    Button( action: {
                        self.context.undo()
                        try? self.context.save()
                    }) {
                        Image(systemName: "arrow.uturn.left.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    }
                    .padding(.leading, (!filter && settings.searching && ( filteredBottles.count > 0 || self.searchEnabled )) ? 8 : 0)
                    .padding(.trailing, 4)
                    Button( action: {
                        self.context.redo()
                        try? self.context.save()
                    }) {
                        Image(systemName: "arrow.uturn.right.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    }
                }
                
            },
            
            trailing:
            HStack {
                if self.filter {
                    Button( action: {
                        self.context.undo()
                        try? self.context.save()
                    }) {
                        Image(systemName: "arrow.uturn.left.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 4)
                    Button( action: {
                        self.context.redo()
                        try? self.context.save()
                    }) {
                        Image(systemName: "arrow.uturn.right.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 8)
                }
                if filterKey != 4 {
                    Button( action: {
                        let keyWindow = UIApplication.shared.connectedScenes
                            .filter({$0.activationState == .foregroundActive})
                            .map({$0 as? UIWindowScene})
                            .compactMap({$0})
                            .first?.windows
                            .filter({$0.isKeyWindow}).first
                        keyWindow?.endEditing(true)
                        self.searchEnabled = false
                        self.bottleAdd = true
                        self.bottleEdit.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .sheet(isPresented: self.$bottleEdit) {
                Group {
                    if self.bottleAdd {
                        if self.filterKey == 5 {
                            EditorView(
                                bottles: self.bottles,
                                locations: self.locations,
                                categories: self.categories,
                                name: filteredBottles[0].wName,
                                selectedCategory: self.categories.firstIndex(of: filteredBottles[0].category!)!,
                                keyboard: self.keyboard
                            ).environment(\.managedObjectContext, self.context)
                        } else {
                            self.editorViewObject
                            
                        }
                    } else {
                        EditorView(
                            bottles: self.bottles,
                            locations: self.locations,
                            categories: self.categories,
                            name: self.editName,
                            desc: self.editDesc,
                            selectedLocation: self.selectedLocation,
                            selectedCategory: self.selectedCategory,
                            selectedOpen: self.selectedOpen,
                            capacity: self.capacity,
                            edit: true,
                            selectedBottle: self.selectedBottle,
                            keyboard: self.keyboard
                        ).environment(\.managedObjectContext, self.context)
                    }
                }
            }
        )
        .navigationBarTitle(Text(self.similar))
    }
    
    var editorViewObject:some View {
        if self.filter {
            if self.filterKey == 0 {
                return EditorView(
                    bottles: self.bottles,
                    locations: self.locations,
                    categories: self.categories,
                    selectedLocation: self.groupIndex,
                    keyboard: self.keyboard
                ).environment(\.managedObjectContext, self.context)
            } else if self.filterKey == 1 {
                return EditorView(
                    bottles: self.bottles,
                    locations: self.locations,
                    categories: self.categories,
                    selectedCategory: self.groupIndex,
                    keyboard: self.keyboard
                ).environment(\.managedObjectContext, self.context)
            } else {
                return EditorView(
                    bottles: self.bottles,
                    locations: self.locations,
                    categories: self.categories,
                    selectedOpen: self.filterKey - 2,
                    keyboard: self.keyboard
                ).environment(\.managedObjectContext, self.context)
            }
        }
        return EditorView(
            bottles: self.bottles,
            locations: self.locations,
            categories: self.categories,
            keyboard: self.keyboard
        ).environment(\.managedObjectContext, self.context)
    }
    
    func toggleBottleOpen(at offsets: IndexSet) {
        var newOpen:Bool = false
        offsets.forEach { index in
            newOpen = self.bottles[index].open
            newOpen.toggle()
            self.bottles[index].open = newOpen
        }
        try? self.context.save()
    }

    func deleteBottle(at offsets: IndexSet) {
        offsets.forEach { index in
            let deleteItem = self.bottles[index]
            self.context.delete(deleteItem)
        }
        try? self.context.save()
    }
    
    func toggleHide(in bottles: [Bottle]) {
        bottles.forEach { bottle in
            bottle.hidden.toggle()
        }
        try? self.context.save()
    }
}
