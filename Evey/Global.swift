//
//  Global.swift
//  EveyDemo
//
//  Created by PROJECTS on 23/01/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import Foundation

struct Constants {
    static var hallwayRSSI = Double()
    static var roomRSSI = Double()
    
    static var hallwayRange = Double()
    static var roomRange = Double()
    //App Constants
    
    static var dashBoard = Bool()
    static var dateArray = [Date]()
    static var rssiArray = NSMutableArray()
    static var finalRssi = [Int]()
    static var recentOpenVisits = NSArray()
    static var recentClosedVisits = NSArray()
    static var recentAllVists = NSMutableArray()
    static var room_Id = String()
    static var residents  = NSArray()
    static var administrators = NSArray()
    
    //to send a mail with beaconID
    static var nearBeacon = NSMutableDictionary()
    
    //beaconNames and Percentage
    static var beaconsWithPercentages = NSMutableArray()
    
    //Selected Cares Selected Dates Selected Residents Selected Staff
    
    static var selections = ["Start Date":NSDate(),"End Date": NSDate(),"VisitType":NSMutableArray(), "Cares":NSMutableArray(), "Residents":NSMutableArray(), "Staff": NSMutableArray()] as [String : Any]
    
    //Storing Care IDs with Care Names
    static var careIDs = NSMutableArray()
    
    //for validation in search screen
    static var validation = Bool()
}
struct Times {
    static var Constant_Start_Time = Date()
    
    static var Variable_Start_Time = Date()
    
    static var Previous_End_Time = [Date]()
    
    static var Leaving_Time = Date()
    
    static var Left_Time = [Date]()
}
struct ResidentDetails {
    static var response = NSDictionary()
    static var residents = NSArray()
    static var openCaresFromServer = NSMutableDictionary()
    static var closedCaresFromServer = NSMutableDictionary()
    static var openCareIDsArray = NSMutableArray()
    static var storedCares = [NSMutableDictionary]()
}
struct serviceConstants {
    
    static let url = "http://13.58.78.59:6060/"
    static let authorization = "x-access-token"
    static let trackCares = "track/cares"

}




extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}







