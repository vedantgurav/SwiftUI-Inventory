//
//  ModalDismiss.swift
//  Bottles
//
//  Created by Vedant Gurav on 30/04/20.
//  Copyright © 2020 Vedant Gurav. All rights reserved.
//

import SwiftUI

// define env key to store our modal mode values
struct ModalModeKey: EnvironmentKey {
    static let defaultValue = Binding<Bool>.constant(false) // < required
}

// define modalMode value
extension EnvironmentValues {
    var modalMode: Binding<Bool> {
        get {
            return self[ModalModeKey.self]
        }
        set {
            self[ModalModeKey.self] = newValue
        }
    }
}


struct ParentModalTest: View {
  @State var showModal: Bool = false

  var body: some View {
    Button(action: {
      self.showModal.toggle()
    }) {
      Text("Launch Modal")
    }
    .sheet(isPresented: self.$showModal, onDismiss: {
    }) {
      PageOneContent()
        .environment(\.modalMode, self.$showModal) // < bind modalMode
    }
  }
}

struct PageOneContent: View {
//@Binding var modalMode:Bool
  var body: some View {
    NavigationView {
      VStack {
        Text("I am Page One")
      }
      .navigationBarTitle("Page One")
      .navigationBarItems(
        trailing: NavigationLink(destination: PageTwoContent()) {
          Text("Next")
        })
      }
  }
}

struct PageTwoContent: View {

  @Environment (\.modalMode) var modalMode // << extract modalMode
//    @Binding var modalMode:Bool

  var body: some View {
    NavigationView {
      VStack {
        Text("This should dismiss the modal. But it just pops the NavigationView")
          .padding()

        Button(action: {
            self.modalMode.wrappedValue = false // << close modal
        }) {
          Text("Finish")
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
      }
      .navigationBarTitle("Page Two")
    }
  }
}
