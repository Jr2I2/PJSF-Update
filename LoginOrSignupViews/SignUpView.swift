//
//  SignUpView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 30/5/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore


struct SignUpView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    @State private var email :String = ""
    @State private var password :String = ""
    
    enum AuthenticationError: Error {
        case tokenError(message:String)
    }

    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID in Firebase Configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
                  print("There is no root view controller")
                  return false
              }
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                throw AuthenticationError.tokenError(message: "ID Token Missing")
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unkown")")
            userID = result.user.uid
            userEmail = result.user.email!
            let db = Firestore.firestore()
            db.collection("User\(userID)").document("User Info").setData(["Email":userEmail]) { error in
                
                // If there are no errors
                if error == nil {
                    print("User info added")
                }
            }
            db.collection("User\(userID)").document("Temp Class").setData(["1":"John"]) { error in
                
                if error == nil {
                    print("Class added")
                }
            }
            
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
        
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")

        return passwordRegex.evaluate(with: password)
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Create an Account!")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                        
                    
                    Spacer()
                }
                .padding()
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Image(systemName: "mail")
                    TextField("Email", text: $email)
                    
                    Spacer()
                    
                    if(email.count != 0) {
                        Image(systemName: email.isValidEmail() ?  "checkmark" : "xmark")
                            .foregroundColor(email.isValidEmail() ? .green : .red)
                    }
                    
                    
                        
                    
                }
                .foregroundColor(.white)

                .padding()
                .overlay(RoundedRectangle(cornerRadius:10)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.white)
                )
                
                .padding()
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                    
                    Spacer()
                    
                    if(password.count != 0) {
                        Image(systemName: isValidPassword(password) ? "checkmark" : "xmark")
                            .foregroundColor(isValidPassword(password) ? .green : .red)
                    }
                        
                    
                }
                .foregroundColor(.white)

                .padding()
                .overlay(RoundedRectangle(cornerRadius:10)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.white)
                )
                
                .padding()
                
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "login"
                    }
                }) {
                    Text("Already have an account?")
                        .foregroundColor(.blue.opacity(0.7))
                }
                Spacer()
                Spacer()
                
                Button {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        if let authResult = authResult {
                            print(authResult.user.uid)
                            userID = authResult.user.uid
                            userEmail = authResult.user.email!
                        }
                        let db = Firestore.firestore()
                        db.collection("User\(userID)").document("User Info").setData(["Email":userEmail, "User ID":userID]) { error in
                            
                            // If there are no errors
                            if error == nil {
                                print("User info added")
                            }
                        }
                        db.collection("User\(userID)").document("Class%Temp Class").setData(["1":"John", "Teacher Name":"You!"]) { error in
                            
                            if error == nil {
                                print("Class added")
                            }
                        }
                    }
                } label: {
                    Text("Sign Up")
                        .foregroundColor(.black)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .padding(.horizontal)
                }
                Button {
                    Task {
                        _ = try await signInWithGoogle()
                    }
                } label: {
                    Text("Create Account With Google")
                        .frame(maxWidth: 380)
                        .padding(.vertical, 8)
                        .foregroundColor(.blue)
                        .background(alignment: .leading)
                    {
                            Image("Google")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, alignment: .center)
                        }
                    }
                } 
            }
        }
    }
