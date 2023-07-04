//
//  HazardsView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 6/6/23.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct HazardsView: View {
    
    @State var hazards : [Hazards] = []
    @State var retrievedImages = [String:UIImage]()
    @State var selected = "Overview"
    @State var isAdmin = false
    @AppStorage("email") var userEmail: String = ""
    
    
    func getHazards() {
        let components = userEmail.components(separatedBy: "@")
        let domain = components.last ?? ""
        if domain == "sst.edu.sg" {
            isAdmin = true
        }
        hazards = []
        let db = Firestore.firestore()
        
        db.collection("Hazards").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                //handle error
                return
            }
            
            snapshot.documents.forEach({ (documentSnapshot) in
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
                                print(retrievedImages)
                            }
                        }
                    } else {
                        print("Error\(error)")
                    }
                }
                
            

                
            })
        }
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
                        if hazard.needCheck == "false" {
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
                                if isAdmin {
                                    Spacer()
                                    Button {
                                        let db = Firestore.firestore()
                                        db.collection("Hazards").document(hazard.type).delete() { err in
                                            if let err = err {
                                                print("Error removing document: \(err)")
                                            } else {
                                                print(hazard.type)
                                            }
                                        }
                                        getHazards()
                                        
                                    } label: {
                                        Text("x")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .listItemTint(Color(red:245 ,green:198, blue:146))

                        }
                    }
                }
            } else {
                List {
                    ForEach(hazards, id:\.id) { hazard in
                        if hazard.type == selected && hazard.needCheck == "false" {
                            let temp = hazard.type
                            let component = temp.components(separatedBy: "%")
                            let type = component.first ?? ""
                            HStack {
                                Image(uiImage: retrievedImages[hazard.image]!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 140)
                                    .cornerRadius(4)
                                Spacer()
                                VStack(alignment: .leading, spacing: 5) {

                                    Text(hazard.title)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        
                                    Text(type)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .listItemTint(Color(red:245 ,green:198, blue:146))
                                .padding()
                                if isAdmin {
                                    Spacer()
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

        .navigationTitle("Hazards")
        .onAppear {
            getHazards()
        }


    }
    
}

struct HazardsView_Previews: PreviewProvider {
    static var previews: some View {
        HazardsView()
    }
}
