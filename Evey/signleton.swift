//
//  signleton.swift
//  Evey
//
//  Created by PROJECTS on 24/05/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import Foundation


struct Service {
    static let sharedInstance = Service()
    
    func batteryLevel(beaconsWithBattery:NSArray){
        
        let url = URL(string: "\(serviceConstants.url)\((UserDefaults.standard.value(forKey: "OrganizationID")!))/api/beacons/battery")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: beaconsWithBattery, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.value(forKey: "authorization_Token") as? String, forHTTPHeaderField: serviceConstants.authorization)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                let re = try! JSONSerialization.jsonObject(with: data, options: [])
                print(re)
                
            }
        })
        task.resume()

    }

    
}
