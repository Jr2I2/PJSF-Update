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
    
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var retrievedImages = [UIImage]()
    
    @State private var title :String = ""
    
    var body: some View {
        VStack {
            
            if selectedImage != nil {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            Button {
                
                isPickerShowing = true
                
            } label: {
                Text("Select a Photo")
            }
            
            if selectedImage != nil {
                Button {
                    uploadPhoto()
                } label: {
                    Text("Upload the Photo")
                }
            }
            
            Divider()
            
            HStack {
                
                //Loop through the images and display
                ForEach(retrievedImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 200, height: 200)
                }
                
            }
                
            
        }
        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
            
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        }
        .onAppear {
            retrievePhotos()
            
        }
    }
    
    func uploadPhoto() {
        
        //Make sure that the selected image propoerty isn't nil
        guard selectedImage != nil else {
            return
        }

        //Create Storage Reference
        let storageRef = Storage.storage().reference()

        //Turn our image into data
        let imageData = selectedImage!.jpegData(compressionQuality: 0.0)
        
        guard imageData != nil else {
            return
        }

        //Specify the file path and name
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)

        //Upload Data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //Check for errors
            if error == nil && metadata != nil {
                
                //Save a reference of that file in firebase database
                let db = Firestore.firestore()
                db.collection("images").document().setData(["url":path]) { error in
                    
                    //If there were no errors, display no image
                    if error == nil {
                        DispatchQueue.main.async {
                            self.retrievedImages.append(self.selectedImage!)
                        }
                        
                    }
                    
                }
                    
                

            }
        }

        

    }
    
    func retrievePhotos() {
        
        //Get the data from the database
        let db = Firestore.firestore()
        db.collection("images").getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                var paths = [String]()
                    
                
                for doc in snapshot!.documents {
                    //Extract the file path
                    paths.append(doc["url"] as! String)
                    
                }
                
            //Loop through each file path and fetch the data from st
            for path in paths {
                
                //Get a reference to storage
                let storageRef = Storage.storage().reference()
                
                //Specify the path
                let fileRef = storageRef.child(path)
                
                //Retrieve the data
                fileRef.getData(maxSize: 5*1024*1024) { data, error in
                    
                    //Check for errors
                    if error == nil && data != nil {
                        
                        //Create a UIImage and put it into our array for display
                        if let image = UIImage(data: data!) {
                            DispatchQueue.main.async {
                                retrievedImages.append(image)
                            }
                        }
                       
                        
                        
                    }
                    
                }
                
            }
            
        }
    }
        
        
        
        //Display the images
        
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
