//
//  PickUsername.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import SwiftUI

struct PickUsername: View {
    
    @Binding var currentView: AuthTab
    
    @State private var username: String = ""
    @State private var status: LOADING_STATE = .pending
    
    @State private var cacheService = CacheService()
    @State private var userObserver = UserObserver()
    
    func validateInput(_ input: String) -> Bool {
        let regex = "^[a-z0-9]{5,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
    
    func verifyUsername() -> Bool {
        
    }
    
    var body: some View {
        VStack {
            // title
            Text("Pick a Username")
                .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                .padding(.top)
            
            // textfield
            VStack(alignment: .leading) {
                Text("username")
                    .padding(.leading)
                    .font(.title3)
                HStack {
                    ZStack {
                        TextField("", text: $username)
                            .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                    }.frame(height: 45)
                        .padding(.horizontal)
                    
                    ZStack {
                        Circle()
                            .frame(width: 45)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                            .overlay {
                                switch status {
                                case .pending:
                                    Image(systemName: "questionmark")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                case .loading:
                                    ProgressView()
                                case .success:
                                    Image(systemName: "checkmark")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                case .failure:
                                    Image(systemName: "xmark")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.trailing)
                    }
                }
                
                // cautionary text
                Text("Must be between 5 and 15 characters to be valid")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading)
                
            }.padding(.top)
            
            Spacer()
            
            // action button
            Button(action: {}){
                SimpleButtonLabel(text: "continue")
            }.padding(.bottom)
        }
    }
}

struct PickUsername_Previews: PreviewProvider {
    static var previews: some View {
        PickUsername(currentView: .constant(.username))
    }
}
