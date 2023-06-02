//
//  BetaPage.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct BetaPage: View {
    @AppStorage("betaTerms") var betaTerms:Bool = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        ScrollView{
            VStack {
                Text("Welcome to the Beta")
                    .font(.largeTitle)
                    .bold()
                Text("Thank you for participating")
                    .font(.callout)
            }.frame(width: SCREEN_WIDTH, height:150, alignment: .center)
            
            Text("Please Accept all these terms before moving on:")
            
            HStack{
                Image(systemName: "cloud")
                    .imageScale(.large)
                    .frame(width: 40, height: 40, alignment: .center)
                Text("We have an Instagram page feel free to message us or report bugs on there or within the app.")
                Spacer()
            }.padding()
            .frame(width: SCREEN_WIDTH)
            
            HStack{
                Image(systemName: "server.rack")
                    .imageScale(.large)
                    .frame(width: 40, height: 40, alignment: .center)
                Text("By participating you consent to the collection and usage of your data on this app to improve the experience of Olympsis.")
                Spacer()
            }.padding()
            .frame(width: SCREEN_WIDTH)
            
            HStack{
                Image(systemName: "tray.full")
                    .imageScale(.large)
                    .frame(width: 40, height: 40, alignment: .center)
                Text("All data is kept secured and will only be used only by Olympsis.")
                Spacer()
            }.padding()
            .frame(width: SCREEN_WIDTH)
            
            HStack{
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .frame(width: 40, height: 40, alignment: .center)
                Text("Remember this is a beta there will be many bugs please dont forget to use the report button in settings to submit bug reports.")
                Spacer()
            }.padding()
            .frame(width: SCREEN_WIDTH)
            
            Button(action:{self.presentationMode.wrappedValue.dismiss(); self.betaTerms = false}){
                Text("Accept All")
                    .foregroundColor(.white)
            }.frame(width: SCREEN_WIDTH/1.5, height: 50, alignment: .center)
            .background(Color("primary-color"))
            .cornerRadius(5)
            .padding(.top)
            
            Spacer()
        }
    }
}

struct BetaPage_Previews: PreviewProvider {
    static var previews: some View {
        BetaPage()
    }
}
