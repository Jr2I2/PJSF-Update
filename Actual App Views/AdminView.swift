//
//  AdminView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 30/5/23.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct AdminView: View {
    @Environment(\.dismiss) var dismiss
    
    let uniqueuuid = "Emergency\(UUID().uuidString)"
    let temp = UUID()
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var retrievedImages = UIImage()
    @State var retrievedTitle: String = ""
    @State var titleText: String = ""
    @State var descText: String = ""
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    
    @State var needCheck = "true"

    

        
    
    var type = ["Hazard", "Emergency"]
    var hazardType = ["Leak", "Cleanliness", "Potential Danger", "Other"]
    @State private var selectedType = "Emergency"
    @State private var selectedHazardType = "Potential Danger"
        
    var body: some View {
        Button {
            isPickerShowing = true
        } label: {
            if selectedImage != nil {
                ZStack{
                    Image(uiImage: UIImage(named: "White")!)
                        .resizable()
                        .frame(height:325)
                    
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .frame(width:315, height:300)
                }
            } else{
                Image(uiImage: UIImage(named: "Placeholder")!)
                    .resizable()
                    .frame(height:325)
            }
        }
        Section {
            VStack {
                VStack(spacing: 8) {
                    HStack {
                        Text("What Happened?")
                            .font(.headline)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    TextField("...", text: $titleText)
                        .background(Color.clear)
                }
                .padding(.vertical, 4)
                
                VStack(spacing: 8){
                    HStack{
                        Text("Short desc / Location:")
                            .font(.headline)
                        Spacer()
                    }
                    
                    TextField("...", text: $descText)
                        .background(Color.clear)
                }
                .padding(.vertical, 4)
                Spacer()
                Picker("What kind of issue is this?", selection: $selectedType) {
                                ForEach(type, id: \.self) {
                                    Text($0)
                                }
                            } .pickerStyle(SegmentedPickerStyle())
                
                if selectedType == "Hazard" {
                    Picker("What kind of hazard is this?", selection: $selectedHazardType) {
                                    ForEach(hazardType, id: \.self) {
                                        Text($0)
                                    }
                                } .pickerStyle(DefaultPickerStyle())
                            }
                Spacer()
                Button {
                    isPickerShowing = false
                    uploadPhoto()
                    
                } label: {
                    Text("Submit")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray)
                .cornerRadius(0.5)
                .offset(y: -1)
                .mask(
                    VStack {
                        Rectangle()
                            .foregroundColor(.clear)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray)
                            .cornerRadius(0.5)
                    }
                )
        )


        
        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        }
        
        

    }
    
    func uploadPhoto() {
        let domain = userEmail.components(separatedBy: "@").last ?? ""
        
        if domain == "sst.edu.sg" {
            needCheck = "false"
        }
        
        //Make sure that selected image property isnt nil
        guard selectedImage != nil else {
            return
        }

        
        //Create storage reference
        let storageRef = Storage.storage().reference()
        
        //Turn image into data
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        
        //Check that we are able to conver it
        guard imageData != nil else {
            return
        }
        
        
        //Specify file path and name
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        //Upload Data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //check for error
            if error == nil && metadata != nil {
                
                //Save a reference to the file in firebase database
                let db = Firestore.firestore()
                if selectedType == "Emergency" {
                    db.collection("Emergencies").document(uniqueuuid).setData(["image":path, "title":titleText,"desc":descText, "Need Admin Check":needCheck]) { error in
                        
                        // If there are no errors
                        if error == nil {
                            dismiss()
                        }
                    }
                }
                else {
                    db.collection("Hazards").document("\(selectedHazardType)%\(temp)").setData(["image":path, "title":titleText,"desc":descText, "Need Admin Check":needCheck]) { error in
                        
                        // If there are no errors
                        if error == nil {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    

    
    func retrievePhotos() {
        
        //Get the data from the database
        let db = Firestore.firestore()
        let docRef = db.collection("Hazards").document("\(selectedHazardType)%\(temp)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let Components = dataDescription.components(separatedBy: "/")
                let data = Components.last ?? ""
                let component = data.components(separatedBy: "]")
                let tempData = component.first ?? ""
                let compmonentagain = tempData.components(separatedBy: ",")
                let docData = compmonentagain.first ?? ""
                print("Image data: \(docData)")
                //Get a reference to the storage
                let storageRef = Storage.storage().reference()
                            
                //Specify the path
                let fileRef = storageRef.child("images")
                
                //Get the image data
                let imgRef = fileRef.child(docData)
                print(imgRef)
                
                //Retrieve the data
                imgRef.getData(maxSize: 5*1024*1024) { data, error in
                    print("hi")
                    //Check for errors
                    if error == nil && data != nil{
                                        
                                        //Create a UIImage
                        if let image = UIImage(data: data!) {
                            DispatchQueue.main.async {
                                retrievedImages = image
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    func retrieveTitle() {
        
        //Get the data from the database
        let db = Firestore.firestore()
        let docTitleRef = db.collection("User\(userID)").document(uniqueuuid)
        
        docTitleRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let Components = dataDescription.components(separatedBy: "title")
                let data = Components.last ?? ""
                let component = data.components(separatedBy: ",")
                let tempData = component.first ?? ""
                let componentagain = tempData.components(separatedBy: ":")
                let docData = componentagain.last ?? ""

                print("Title data: \(docData)")
            }
        }
    }
    func retrieveDesc() {
        
        //Get the data from the database
        let db = Firestore.firestore()
        let docDescRef = db.collection("User\(userID)").document(uniqueuuid)
        
        docDescRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let Components = dataDescription.components(separatedBy: "desc")
                let data = Components.last ?? ""
                let component = data.components(separatedBy: ",")
                let tempData = component.first ?? ""
                let componentagain = tempData.components(separatedBy: ":")
                let docData = componentagain.last ?? ""

                print("Desc data: \(docData)")
            }
        }
    }
}
        



struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
