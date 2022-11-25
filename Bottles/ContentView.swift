//
//  ContentView.swift
//  Bottles
//
//  Created by Vedant Gurav on 08/03/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI
import MobileCoreServices

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: Bottle.getAll()) var bottles:FetchedResults<Bottle>
    @FetchRequest(fetchRequest: Location.getAll()) var locations:FetchedResults<Location>
    @FetchRequest(fetchRequest: Category.getAll()) var categories:FetchedResults<Category>
    @FetchRequest(fetchRequest: Bottle.getOpen(open: true)) var openBottles:FetchedResults<Bottle>
    @FetchRequest(fetchRequest: Bottle.getOpen(open: false)) var sealedBottles:FetchedResults<Bottle>
    @FetchRequest(fetchRequest: Bottle.getHidden()) var hiddenBottles:FetchedResults<Bottle>
    @FetchRequest(fetchRequest: Settings.getSettings()) var settingsArray:FetchedResults<Settings>

    @State private var currentTab = 0
    @State private var bottleAdd = false
    @State private var locationAdd = false
    @State private var categoryAdd = false
    @State private var bottleEdit = false
    @State private var locationEdit = false
    @State private var categoryEdit = false

    @ObservedObject var keyboard = KeyboardResponder()

    var deleteIndexSet:IndexSet = []

    @State private var locationEditObject:Location = Location()
    @State private var categoryEditObject:Category = Category()

    @State var newName:String = ""
    @State var newLocationColor:Color = Color(red:1,green:0,blue:0)
    @State var newCategoryColor:Color = Color(red:1,green:0,blue:0)
    
    @State private var isFilePickerShown = false
    @State private var picker = DocumentPicker()

    @State private var searchText = ""
    
    @State private var groupRename = false
    @State private var groupRenameName = ""

    var body: some View {

        let groups = Dictionary(grouping: self.bottles, by: { $0.wName }).map{ $0.value }.sorted(by: { $0[0].wName < $1[0].wName })

        if self.settingsArray.count == 0 {
            let newSettings = Settings(context: self.context)
            newSettings.hiding = true
            newSettings.searching = true
            newSettings.showDesc = true
            newSettings.separateGroup = false
            try? self.context.save()
        }

        var settings: Settings {
            return settingsArray[0]
        }

        let hiding = Binding<Bool>(get: {
            settings.hiding
        }, set: {
            settings.hiding = $0
            try? self.context.save()
        })

        let showDesc = Binding<Bool>(get: {
            settings.showDesc
        }, set: {
            settings.showDesc = $0
            try? self.context.save()
        })

        let searching = Binding<Bool>(get: {
            settings.searching
        }, set: {
            settings.searching = $0
            try? self.context.save()
        })

        let separateGroup = Binding<Bool>(get: {
            settings.separateGroup
        }, set: {
            settings.separateGroup = $0
            try? self.context.save()
        })
        
        var ListTabView: some View {
            NavigationView {
                GroupListView (
                    showDesc: settings.showDesc,
                    keyboard: self.keyboard
                )
                .padding(.bottom, keyboard.currentHeight)
                .edgesIgnoringSafeArea(keyboard.currentHeight == 0 ? .leading : .bottom)
                .environment(\.managedObjectContext, self.context)
                .navigationBarTitle(Text("Bottles"))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        
        var LocationsTabView: some View {
            NavigationView {
                Group {
                    if self.locations.count == 0 {
                        Button( action: {
                            self.newName = ""
                            self.newLocationColor = Color(red:1,green:0,blue:0)
                            self.locationAdd.toggle()
                        }) {
                            Text("New Location")
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.systemBackground))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                            )
                        }
                    } else {
                        List {
                            Section {
                                ForEach(self.locations, id: \.self) { location in
                                    NavigationLink(
                                        destination: GroupListView(
                                            filter: true,
                                            filterKey: 0,
                                            filterValue: location.wName,
                                            groupIndex: self.locations.firstIndex(of: location)!,
                                            showDesc: settings.showDesc,
                                            keyboard: self.keyboard
                                        )
                                        .navigationBarTitle(Text(location.wName))
                                    ) {
                                        GroupItemView(
                                            name: location.wName,
                                            color: location.wColor,
                                            count: (settings.hiding ? location.bottleArray.filter{ $0.hidden == false }.count : location.bottleArray.count)
                                        )
                                        .contextMenu {
                                            Button(action: {
                                                self.locationEdit = true
                                                self.newName = location.wName
                                                self.newLocationColor = Color(red:1, green:0, blue:0)
                                                self.locationEditObject = location
                                                self.locationAdd.toggle()
                                            }) {
                                                Text("Edit")
                                                Image(systemName: "pencil")
                                                    .imageScale(.small)
                                            }
                                            if settings.hiding {
                                                Button(action: {
                                                    location.bottleArray.forEach { groupBottle in
                                                        groupBottle.hidden = true
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Hide All")
                                                    Image(systemName: "eye.slash")
                                                        .imageScale(.small)
                                                }
                                                Button(action: {
                                                    location.bottleArray.forEach { groupBottle in
                                                        groupBottle.hidden = false
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Unhide All")
                                                    Image(systemName: "eye")
                                                        .imageScale(.small)
                                                }
                                            }
                                            Button(action: {
                                                let index = self.locations.firstIndex(of: location)
                                                self.deleteLocation(at: [index!])
                                            }) {
                                                Text("Delete All")
                                                Image(systemName: "trash")
                                                    .imageScale(.small)
                                            }
                                        }
                                    }
                                }
                            }

                            Section {
                                if settings.hiding ? self.sealedBottles.filter{ $0.hidden == false }.count>0 : self.sealedBottles.count>0 {
                                    NavigationLink(
                                        destination: GroupListView(
                                            filter: true,
                                            filterKey: 2,
                                            showDesc: settings.showDesc,
                                            keyboard: self.keyboard
                                        )
                                        .navigationBarTitle(Text("Sealed"))
                                    ) {
                                        HStack(alignment: .center) {
                                            Text("Sealed")
                                                .font(.headline)
                                            Spacer()
                                            CircleTextView(text: "\( settings.hiding ? self.sealedBottles.filter{ $0.hidden == false }.count : self.sealedBottles.count )", color: Color.primary, radius: 30, padding: 10, fill: true)
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                self.toggleBottleGroup(in: self.sealedBottles)
                                            }) {
                                                Text("Open")
                                                Image(systemName: "tray.and.arrow.up.fill")
                                                    .imageScale(.small)
                                            }
                                            if settings.hiding {
                                                Button(action: {
                                                    self.sealedBottles.forEach { groupBottle in
                                                        groupBottle.hidden = true
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Hide All")
                                                    Image(systemName: "eye.slash")
                                                        .imageScale(.small)
                                                }
                                                Button(action: {
                                                    self.sealedBottles.forEach { groupBottle in
                                                        groupBottle.hidden = false
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Unhide All")
                                                    Image(systemName: "eye")
                                                        .imageScale(.small)
                                                }
                                            }
                                            Button(action: {
                                                self.deleteBottleGroup(in: self.sealedBottles)
                                            }) {
                                                Text("Delete All")
                                                Image(systemName: "trash")
                                                    .imageScale(.small)
                                            }
                                        }
                                    }
                                }

                                if settings.hiding ? self.openBottles.filter{ $0.hidden == false }.count>0 : self.openBottles.count>0 {
                                    NavigationLink(
                                        destination: GroupListView(
                                            filter: true,
                                            filterKey: 3,
                                            showDesc: settings.showDesc,
                                            keyboard: self.keyboard
                                        )
                                        .navigationBarTitle(Text("Open"))
                                    ) {
                                        HStack(alignment: .center) {
                                            Text("Open")
                                                .font(.headline)
                                            Spacer()
                                            CircleTextView(text: "\( settings.hiding ? self.openBottles.filter{ $0.hidden == false }.count : self.openBottles.count )", color: Color.primary, radius: 30, padding: 10, fill: false)
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                self.toggleBottleGroup(in: self.openBottles)
                                            }) {
                                                Text("Seal")
                                                Image(systemName: "tray.and.arrow.down.fill")
                                                    .imageScale(.small)
                                            }
                                            if settings.hiding {
                                                Button(action: {
                                                    self.openBottles.forEach { groupBottle in
                                                        groupBottle.hidden = true
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Hide All")
                                                    Image(systemName: "eye.slash")
                                                        .imageScale(.small)
                                                }
                                                Button(action: {
                                                    self.openBottles.forEach { groupBottle in
                                                        groupBottle.hidden = false
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Unhide All")
                                                    Image(systemName: "eye")
                                                        .imageScale(.small)
                                                }
                                            }
                                            Button(action: {
                                                self.deleteBottleGroup(in: self.openBottles)
                                            }) {
                                                Text("Delete All")
                                                Image(systemName: "trash")
                                                    .imageScale(.small)
                                            }
                                        }
                                    }
                                }

                                if self.hiddenBottles.count>0 && settings.hiding {
                                    NavigationLink(
                                        destination: GroupListView(
                                            filter: true,
                                            filterKey: 4,
                                            showDesc: settings.showDesc,
                                            keyboard: self.keyboard
                                        )
                                        .navigationBarTitle(Text("Hidden"))
                                    ) {
                                        HStack(alignment: .center) {
                                            Text("Hidden")
                                                .font(.headline)
                                            Spacer()
                                            CircleTextView(text: "\(self.hiddenBottles.count)", color: Color.red, radius: 30, padding: 10, fill: false)
                                        }
                                        .contextMenu {
                                            Button(action: {
                                                self.toggleHideAll(in: self.hiddenBottles)
                                            }) {
                                                Text("Unhide All")
                                                Image(systemName: "eye")
                                                    .imageScale(.small)
                                            }
                                        }
                                    }
                                }


                                HStack(alignment: .center) {
                                    Text("Total")
                                        .font(.headline)
                                    Spacer()
                                    CircleTextView(text: "\(self.bottles.count)", color: Color.green, radius: 30, padding: 10, fill: true)
                                    Image(systemName: "chevron.right")
                                        .imageScale(.small)
                                        .foregroundColor(Color(.systemGray2))
                                }
                                .onTapGesture {
                                    self.currentTab = 0
                                }
                                .contextMenu {
                                    Button( action: {
                                        self.context.undo()
                                        try? self.context.save()
                                    }) {
                                        Text("Undo")
                                        Image(systemName: "arrow.uturn.left")
                                    }
                                    Button( action: {
                                        self.context.redo()
                                        try? self.context.save()
                                    }) {
                                        Text("Redo")
                                        Image(systemName: "arrow.uturn.right")
                                    }
                                    if settings.hiding {
                                        Button(action: {
                                            self.bottles.forEach { groupBottle in
                                                groupBottle.hidden = true
                                            }
                                            try? self.context.save()
                                        }) {
                                            Text("Hide All")
                                            Image(systemName: "eye.slash")
                                                .imageScale(.small)
                                        }
                                        Button(action: {
                                            self.bottles.forEach { groupBottle in
                                                groupBottle.hidden = false
                                            }
                                            try? self.context.save()
                                        }) {
                                            Text("Unhide All")
                                            Image(systemName: "eye")
                                                .imageScale(.small)
                                        }
                                    }
                                    Button(action: {
                                        self.deleteBottleGroup(in: self.bottles)
                                    }) {
                                        Text("Delete All")
                                        Image(systemName: "trash")
                                            .imageScale(.small)
                                    }
                                }
                            }
                        }
                        .id(UUID())
                        .listStyle(GroupedListStyle())
                    }
                }
                .navigationBarTitle(Text("Locations"))
                .navigationBarItems(
                    leading: HStack {
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
                    },

                    trailing: Button( action: {
                        self.newName = ""
                        self.newLocationColor = Color(red:1,green:0,blue:0)
                        self.locationEdit = false
                        self.locationAdd.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                )
                .sheet(isPresented: $locationAdd) {
                    NavigationView {
                        GroupMaker(groupName: self.$newName, groupColor: self.$newLocationColor, groupTitle: "Location", form: true)
                            .navigationBarTitle("\(locationEdit ? "Edit":"Add") \(self.newName)")
                        .navigationBarItems(leading:
                            Button(action: {
                                self.dismissKeyboard()
                                self.newName = ""
                                self.newLocationColor = Color(red:1,green:0,blue:0)
                                self.locationAdd = false
                            }) {
                                Text("Cancel")
                            },
                            trailing:
                            Button(action: {
                                self.dismissKeyboard()
                                self.locationAdd = false
                                if !self.newName.isEmpty {
                                    if self.locationEdit {
                                        self.locationEditObject.name = self.newName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        self.locationEditObject.color = self.newLocationColor.description
                                    } else {
                                        let newLocation = Location(context: self.context)
                                        newLocation.name = self.newName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        newLocation.color = self.newLocationColor.description
                                    }
                                    try? self.context.save()
                                }
                                self.newName = ""
                                self.newLocationColor = Color(red:1,green:0,blue:0)
                                self.locationEdit = false
                            }) {
                                Text("Save")
                                    .disabled( self.newName.isEmpty )
                            }
                        )
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
        }
        
        var CategoriesTabView: some View {
            NavigationView {
                Group {
                    if self.categories.count == 0 {
                        Button( action: {
                            self.newName = ""
                            self.newCategoryColor = Color(red:1,green:0,blue:0)
                            self.categoryAdd.toggle()
                        }) {
                            Text("New Category")
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.systemBackground))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                            )
                        }
                    } else {
                        List {
                            Section {
                                ForEach(self.categories, id: \.self) { category in
                                    NavigationLink(
                                        destination: GroupListView(
                                            filter: true,
                                            filterKey: 1,
                                            filterValue: category.wName,
                                            groupIndex: self.categories.firstIndex(of: category)!,
                                            showDesc: settings.showDesc,
                                            keyboard: self.keyboard
                                        )
                                        .navigationBarTitle(Text(category.wName))
                                    ) {
                                        GroupItemView(
                                            name: category.wName,
                                            color: category.wColor,
                                            count: (settings.hiding ? category.bottleArray.filter{ $0.hidden == false }.count : category.bottleArray.count)
                                        )
                                        .contextMenu {
                                            Button(action: {
                                                self.categoryEdit = true
                                                self.newName = category.wName
                                                self.newCategoryColor = Color(red:1, green:0, blue:0)
                                                self.categoryEditObject = category
                                                self.categoryAdd.toggle()
                                            }) {
                                                Text("Edit")
                                                Image(systemName: "pencil")
                                                    .imageScale(.small)
                                            }
                                            if settings.hiding {
                                                Button(action: {
                                                    category.bottleArray.forEach { groupBottle in
                                                        groupBottle.hidden = true
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Hide All")
                                                    Image(systemName: "eye.slash")
                                                        .imageScale(.small)
                                                }
                                                Button(action: {
                                                    category.bottleArray.forEach { groupBottle in
                                                        groupBottle.hidden = false
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Unhide All")
                                                    Image(systemName: "eye")
                                                        .imageScale(.small)
                                                }
                                            }
                                            Button(action: {
                                                let index = self.categories.firstIndex(of: category)
                                                self.deleteCategory(at: [index!])
                                            }) {
                                                Text("Delete All")
                                                Image(systemName: "trash")
                                                    .imageScale(.small)
                                            }
                                        }
                                    }
                                }
                            }

                            if !settings.separateGroup {
                                Section {
                                    ForEach(groups, id: \.self) { group in
                                        NavigationLink(
                                            destination: GroupListView(
                                                filter: true,
                                                filterKey: 5,
                                                filterValue: group[0].wName,
                                                showDesc: settings.showDesc,
                                                keyboard: self.keyboard
                                            )
                                            .navigationBarTitle(Text(group[0].wName))
                                        ) {
                                            GroupItemView(
                                                name: group[0].wName,
                                                color: group[0].category?.color ?? "#FFFFFF",
                                                count: (settings.hiding ? group.filter{ $0.hidden == false }.count : group.count)
                                            )
                                            .contextMenu {
                                                if settings.hiding {
                                                    Button(action: {
                                                        group.forEach { groupBottle in
                                                            groupBottle.hidden = true
                                                        }
                                                        try? self.context.save()
                                                    }) {
                                                        Text("Hide All")
                                                        Image(systemName: "eye.slash")
                                                            .imageScale(.small)
                                                    }
                                                    Button(action: {
                                                        group.forEach { groupBottle in
                                                            groupBottle.hidden = false
                                                        }
                                                        try? self.context.save()
                                                    }) {
                                                        Text("Unhide All")
                                                        Image(systemName: "eye")
                                                            .imageScale(.small)
                                                    }
                                                }
                                                Button(action: {
                                                    group.forEach { groupBottle in
                                                        print(groupBottle.wName)
                                                        self.context.delete(groupBottle)
                                                    }
                                                    try? self.context.save()
                                                }) {
                                                    Text("Delete All")
                                                    Image(systemName: "trash")
                                                        .imageScale(.small)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .id(UUID())
                        .listStyle(GroupedListStyle())
                    }
                }
                .navigationBarTitle(Text("Categories"))
                .navigationBarItems(
                    leading: HStack {
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
                    },

                    trailing: Button( action: {
                        self.newName = ""
                        self.newCategoryColor = Color(red:1,green:0,blue:0)
                        self.categoryEdit = false
                        self.categoryAdd.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                )
                .sheet(isPresented: $categoryAdd) {
                    NavigationView {
                        GroupMaker(groupName: self.$newName, groupColor: self.$newCategoryColor, groupTitle: "Category", form: true)
                            .navigationBarTitle("\(categoryEdit ? "Edit" : "Add") \(self.newName)")
                        .navigationBarItems(leading:
                            Button(action: {
                                self.dismissKeyboard()
                                self.newName = ""
                                self.newCategoryColor = Color(red:1,green:0,blue:0)
                                self.categoryAdd = false
                            }) {
                                Text("Cancel")
                            },
                            trailing:
                            Button(action: {
                                self.dismissKeyboard()
                                if self.categoryEdit {
                                    self.categoryEditObject.name = self.newName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    self.categoryEditObject.color = self.newCategoryColor.description
                                } else {
                                    let newCategory = Category(context: self.context)
                                    newCategory.name = self.newName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    newCategory.color = self.newCategoryColor.description
                                }

                                try? self.context.save()

                                self.newName = ""
                                self.newCategoryColor = Color(red:1,green:0,blue:0)
                                self.categoryEdit = false
                                self.categoryAdd = false
                            }) {
                                Text("Save")
                                    .disabled( self.newName.isEmpty )
                            }
                        )
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            }
        }

        return TabView(selection: $currentTab) {

            
            ListTabView
                .tabItem {
                VStack {
                    Image(systemName: "list.bullet")
                        .imageScale(.large)
                    Text("List")
                }
            }
            .tag(0)

            LocationsTabView
            .tabItem {
                VStack {
                    Image(systemName: "archivebox.fill")
                        .imageScale(.large)
                    Text("Locations")
                }
            }
            .tag(1)

            CategoriesTabView
            .tabItem {
                VStack {
                    Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        .imageScale(.large)
                    Text("Categories")
                }
            }
            .tag(2)

            if settings.separateGroup {
                NavigationView() {
                    List {
                        Section {
                            ForEach(groups, id: \.self) { group in
                                NavigationLink(
                                    destination: GroupListView(
                                        filter: true,
                                        filterKey: 5,
                                        filterValue: group[0].wName,
                                        showDesc: settings.showDesc,
                                        keyboard: self.keyboard
                                    )
                                    .navigationBarTitle(Text(group[0].wName))
                                ) {
                                    GroupItemView(
                                        name: group[0].wName,
                                        color: group[0].category?.color ?? "#FFFFFF",
                                        count: (settings.hiding ? group.filter{ $0.hidden == false }.count : group.count)
                                    )
                                    .contextMenu {
                                        if settings.hiding {
                                            Button(action: {
                                                group.forEach { groupBottle in
                                                    groupBottle.hidden = true
                                                }
                                                try? self.context.save()
                                            }) {
                                                Text("Hide All")
                                                Image(systemName: "eye.slash")
                                                    .imageScale(.small)
                                            }
                                            Button(action: {
                                                group.forEach { groupBottle in
                                                    groupBottle.hidden = false
                                                }
                                                try? self.context.save()
                                            }) {
                                                Text("Unhide All")
                                                Image(systemName: "eye")
                                                    .imageScale(.small)
                                            }
                                        }
                                        Button(action: {
                                            group.forEach { groupBottle in
                                                print(groupBottle.wName)
                                                self.context.delete(groupBottle)
                                            }
                                            try? self.context.save()
                                        }) {
                                            Text("Delete All")
                                            Image(systemName: "trash")
                                                .imageScale(.small)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .id(UUID())
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle(Text("Grouped"))
                    .navigationBarItems(
                        leading:
                        HStack {
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
                        }
                    )
                }
                .tabItem {
                    VStack {
                        Image(systemName: "text.justifyleft")
                            .imageScale(.large)
                        Text("Grouped")
                    }
                }
                .tag(3)
            }


            NavigationView() {
                Form {
                    Section {
                        Toggle(isOn: hiding) {
                            Text("Hide Bottles")
                        }
                        Toggle(isOn: showDesc) {
                            Text("Show Descriptions")
                        }
                        Toggle(isOn: searching) {
                            Text("Show Search")
                        }
                        Toggle(isOn: separateGroup) {
                            Text("Show Grouped Tab")
                        }
                    }
                    Section {
                        Button( action: {
                            var data:String = "{\n\t\"device\": \"\(UIKit.UIDevice.current.name)\",\n\t\"date\": \"\(Date())\",\n\t\"bottleCount\": \(self.bottles.count),\n\t\"locationCount\": \(self.locations.count),\n\t\"categoryCount\": \(self.categories.count),"

                            if self.bottles.count>0 {
                                data.append("\n\t\"bottles\": [")
                                for i in 0...self.bottles.count-1 {
                                    data.append(
                                    """
                                    \n\t\t{
                                        \t\t\"name\": \"\(self.bottles[i].wName)\",
                                        \t\t\"desc\": \"\(self.bottles[i].wDesc.isEmpty ? "nil" : self.bottles[i].wDesc)\",
                                        \t\t\"open\": \(self.bottles[i].open),
                                        \t\t\"hidden\": \(self.bottles[i].hidden),
                                        \t\t\"capacity\": \(self.bottles[i].capacity),
                                        \t\t\"location\": { \"name\": \"\(self.bottles[i].location!.wName)\", \"color\": \"\(self.bottles[i].location!.wColor)\" },
                                        \t\t\"category\": { \"name\": \"\(self.bottles[i].category!.wName)\", \"color\": \"\(self.bottles[i].category!.wColor)\" }
                                    \t\t}
                                    """
                                    )
                                    if i != self.bottles.count-1 {
                                      data.append(",")
                                    }
                                }
                                data.append("\n\t]")
                            }
                            
                            if self.locations.count>0 {
                                if self.bottles.count>0 {
                                    data.append(",")
                                }
                                data.append("\n\t\"locations\": [")
                                for i in 0...self.locations.count-1 {
                                    data.append("\n\t\t{ \"name\": \"\(self.locations[i].wName)\", \"color\": \"\(self.locations[i].wColor)\" }")
                                    if i != self.locations.count-1 {
                                      data.append(",")
                                    }
                                }
                                data.append("\n\t]")
                            }
                            
                            if self.categories.count>0 {
                                if self.bottles.count>0 || self.locations.count>0 {
                                    data.append(",")
                                }
                                data.append("\n\t\"categories\": [")
                                for i in 0...self.categories.count-1 {
                                    data.append("\n\t\t{ \"name\": \"\(self.categories[i].wName)\", \"color\": \"\(self.categories[i].wColor)\" }")
                                    if i != self.categories.count-1 {
                                      data.append(",")
                                    }
                                }
                                data.append("\n\t]")
                            }
                            data.append("\n}")

                            UIPasteboard.general.string = data
                            let filename = self.getDocumentsDirectory().appendingPathComponent("JSON \(self.getExportName()).json")
                            try? data.description.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                            print(filename)
//                            print(data)
//                            UIPasteboard.general.url = filename
                            if UIDevice.current.userInterfaceIdiom != .pad {
                                let activityViewController = UIActivityViewController(activityItems: [filename], applicationActivities: nil)
                                UIApplication.shared.windows.first?.rootViewController!.present(activityViewController, animated: true, completion: nil)
                            }

                        }) {
                            Text("Export to JSON")
                        }
                        .disabled(self.bottles.count == 0 && self.locations.count == 0 && self.categories.count == 0)
                    }
                    Section {
                        Button( action: {
                            var collection = ["export": [
                                    "device": UIKit.UIDevice.current.name,
                                    "date": Date(),
                                    "bottles": self.bottles.count,
                                    "locations": self.locations.count,
                                    "categories": self.categories.count
                                ] as [String:Any]
                            ] as [String:Any]

                            var data:[Any] = []

                            if self.bottles.count>0 {
                                for i in 0...self.bottles.count-1 {
                                    data.append([
                                        "name": self.bottles[i].wName,
                                        "desc": self.bottles[i].wDesc,
                                        "open": self.bottles[i].open,
                                        "hidden": self.bottles[i].hidden,
                                        "capacity": self.bottles[i].capacity,
                                        "location": ["name": self.bottles[i].location!.wName, "color": self.bottles[i].location!.wColor] as [String:String],
                                        "category": ["name": self.bottles[i].category!.wName, "color": self.bottles[i].category!.wColor] as [String:String]
                                    ] as [String:Any])
                                }
                            }

                            collection["data"] = data

                            let fullPath = self.getDocumentsDirectory().appendingPathComponent("Export \(self.getExportName()).obj")

                            do {
                                let exportData = try NSKeyedArchiver.archivedData(withRootObject: collection, requiringSecureCoding: false)
                                try exportData.write(to: fullPath)
//                                let copyData = try Data(contentsOf: fullPath)
//                                UIPasteboard.general.setData(copyData, forPasteboardType: kUTTypeItem as String)
//                                UIPasteboard.general.setData(exportData, forPasteBoardType: String)
                                if UIDevice.current.userInterfaceIdiom != .pad {
                                    let activityViewController = UIActivityViewController(activityItems: [fullPath], applicationActivities: nil)
                                    UIApplication.shared.windows.first?.rootViewController!.present(activityViewController, animated: true, completion: nil)
                                }
                            } catch {
                                print("Couldn't write file")
                            }

                        }) {
                            Text("Export Data")
                        }
                        .disabled(self.bottles.count == 0 || UIDevice.current.userInterfaceIdiom == .pad)


                        Button( action: {
                            self.isFilePickerShown.toggle()
                            #if targetEnvironment(macCatalyst)
                            UIApplication.shared.windows[0].rootViewController!.present(self.picker.viewController, animated: true)
                            #endif
                        }) {
                            Text("Import Data")
                        }
                        .sheet(isPresented: $isFilePickerShown, onDismiss: {self.isFilePickerShown = false}) {
                            DocPickerViewController(callback: self.filePicked, onDismiss: { self.isFilePickerShown = false })
                            .edgesIgnoringSafeArea(.bottom)
                        }
                    


                    }
                }
                .navigationBarTitle(Text("Settings"))
                .navigationBarItems(
                    leading:
                    HStack {
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
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image(systemName: "gear")
                        .imageScale(.large)
                    Text("Settings")
                }
            }
            .tag(4)

        }
    }
    
    func getExportName() -> String {
        let fm = DateFormatter()
        fm.timeStyle = .medium
        fm.dateStyle = .short
        print(fm.string(from: Date()).replacingOccurrences(of: ":", with: "."))
        return fm.string(from: Date()).replacingOccurrences(of: ":", with: ".").replacingOccurrences(of: "/", with: "-")
    }
    
    func filePicked(_ url: URL) {
        print("\nThe url is: \(url)")
        do {
            let exportData = try Data(contentsOf: url)
            if let loaded = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(exportData) as? [String:Any] {
                let exportLoaded = loaded["data"] as? [[String:Any]]

                exportLoaded?.forEach { bottle in
                    let newBottle = Bottle(context: self.context)
                    newBottle.name = bottle["name"] as? String
                    newBottle.desc = bottle["desc"] as? String
                    newBottle.capacity = bottle["capacity"] as! Int16
                    newBottle.open = bottle["open"] as! Bool

                    newBottle.location = Location(context: self.context)
                    let newLocation = bottle["location"] as! [String:String]
                    newBottle.location?.name = newLocation["name"]!
                    if #available(iOS 14.0, *) {
                        newBottle.location?.color = UIColor(hex: newLocation["color"]!)?.adjust(saturationBy: -0.3, brightnessBy: -0.2).toHex(alpha: true) ?? "#FFFFFFFF"
                    } else {
                        newBottle.location?.color = newLocation["color"]!
                    }

                    newBottle.category = Category(context: self.context)
                    let newCategory = bottle["category"] as! [String:String]
                    newBottle.category?.name = newCategory["name"]!
                    if #available(iOS 14.0, *) {
                        newBottle.category?.color = UIColor(hex: newCategory["color"]!)?.adjust(saturationBy: -0.3, brightnessBy: -0.2).toHex(alpha: true) ?? "#FFFFFFFF"
                    } else {
                        newBottle.category?.color = newLocation["color"]!
                    }
                }
                try? self.context.save()
            }
        } catch {
            print("Couldn't read file.")
        }
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

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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

    func deleteBottleGroup(in fr: FetchedResults<Bottle>) {
        fr.forEach { bottle in
            self.context.delete(bottle)
        }
        try? self.context.save()
    }

    func deleteBottleGroupArray(in fr: [Bottle]) {
        fr.forEach { bottle in
            self.context.delete(bottle)
        }
        try? self.context.save()
    }

    func toggleBottleGroup(in fr: FetchedResults<Bottle>) {
        for index in 0...fr.count-1 {
            fr[index].open.toggle()
        }
        try? self.context.save()
    }

    func deleteLocation(at offsets: IndexSet) {
        offsets.forEach { index in
            self.locations[index].bottleArray.forEach { bottle in
                self.context.delete(bottle)
            }
            let deleteItem = self.locations[index]
            self.context.delete(deleteItem)
        }
        try? self.context.save()
    }

    func deleteCategory(at offsets: IndexSet) {
        offsets.forEach { index in
            self.categories[index].bottleArray.forEach { bottle in
                self.context.delete(bottle)
            }
            let deleteItem = self.categories[index]
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

    func toggleHideAll(in bottles: FetchedResults<Bottle>) {
        bottles.forEach { bottle in
            bottle.hidden.toggle()
        }
        try? self.context.save()
    }
    
    struct DocPickerViewController: UIViewControllerRepresentable {

        private let docTypes: [String] = ["public.data"]
        var callback: (URL) -> ()
        private let onDismiss: () -> Void

        init(callback: @escaping (URL) -> (), onDismiss: @escaping () -> Void) {
            self.callback = callback
            self.onDismiss = onDismiss
        }

        func makeCoordinator() -> Coordinator { Coordinator(self) }

        func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerViewController>) {
        }

        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let controller = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
            controller.allowsMultipleSelection = false
            controller.delegate = context.coordinator
            return controller
        }

        class Coordinator: NSObject, UIDocumentPickerDelegate {
            var parent: DocPickerViewController
            init(_ pickerController: DocPickerViewController) {
                self.parent = pickerController
            }
            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                parent.callback(urls[0])
                parent.onDismiss()
            }
            func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                parent.onDismiss()
            }
        }
    }
    
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    var toHex: String? {
        return toHex()
    }

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
