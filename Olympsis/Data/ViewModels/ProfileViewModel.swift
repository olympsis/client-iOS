//
//  ProfileViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/29/24.
//

import PhotosUI
import SwiftUI
import Foundation
import CoreLocation


class ProfileViewModel: ObservableObject {
    
    @Published var bio: String = ""
    @Published var username: String = ""
    @Published var isPublic: Bool = true
    @Published var visibility: String = "public"
    
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var country: String = ""
    
    @Published var hometown: CLLocationCoordinate2D?
    
    @Published var selectedSports: Set<String> = []
    
    @Published var selectedPhotoData: Data?
    @Published var selectedPhotoItem: PhotosPickerItem?
    
    @State var status: LOADING_STATE = .pending
    
    @EnvironmentObject private var session: SessionStore
    
    private var userObserver: UserObserver = UserObserver()
    private var uploadObserver: UploadObserver = UploadObserver()
    
    func UpdateProfile() async {
        var imageURL: String = ""
        status = .loading
        // new image
        let imageId = UUID().uuidString
        
        // check for updated image
        guard let data = selectedPhotoData else {
            guard let user = session.user else {
                status = .failure
                return
            }
            let update = UserDao(username: user.username, bio: bio, sports: Array(selectedSports))
            let res = await userObserver.UpdateUserData(update: update)
            
            guard res == true else {
                status = .failure
                return
            }
            status = .success
            return
        }
        
        let res = await uploadObserver.UploadImage(location: "/olympsis-profile-images", fileName: imageId, data: data)
        
        guard res == true else {
            status = .failure
            return
        }
        
        imageURL = "profile-images/\(imageId).jpeg"
        
        guard var user = session.user else {
            return
        }
        
        if let img = user.imageURL {
            // delete old picture
            _ = await uploadObserver.DeleteObject(path: "/olympsis-profile-images", name: GrabImageIdFromURL(img))
        }
        
        var coordinates: [Double]? = nil
        if let clocation = hometown {
            coordinates = [clocation.latitude, clocation.longitude]
        }
        
        // update user data
        let update = UserDao(username: user.username, bio: bio, imageURL: imageURL, hometown: coordinates, sports: Array(selectedSports))
        let resp = await userObserver.UpdateUserData(update: update)
        
        guard resp == true else {
            status = .failure
            return
        }
        
        user.imageURL = imageURL
        session.user = user
        status = .success
    }
}
