//
//  UserView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 30/5/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn

struct UserView: View {
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    @State var showRep = false
    
    var body: some View {
        NavigationView {
            VStack {
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
                Button {
                    showRep = true
                } label: {
                    Text("Something Wrong?")
                }
                NavigationLink(destination: HazardsView()) {
                    Text("Hazards in the school")
                }
            }
        }
        .sheet(isPresented: $showRep) {
            AdminView()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}

