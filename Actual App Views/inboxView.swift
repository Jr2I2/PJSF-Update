//
//  inboxView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 12/6/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct inboxView: View {
    @State var hazards : [Hazards] = []
    @State var retrievedImages = [String:UIImage]()
    @State var selected = "Overview"
    func getHazards() {
        hazards = []
        let db = Firestore.firestore()
        
        db.collection("Hazards").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                //handle error
                return
            }
            
            snapshot.documents.forEach({ (documentSnapshot) in
                if documentSnapshot.data()["Need Admin Check"] as! String == "true" {
                    let documentData = documentSnapshot.data()
                    let temp2 = documentData["image"] as! String
                    let component2 = temp2.components(separatedBy: "/")
                    let imageData = component2.last ?? ""

                    let docData = imageData
                    print("image data: \(docData)")
                    //Get a reference to the storage
                    let storageRef = Storage.storage().reference()
                                        
                    //Specify the path
                    let fileRef = storageRef.child("images")
                            
                    //Get the image data
                    let imgRef = fileRef.child(docData)
                    print(imgRef)
                            
                    //Retrieve the data
                    imgRef.getData(maxSize: 5*1024*1024) { data, error in
                        print(retrievedImages)
                        //Check for errors
                        if error == nil && data != nil{
                                            
                                            //Create a UIImage
                            if let image = UIImage(data: data!) {
                                DispatchQueue.main.async {
                                    retrievedImages[docData] = image
                                    hazards.append(Hazards(title: documentData["title"] as! String, desc: documentData["desc"] as! String, type: documentSnapshot.documentID, image: imageData, needCheck: documentData["Need Admin Check"] as! String))
                                    print(hazards)
                                }
                            }
                        } else {
                            print("Error\(error)")
                        }
                    }
                
                }

                
            })
        }
        print(retrievedImages)
    }
    

    
    var body: some View {
        Picker(selection: $selected, label: Text("Picker"), content: {
            Text("Overview").tag("Overview")
            Text("Leak").tag("Leak")
            Text("Cleanliness").tag("Cleanliness")
            Text("Danger").tag("Potential Danger")
            Text("Other").tag("Other")
        })
            .pickerStyle(SegmentedPickerStyle())
        VStack {

            if selected == "Overview" {
                List {
                    ForEach(hazards, id:\.id) { hazard in
                            let temp = hazard.type
                            let component = temp.components(separatedBy: "%")
                            let type = component.first ?? ""
                            HStack {
                                Image(uiImage: retrievedImages[hazard.image]!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 140)
                                    .cornerRadius(4)
                                
                                VStack(alignment: .leading, spacing: 5) {

                                    Text(hazard.title)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        
                                    Text(type)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                Spacer()
                                Button {
                                    let db = Firestore.firestore()
                                    db.collection("Hazards").document(hazard.type).updateData(["Need Admin Check" : "false"]) { error in
                                        
                                        // If there are no errors
                                        if error == nil {
                                            print("info changed")
                                        }
                                    }
                                    getHazards()
                                    
                                } label: {
                                    Text("✓")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button {
                                    let db = Firestore.firestore()
                                    db.collection("Hazards").document(hazard.type).delete() { err in
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                    }
                                    getHazards()
                                    
                                } label: {
                                    Text("x")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        
                    }
                }
            } else {
                List {
                    ForEach(hazards, id:\.id) { hazard in
                        if hazard.type == selected {
                            HStack {
                                Image(uiImage: retrievedImages[hazard.image]!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 140)
                                    .cornerRadius(4)
                                
                                VStack(alignment: .leading, spacing: 5) {

                                    Text(hazard.title)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        
                                    Text(hazard.type)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                Spacer()
                                HStack {
                                    Button {
                                        let db = Firestore.firestore()
                                        db.collection("Hazards").document("User Info").updateData(["Need Admin Check" : "false"]) { error in
                                            
                                            // If there are no errors
                                            if error == nil {
                                                print("info changed")
                                            }
                                        }
                                        getHazards()
                                        
                                    } label: {
                                        Text("✓")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    Button {
                                        let db = Firestore.firestore()
                                        db.collection("Hazards").document(hazard.type).delete() { err in
                                            if let err = err {
                                                print("Error removing document: \(err)")
                                            } else {
                                                print("Document successfully removed!")
                                            }
                                        }
                                        getHazards()
                                        
                                    } label: {
                                        Text("x")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
        }

        .navigationTitle("Inbox")
        .onAppear {
            getHazards()
        }


    }
    
}

struct inboxView_Previews: PreviewProvider {
    static var previews: some View {
        inboxView()
    }
}
