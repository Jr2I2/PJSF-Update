//
//  LogInView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 30/5/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn



struct LogInView: View {
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
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Welcome Back!")
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
                .padding()
                .overlay(RoundedRectangle(cornerRadius:10)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.black)
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
                .padding()
                .overlay(RoundedRectangle(cornerRadius:10)
                            .stroke(lineWidth: 2)
                            .foregroundColor(.black)
                )
                
                .padding()
                
                Button(action: {
                    withAnimation{
                        self.currentShowingView = "signup"
                    }
                }) {
                    Text("Don't have an account?")
                        .foregroundColor(.blue.opacity(0.7))
                }
                Spacer()
                Spacer()
                
                Button {
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            print(error)
                        }
                            
                        
                        if let authResult = authResult {
                            print("Logged In")
                            withAnimation {
                                userID = authResult.user.uid
                                userEmail = authResult.user.email!
                            }
                        }
                        
                    }
                } label: {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black))
                        .padding(.horizontal)
                }
                
                Button {
                    Task {
                        _ = try await signInWithGoogle()
                    }
                } label: {
                    Text("Sign In With Google")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(alignment: .leading) {
                            Image("Google")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, alignment: .center)
                }
                
                        
                        }
                }
                
                .buttonStyle(.bordered)
                
                
            }
        }
}
