//
//  DevDataLoader.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/17/22.
//

import Foundation

class DevDataLoader {
    
    private var data: Data?
    private var decoder: JSONDecoder?
    private var decodedData: DevData?
    
    init(){
        decoder = JSONDecoder()
        data = self.readLocalFile(forName: "dev-data")
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func getData() {
        if let d = data {
            do {
                let dData = try decoder?.decode(DevData.self, from: d)
                self.decodedData = dData
            } catch {
                print(error)
            }
        } else {
            print("there is no dev data")
        }
    }
    
    func getUsers() -> [UserDao] {
        if let d = self.decodedData {
            return d.users
        } else {
            return [UserDao]()
        }
    }
    
    func getFields() -> [Field] {
        if let d = self.decodedData {
            return d.fields
        } else {
            return [Field]()
        }
    }
    
    func getClubs() -> [Club] {
        if let d = self.decodedData {
            return d.clubs
        } else {
            return [Club]()
        }
    }
    
    func getEvents() -> [Event] {
        if let d = self.decodedData {
            return d.events
        } else {
            return [Event]()
        }
    }
    
    func getPosts() -> [Post] {
        if let d = self.decodedData {
            return d.posts
        } else {
            return [Post]()
        }
    }
}
