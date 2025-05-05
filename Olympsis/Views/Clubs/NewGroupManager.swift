//
//  NewGroupManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/27/24.
//

import os
import UIKit
import Foundation
import CoreLocation

@Observable
class NewGroupManager {
    
    enum GROUP_CREATION_ERROR: Error {
        case unexpected
        case noName
        case noSport
    }
    
    var city: String = ""
    var state: String = ""
    var country: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    var logoPhoto: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.logoPhotoData = self.logoPhoto?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    private var logoPhotoData: Data?
    
    
    var bannerPhoto: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.bannerPhotoData = self.bannerPhoto?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    private var bannerPhotoData: Data?
    
    var logoURL: String = ""
    var bannerURL: String = ""
    
    var clubName: String = ""
    var description: String = ""
    var status: LOADING_STATE = .pending
    var selectedSports: Set<String> = []
    
    var selectedCountry: Country?
    var selectedAdminArea: AdministrativeArea?
    var selectedSubAdminArea: SubAdministrativeArea?
    
    var showToast = false
    
    var showMediaWarning: Bool = false
    var showSportsPicker: Bool = false
    var showLogoMediaPicker: Bool = false
    var showBannerMediaPicker: Bool = false
    
    var uploadObserver = UploadObserver()
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "new_group_view_model")
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.status = .pending
        }
    }
    
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
            log.error("Failed to validate new group. Bad group name.")
            return .noName
        }
        if selectedSports.isEmpty {
            log.error("Failed to validate new group. No sports selection selected.")
            return .noSport
        }
        if selectedCountry == nil && selectedAdminArea == nil && selectedSubAdminArea == nil {
            log.error("Failed to validate new group. No location provided!")
            return .unexpected
        }
        log.info("Group validated successfully")
        return nil
    }
    
    @MainActor
    func createClubDTO() async -> ClubDao? {
        // validate view
        guard validate() == nil else {
            log.error("Failed to validate club create view before creating club")
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.status = .pending
            }
            return nil
        }
        
        status = .loading
        
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
            status = .failure
            await imagesCleanUp("/olympsis-club-images")
            log.error("Failed to upload club logo/banner: \(error.localizedDescription)")
            return nil
        }
        
        guard let country = selectedCountry,
              let state = selectedAdminArea,
              let city = selectedSubAdminArea else {
            log.error("Failed to create club DTO. Missing location data.")
            return nil
        }
        
        return ClubDao(
            name: clubName,
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil,
            description: description,
            sports: Array(selectedSports),
            city: city.name,
            state: state.name,
            country: country.name,
            location: city.location,
            visibility: "public"
        )
    }
    
    @MainActor
    func createOrganizationDTO() async -> OrganizationDao? {
        // validate view
        guard validate() == nil else {
            log.error("Failed to validate organization create view before creating organization")
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.status = .pending
            }
            return nil
        }
        
        status = .loading
        
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
            state: state,
            country: country,
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil
        )
    }
    
    @MainActor
    func updateClubDTO() async -> ClubDao? {
        status = .loading
        
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
            status = .failure
            await imagesCleanUp("/olympsis-club-images")
            log.error("Failed to upload club logo/banner: \(error.localizedDescription)")
            return nil
        }
        
        return ClubDao(
            name: clubName,
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil,
            description: description,
            sports: Array(selectedSports)
        )
    }
    
    @MainActor
    func updateOrganizationDTO() async -> OrganizationDao? {
        status = .loading
        
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
    
    func loadClub(_ club: Club) {
        guard let description = club.description else {
            return
        }
        
        if let logo = club.logo {
            self.logoURL = logo
        }
        
        if let banner = club.banner {
            self.bannerURL = banner
        }
        
        self.clubName = club.name
        self.description = description
        self.selectedSports.formUnion(club.sports)
    }
    
    func loadOrganization(_ org: Organization) {
        guard let description = org.description else {
            return
        }
        
        if let logo = org.logo {
            self.logoURL = logo
        }
        
        if let banner = org.banner {
            self.bannerURL = banner
        }
        
        self.clubName = org.name
        self.description = description
        self.selectedSports.formUnion(org.sports)
        
    }
    
    @MainActor
    func updateClub(_ club: Club) async -> Bool {
        guard let dto = await self.updateClubDTO()else {
            handleFailure()
            log.error("Failed to create club DTO")
            return false
        }
        
        dto.visibility = nil
        guard await ClubObserver.shared.updateClub(id: club.id, dto: dto) else {
            handleFailure()
            log.error("Failed to update club")
            return false
        }
        
        status = .success
        
        if let name = dto.name {
            club.name = name
        }
        
        club.logo = dto.logo
        club.banner = dto.banner
        club.description = dto.description
        
        if let sports = dto.sports {
            club.sports = sports
        }
        
        return true
    }
    
    @MainActor
    func updateOrganization(_ org: Organization) async -> Bool {
        guard let dto = await self.updateOrganizationDTO() else {
            handleFailure()
            log.error("Failed to create org DTO")
            return false
        }
        
        guard await OrgObserver.shared.updateOrganization(id: org.id, dto: dto) else {
            handleFailure()
            log.error("Failed to update club")
            return false
        }
        
        status = .success
        
        guard let name = dto.name,
              let sports = dto.sports else {
            return false
        }
        
        org.name = name
        org.logo = dto.logo
        org.banner = dto.banner
        org.description = dto.description
        org.sports = sports
        
        return true
    }
}
