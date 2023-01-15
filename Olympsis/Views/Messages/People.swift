//
//  People.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import SwiftUI
/*
struct People: View {
    @State private var index:Int = 1
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $index) {
                    LookUp().tag(1)
                    FriendRequestsView().tag(2)
                }.tabViewStyle(PageTabViewStyle())
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                                Image(systemName: "chevron.left")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action:{index = 1}){
                                Text("Search")
                                    .foregroundColor(.primary)
                                    .font(index == 1 ? .headline : .body)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action:{index = 2}){
                                Text("Friend Requests")
                                    .foregroundColor(.primary)
                                    .font(index == 2 ? .headline : .body)
                            }
                        }
                    }
            }
        }
    }
}

struct People_Previews: PreviewProvider {
    static var previews: some View {
        People()
    }
}
*/
