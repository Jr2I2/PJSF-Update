//
//  ContentView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 30/5/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn


struct ContentView: View {
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    
    
    
    var body: some View {
        if userID == "" {
            AuthView()
        } else {
            let components = userEmail.components(separatedBy: "@")
            let domain = components.last ?? ""
            if domain == "s2021.ssts.edu.sg" {
                UserView()
            }
            else if domain == "sst.edu.sg" {
                AdminView()
            }
            else {
                normalUserView()
            }
            
            Button(action: {
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                    withAnimation{
                        userID = ""
                    }
                } catch let signOutError as NSError {
                  print("Error signing out: %@", signOutError)
                }}) {
                Text("Sign Out")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
