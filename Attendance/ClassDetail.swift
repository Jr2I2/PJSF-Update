//
//  ClassDetail.swift
//  PJSF
//
//  Created by Lim Jun Rui on 3/6/23.
//

import SwiftUI
import FirebaseFirestore

struct ClassDetail: View {
    
    var classs: Classes
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    @State var students : [Students] = []
    func getStudent() {
        students = []
        let db = Firestore.firestore()
        db.collection("User\(userID)").getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                for doc in snapshot!.documents {
                    let temp = doc.documentID
                    let Components = temp.components(separatedBy: "%")
                    let data = Components.first ?? ""
                    let className = Components.last ?? ""
                    if className == classs.name {
                        let docData = doc.data()
                        for (key, value) in docData {
                            if key != "Teacher Name" {
                                students.append(Students(name: value as! String, regNum: key))
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @State private var showAddScreen = false
    var body: some View {

        NavigationView {
            List {
            ForEach(students, id:\.id) { student in
                VStack(alignment: .leading, spacing: 2) {
                    Text(student.name)
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.5)
                    
                    Text("Reg: \(student.regNum)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteClasses)
            }
        }
        .navigationTitle(classs.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddScreen.toggle()
                } label: {
                    Label("Add Student", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddScreen) {
            AddStudent(classs: classs)
    }
        .onAppear(perform: getStudent)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ViewChangedStudent"))) { _ in
            getStudent()
        }
}
    
    private func deleteClasses(at indexSet: IndexSet) {
        indexSet.forEach { index in
            
            let student = students[index]
            
            let db = Firestore.firestore()
            db.collection("User\(userID)").document("Class%\(classs.name)").updateData([
                student.regNum: FieldValue.delete(),]) { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Student Removed")
                }
                getStudent()
            }
        }
    }
}

