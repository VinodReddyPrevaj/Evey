//
//  TermsAndConditionsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 09/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    @IBOutlet weak var termsLbl: UILabel!
    
    @IBOutlet weak var datalbl: UILabel!
    
    @IBOutlet weak var scroll: UIScrollView!
    
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        navigationController?.navigationItem.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 30, vertical: -20), for: UIBarMetrics.default)
        
        let infoString = "Duty to Maintain Confidentiality Each Party agree s to hold the Confidential Information of the other Party in strict confidence, to use such information solely in the course of performing its obligations hereunder, and to make no disclosure of such information except in accordance with the terms of this Agreement . A Party may disclose Confidential Information only to its personnel and to personnel of its subcontractors who have a need to know such Confidential Information in order to fulfill its obligations hereunder and are subject to confidentiality obligations no less restrictive than those applicable hereunder. Each Party shall be primarily responsible and liable for any confidentiality breaches by its personnel and the personnel of its subcontractors.\r\n \r\nExceptions Notwithstanding anything to the contrary stated elsewhere in this Agreement, Confidential Information shall also not include information that the Receiving Party can demonstrate (i) was, at the time of its disclosure, or thereafter becomes part of the public domain through no fault of the Receiving Party or its personnel, agents or subcontractors, (ii) was known to the Receiving Party at the time of its disclosure from a source other than the Disclosing Party as evidenced by prior or contemporaneous writings, (iii) is subsequently learned from a third party not "
        
        
        let attString = NSMutableAttributedString(string: infoString)
        let font_regular = UIFont.systemFont(ofSize: 15.0)
        let font_bold = UIFont(name: ".SFUIText-Semibold", size: 16.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 0, length: 33))
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range:NSRange(location: 773, length: 11))
        attString.addAttribute(NSFontAttributeName, value: font_regular, range: NSRange(location: 34, length: 736))
        attString.addAttribute(NSFontAttributeName, value: font_regular, range: NSRange(location: 784, length: (infoString.characters.count)-782))
        
        datalbl.attributedText = attString
        datalbl.sizeToFit()
        
        datalbl.frame = CGRect(x: datalbl.frame.origin.x, y: datalbl.frame.origin.y, width: screenWidth/1.126, height: datalbl.frame.height)
        
        scroll.contentSize = CGSize(width: scroll.frame.width, height: datalbl.frame.height+datalbl.frame.origin.y+5)
        
    }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        let TACVC = storyboard?.instantiateViewController(withIdentifier :"TermsAndConditionsHomeViewController") as? TermsAndConditionsHomeViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        present(TACVC!, animated: false, completion: nil)
        
    }
    
    func layOuts(){
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        scroll.frame = CGRect(x: screenWidth/18.75, y: backBtn.frame.origin.y+backBtn.frame.height+screenHeight/24.703, width: screenWidth/1.112, height: screenHeight/1.237)
        
        termsLbl.frame = CGRect(x: 0, y: 0, width: scroll.frame.width, height: scroll.frame.height/21.56)
        
        datalbl.frame = CGRect(x: 0, y: termsLbl.frame.origin.y+termsLbl.frame.height+scroll.frame.height/21.56, width: screenWidth/1.126, height: scroll.frame.height-datalbl.frame.origin.y)
        
        buttonsView.frame =  CGRect(x: 0, y: scroll.frame.origin.y+scroll.frame.height, width: screenWidth, height: screenHeight/12.584)
        
        cancelBtn.frame = CGRect(x: screenWidth/1.275, y: buttonsView.frame.height/5.3, width: screenWidth/8.152, height: buttonsView.frame.height/1.606)
    }
}
