//
//  FiveDayWeatherModel.swift
//  WeatherApp
//
//  Created by Shahir Abdul-Satar on 3/22/18.
//  Copyright © 2018 Ahmad Shahir Abdul-Satar. All rights reserved.
//

import Foundation


class FiveDayWeatherModel {
    
    var day: String?
    var time: String?
    var temp_max: String?
    
    
    init?(day: String, temp_max: String, time: String) {
        
        
        // Initialize stored properties.
        self.day = day
        self.time = time
        self.temp_max = temp_max
      
    }
    
    
    
    
    
}
