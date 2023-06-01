//
//  CreateNewClub.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI
import PhotosUI
import AlertToast

struct Rule: Identifiable {
    let id = UUID()
    let text: String
}

struct CreateNewClub: View {
    
    enum CREATE_ERROR: Error {
        case unexpected
        case noName
    }
    
    @State private var state: LOADING_STATE = .pending
    @State private var clubName: String = ""
    @State private var description: String = ""
    @State private var sport: String   = "soccer"
    @State private var imageURL: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var showToast = false
    
    @StateObject var uploadObserver = UploadObserver()
    @StateObject private var clubObserver = ClubObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func UploadImage() async {
        if let data = selectedImageData {
            // new image
            let imageId = UUID().uuidString
            let _ = await uploadObserver.UploadImage(location: "/club-images", fileName: imageId, data: data)
            self.imageURL = "club-images/\(imageId).jpeg"
        }
    }
    
    func Validate() -> CREATE_ERROR? {
        if clubName == "" || clubName.count < 3 {
            return .noName
        }
        return nil
    }
    
    func CreateClub() async {
        
        // validate view
        let val = Validate()
        guard val == nil else {
            print("err")
            state = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                state = .pending
            }
            return
        }
        
        state = .loading
        
        // upload image if there is one
        if selectedImageData != nil {
            await UploadImage()
        }
        
        // grab current location and create club
        let geoCoder = CLGeocoder()
        let location = session.locationManager.location
        if let loc = location {
            let l = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            do {
                let pk = try await geoCoder.reverseGeocodeLocation(l)
                if let country = pk.first?.country {
                    if let state = pk.first?.administrativeArea{
                        if let city = pk.first?.locality {
//                            let c = Club(id: "", name: clubName, description: description, sport: sport, city: city, state: state, country: country, imageURL: imageURL, isPrivate: false, members: [Member]())
//                            let resp = try await clubObserver.createClub(club: c)
//                            session.clubTokens[resp.club.id] = resp.token
//                            await MainActor.run {
//                                session.myClubs.append(resp.club)
//                            }
//                            showToast = true
//                            self.state = .success
//                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            } catch {
                self.state = .failure
                print(error)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack (alignment: .leading){
                    VStack (alignment: .leading){
                        Text("Club Name:")
                            .font(.title3)
                            .bold()
                        Text("What your club will be known by")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextField("", text: $clubName)
                            .padding(.leading)
                    }.frame(height: 40)
                    VStack(alignment: .leading){
                        Text("Description:")
                            .font(.title3)
                            .bold()
                        .padding(.top)
                        Text("Explain what club is about?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextEditor(text: $description)
                            .scrollContentBackground(.hidden)
                        .frame(height: 200)
                    }
                    
                    // MARK: - Sports picker
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Sport")
                                .font(.title3)
                            .bold()
                            Text("The sport your club will focus on")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.primary)
                                .opacity(0.1)
                                .frame(height: 40)
                            Picker(selection: $sport, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                                ForEach(SPORT.allCases, id: \.rawValue) { sport in
                                    Text(sport.Icon() + " " + sport.rawValue).tag(sport.rawValue)
                                }
                            }.frame(width: SCREEN_WIDTH/2)
                                .tint(Color("primary-color"))
                        }
                    }.padding(.top)
                        .frame(width: SCREEN_WIDTH-25)
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading){
                                Text("Club Image")
                                    .font(.title3)
                                .bold()
                                Text("Upload an image for your club")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if selectedImageData == nil {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 100, height: 30)
                                                .foregroundColor(Color("primary-color"))
                                            Text("upload")
                                                .foregroundColor(.white)
                                                .frame(height: 30)
                                        }
                                    }.onChange(of: selectedItem) { newItem in
                                        Task {
                                            // Retrive selected asset in the form of Data
                                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                                withAnimation(.easeIn){
                                                    selectedImageData = data
                                                }
                                            }
                                        }
                                    }
                            } else {
                                Button(action:{
                                    withAnimation(.easeOut){
                                        selectedImageData = nil
                                        selectedItem = nil
                                    }
                                }){
                                    Image(systemName: "x.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color("primary-color"))
                                }
                            }
                        }.frame(height: 40)
                        
                        if let imgData = selectedImageData {
                            let img = UIImage(data: imgData)
                            if let i = img {
                                Image(uiImage: i)
                                    .resizable()
                                    .frame(width: SCREEN_WIDTH-25, height: 250)
                                    .scaledToFill()
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                        }
                    }.padding(.top)
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .center){
                            Button(action: { Task { await CreateClub() } }) {
                                LoadingButton(text: "Create Club", width: 150, status: $state)
                            }.disabled(state == .pending ? false : true)
                        }.frame(width: SCREEN_WIDTH-25)
                            .padding(.top, 50)
                    }
                }.onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                .padding(.top)
            }.frame(width: SCREEN_WIDTH-25)
                .toast(isPresenting: $showToast, alert: {
                    AlertToast(displayMode: .banner(.pop), type: .regular, title: "Club Created!", style: .style(titleColor: .green, titleFont: .body))
                }, completion: {
                    self.presentationMode.wrappedValue.dismiss()
                })
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{self.presentationMode.wrappedValue.dismiss()}) {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Create Club")
                            .font(.title3)
                            .bold()
                    }
                }
        }
    }
}

struct CreateNewClub_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewClub().environmentObject(SessionStore())
    }
}
