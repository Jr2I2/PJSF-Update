//
//  DefaultView.swift
//  PJSF
//
//  Created by Lim Jun Rui on 31/5/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn

struct DefaultView: View {
    
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var userEmail: String = ""
    @State var showRep = false
    
    var body: some View {
        let temp = userEmail
        let component = temp.components(separatedBy: "@")
        let email = component.first ?? ""
        NavigationView {
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all).opacity(0.05)
                VStack {
                    Text("Welcome Back \(email)!")
                        .font(.largeTitle).bold()
                        .font(.system(size: 56.0))
                        .foregroundColor(.blue)
                    Spacer()
                    HStack {
                        
                        Button {
                            showRep = true
                        } label:{
                            Text("Report")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: 160)
                                .font(.system(size: 18))
                                .padding()
                                .foregroundColor(.black)
                                .background(.white)
     
                        }
                                .cornerRadius(25)
                            
                            NavigationLink(destination: Attendance()) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 40, height: 40)
                                    
                                        Image("att")
                                            .resizable()
                                            .aspectRatio(1.0, contentMode: .fit)
                                            .frame(width: 2.0.squareRoot() * 20, height: 2.0.squareRoot() * 20)
                                    }
                                    Text("Attendance")
                                        .bold()
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 160)
                            .font(.system(size: 18))
                            .padding()
                            .background(.white)
                            .cornerRadius(25)
                        
                        
                    }
                    HStack {
                        NavigationLink(destination: HazardsView()) {
                            Text("Hazards")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: 160)
                                .font(.system(size: 18))
                                .padding()
                                .foregroundColor(.black )
                                .background(.white)
                        }
                                .cornerRadius(25)
                        NavigationLink(destination: inboxView()) {
                            Text("Inbox")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: 160)
                                .font(.system(size: 18))
                                .padding()
                                .foregroundColor(.black )
                                .background(.white)
                        }
                                .cornerRadius(25)
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
                    Spacer()
                    
                    
                    
                }
            }
            .sheet(isPresented: $showRep) {
                AdminView()
            }
        }
    }
}

struct DefaultView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultView()
    }
}
