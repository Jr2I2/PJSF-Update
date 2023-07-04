//
//  AddStudent.swift
//  PJSF
//
//  Created by Lim Jun Rui on 4/6/23.
//

import SwiftUI
import FirebaseFirestore

struct AddStudent: View {
    var classs:Classes
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var regNum = ""
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name of student", text: $name)
                    TextField("Register number", text:$regNum)
                }
                Section {
                    Button("Save") {
                        tryToAddClass()
                    }
                }
            }
            .navigationTitle("Add Student")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    func tryToAddClass() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        guard !regNum.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("User\(userID)").document("Class%\(classs.name)").setData([regNum:name], merge: true) { error in
            // If there are no errors
            if error == nil {
                print("Student added")
                NotificationCenter.default.post(name: NSNotification.Name("ViewChangedStudent"), object: nil)
            }
        
        dismiss()
        }
    }
}

