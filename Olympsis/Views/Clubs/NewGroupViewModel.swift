//
//  NewClubViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/27/24.
//

import os
import UIKit
import Foundation
import CoreLocation

class NewGroupViewModel: ObservableObject {
    
    enum GROUP_CREATION_ERROR: Error {
        case unexpected
        case noName
        case noSport
    }
    
    @Published var logoPhoto: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.logoPhotoData = self.logoPhoto?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    @Published private var logoPhotoData: Data?
    
    
    @Published var bannerPhoto: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.bannerPhotoData = self.bannerPhoto?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    @Published private var bannerPhotoData: Data?
    
    @Published var logoURL: String = ""
    @Published var bannerURL: String = ""
    
    @Published var clubName: String = ""
    @Published var description: String = ""
    @Published var state: LOADING_STATE = .pending
    @Published var selectedSports: Set<String> = []
    
    @Published var showToast = false
    
    @Published var showMediaWarning: Bool = false
    @Published var showSportsPicker: Bool = false
    @Published var showLogoMediaPicker: Bool = false
    @Published var showBannerMediaPicker: Bool = false
    
    var uploadObserver = UploadObserver()
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "new_club_view_model")
    
    @MainActor
    func uploadLogo(_ location: String) async throws {
        if let data = logoPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadObserver.UploadImage(location: location, fileName: id, data: data) else {
                return
            }
            if resp.score > 4 {
                throw MediaUploadError.innapropriateContent
            } else {
                logoURL = "club-images/\(id).jpeg"
            }
        }
    }
    
    @MainActor
    func uploadBanner(_ location: String) async throws {
        if let data = bannerPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadObserver.UploadImage(location: location, fileName: id, data: data) else {
                return
            }
            if resp.score > 4 {
                throw MediaUploadError.innapropriateContent
            } else {
                bannerURL = "club-images/\(id).jpeg"
            }
        }
    }
    
    @MainActor
    func deleteLogo(_ location: String, image: String) async {
        _ = await uploadObserver.DeleteObject(path: "/olympsis-club-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func deletebanner(_ location: String, image: String) async {
        _ = await uploadObserver.DeleteObject(path: "/olympsis-club-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func imagesCleanUp(_ location: String) async {
        if logoURL != "" {
            await deleteLogo(location, image: logoURL)
        }
        
        if bannerURL != "" {
            await deletebanner(location, image: bannerURL)
        }
    }
    
    func validate() -> GROUP_CREATION_ERROR? {
        if clubName == "" || clubName.count < 3  || clubName.count > 25 {
            return .noName
        }
        if selectedSports.isEmpty {
            return .noSport
        }
        return nil
    }
    
    @MainActor
    func createClubDTO() async -> ClubDao? {
        // validate view
        guard validate() == nil else {
            log.error("Failed to validate club create view before creating club")
            state = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.state = .pending
            }
            return nil
        }
        
        state = .loading
        
        do {
            // upload logo if there is one
            if logoPhotoData != nil {
                try await uploadLogo("/olympsis-club-images")
            }
            
            // upload banner if there is one
            if bannerPhotoData != nil {
                try await uploadBanner("/olympsis-club-images")
            }
        } catch MediaUploadError.innapropriateContent {
            await imagesCleanUp("/olympsis-club-images")
            self.showMediaWarning.toggle()
            log.error("Failed to upload club logo/banner. Media may contain innapropriate content.")
            return nil
        } catch {
            await imagesCleanUp("/olympsis-club-images")
            log.error("Failed to upload club logo/banner: \(error.localizedDescription)")
            return nil
        }
        
        return ClubDao(
            name: clubName,
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil,
            description: description,
            sports: Array(selectedSports),
            visibility: "public"
        )
    }
    
    @MainActor
    func createOrganizationDTO() async -> OrganizationDao? {
        // validate view
        guard validate() == nil else {
            log.error("Failed to validate club create view before creating club")
            state = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.state = .pending
            }
            return nil
        }
        
        state = .loading
        
        do {
            // upload logo if there is one
            if logoPhotoData != nil {
                try await uploadLogo("/olympsis-org-images")
            }
            
            // upload banner if there is one
            if bannerPhotoData != nil {
                try await uploadBanner("/olympsis-org-images")
            }
        } catch MediaUploadError.innapropriateContent {
            await imagesCleanUp("/olympsis-org-images")
            self.showMediaWarning.toggle()
            log.error("Failed to upload club logo/banner. Media may contain innapropriate content.")
            return nil
        } catch {
            await imagesCleanUp("/olympsis-org-images")
            log.error("Failed to upload club logo/banner: \(error.localizedDescription)")
            return nil
        }
        
        return OrganizationDao(
            name: clubName,
            description: description, 
            sports: Array(selectedSports), 
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil
        )
    }
}
