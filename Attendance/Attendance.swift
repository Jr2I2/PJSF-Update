//
//  Attendance.swift
//  PJSF
//
//  Created by Lim Jun Rui on 3/6/23.
//

import SwiftUI
import FirebaseFirestore



struct Attendance: View {
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    @State var classes : [Classes] = []
    @State private var showAddScreen = false
    @State private var searchText: String = ""
    @State private var filteredWords: [String] = []
    
    func getClass() {
        classes = []
        let db = Firestore.firestore()
        db.collection("User\(userID)").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                //handle error
                return
            }
            
            snapshot.documents.forEach({ (documentSnapshot) in
                let temp = documentSnapshot.documentID
                let Components = temp.components(separatedBy: "%")
                let data = Components.first ?? ""
                let className = Components.last ?? ""
                if data == "Class" {
                    let documentData = documentSnapshot.data()
                    let cherName = documentData["Teacher Name"] as? String
                    classes.append(Classes(name: className, cherName: cherName!))
                }
            })
        }
    }
        
        
        
        
        var body: some View {
            
            NavigationView {
                List {
                    ForEach(classes, id:\.id) { classs in
                        NavigationLink(destination: ClassDetail(classs: classs), label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(classs.name)
                                    .fontWeight(.semibold)
                                    .minimumScaleFactor(0.5)
                                
                                Text(classs.cherName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        })
                    }
                    .onDelete(perform: deleteClasses)
                }
            } 
            
            
            .navigationTitle("Classes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddScreen.toggle()
                    } label: {
                        Label("Add Class", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddScreen) {
                AddClass()
            }
            .onAppear(perform: getClass)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ViewChanged"))) { _ in
                getClass()
            }
        }
    
    
    private func deleteClasses(at indexSet: IndexSet) {
        indexSet.forEach { index in
            
            let classs = classes[index]
            
            let db = Firestore.firestore()
            db.collection("User\(userID)").document("Class%\(classs.name)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Class Removed")
                }
                getClass()
            }
        }
    }
}

struct Attendance_Previews: PreviewProvider {
    static var previews: some View {
        Attendance()
    }
}
