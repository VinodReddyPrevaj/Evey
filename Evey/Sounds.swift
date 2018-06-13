//
//  Sounds.swift
//  Evey
//
//  Created by PROJECTS on 02/05/18.
//  Copyright © 2018 Prevaj. All rights reserved.
//

import Foundation
import AVFoundation
public class Sounds {
    class func roomSound () {
        var audioPlayer = AVAudioPlayer()
        
        let url = Bundle.main.url(forResource: "Room", withExtension: "mp3")
        do {
            audioPlayer = try! AVAudioPlayer.init(contentsOf: url!)
            audioPlayer.prepareToPlay()
        }
        audioPlayer.play()

    }
    class func hallwaySound(){
        var audioPlayer = AVAudioPlayer()
        
        let url = Bundle.main.url(forResource: "hallway", withExtension: "mp3")
        do {
            audioPlayer = try! AVAudioPlayer.init(contentsOf: url!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }
    class func openVisitSound(){
        var audioPlayer = AVAudioPlayer()
        
        let url = Bundle.main.url(forResource: "Open Visits", withExtension: "mp3")
        do {
            audioPlayer = try! AVAudioPlayer.init(contentsOf: url!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
    }

}
