//
//  DataModel.swift
//  WeatherApp
//
//  Created by Shahir Abdul-Satar on 3/21/18.
//  Copyright © 2018 Ahmad Shahir Abdul-Satar. All rights reserved.
//

import Foundation
import UIKit
import os.log


struct PropertyKey {
    static let cityName = "cityName"
    static let zipcode = "zipcode"
    static let temperature = "temperature"
    static let id = "id"

}




class WeatherModel: NSObject, NSCoding {

     var cityName: String?
     var zipcode: String?
     var temperature: String?
    var id: String?
    
    init?(cityName: String, zipcode: String, temperature: String, id: String) {
        
        
        // Initialize stored properties.
        self.cityName = cityName
        self.zipcode = zipcode
        self.temperature = temperature
        self.id = id
    }
    
    
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cityName, forKey: PropertyKey.cityName)
        aCoder.encode(zipcode, forKey: PropertyKey.zipcode)
        aCoder.encode(temperature, forKey: PropertyKey.temperature)
        aCoder.encode(id, forKey: PropertyKey.id)

    }
    
   
    required convenience init?(coder aDecoder: NSCoder) {
        guard let cityName = aDecoder.decodeObject(forKey: PropertyKey.cityName) as? String
            else {
                if #available(iOS 10.0, *) {
                    os_log("Unable to decode the name for a Weather Object.", log: OSLog.default, type: .debug)
                } else {
                    // Fallback on earlier versions
                }
            return nil
        }
        
        let zipcode = aDecoder.decodeObject(forKey: PropertyKey.zipcode) as? String
        
        let temperature = aDecoder.decodeObject(forKey: PropertyKey.temperature) as? String
        
        let id = aDecoder.decodeObject(forKey: PropertyKey.id) as? String
        // Must call designated initializer.
        self.init(cityName: cityName, zipcode: zipcode!, temperature: temperature!, id: id!)
    }
    
    
    
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("weather")
    
    
   


}
