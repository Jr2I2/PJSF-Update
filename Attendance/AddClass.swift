//
//  AddClass.swift
//  PJSF
//
//  Created by Lim Jun Rui on 3/6/23.
//

import SwiftUI
import FirebaseFirestore

struct AddClass: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var cherName = ""
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name of class", text: $name)
                    TextField("Name of teacher", text:$cherName)
                }
                Section {
                    Button("Save") {
                        tryToAddClass()
                    }
                }
            }
            .navigationTitle("Add Class")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    func tryToAddClass() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        guard !cherName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("User\(userID)").document("Class%\(name)").setData(["Teacher Name":cherName]) { error in
            // If there are no errors
            if error == nil {
                print("Class added")
                NotificationCenter.default.post(name: NSNotification.Name("ViewChanged"), object: nil)
            }
        
        dismiss()
        }
    }
}

struct AddClass_Previews: PreviewProvider {
    static var previews: some View {
        AddClass()
    }
}
