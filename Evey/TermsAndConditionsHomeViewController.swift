//
//  TermsAndConditionsHomeViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 09/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class TermsAndConditionsHomeViewController: UIViewController ,UIAlertViewDelegate{

    @IBOutlet weak var titleLabel: UIImageView!
    
    @IBOutlet weak var termsAndConditionsLbl: UILabel!
    
    @IBOutlet weak var topBorder: UILabel!
    
    @IBOutlet weak var importantLabel: UILabel!
    
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet weak var firstLbl: UILabel!
    
    @IBOutlet weak var secondLbl: UILabel!
    
    @IBOutlet weak var thirdLbl: UILabel!
    
    @IBOutlet weak var termsAndConditionsA: UILabel!
    
    @IBOutlet weak var privacyPolicyB: UILabel!
    
    @IBOutlet weak var termsAndConditionsBtn: UIButton!
    
    @IBOutlet weak var privacyAndPolicyBtn: UIButton!
    
    @IBOutlet weak var arrow1: UIImageView!
    @IBOutlet weak var arrow2: UIImageView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var disAgreeBtn: UIButton!
    @IBOutlet weak var agreeBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       UIBarButtonItem.appearance().setTitlePositionAdjustment(UIOffset.init(horizontal: 30, vertical: 0), for: UIBarMetrics.default)
        self.navigationController?.navigationItem.backBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 30, vertical: -20), for: UIBarMetrics.default)
        let image = UIImage(named: "eveyTitle.png")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(30), height: CGFloat(26))
        navigationController?.navigationBar.topItem?.titleView = imageView
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "eveyTitle.png")
        let infoString  = "Place Holder Content Not the real thing. During the use of this application or derivative products and/or technologies, the user may be exposed to or acquir e information regarding the business, projects, oper ations, finances, activities, affairs, research, develop ment, products, technology, technology architecture , business models, business plans, business proces ses, marketing and sales plans, clients, finances, pe rsonnel data, health plan rating and reimbursement f ormulas, computer hardware and software, compute r systems and programs, processing techniques an d generated outputs, intellectual property,"
        
        let attString = NSMutableAttributedString(string: infoString)
        let font_regular = UIFont.systemFont(ofSize: 17.0)
        let font_bold = UIFont(name: ".SFUIText-Semibold", size: 17.0)
        
        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 0, length: 20))
        attString.addAttribute(NSFontAttributeName, value: font_regular, range: NSRange(location: 21, length: 597))
        
        textView.attributedText = attString

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func termsAndCondition(_ sender: Any) {
        let TACVC = storyboard?.instantiateViewController(withIdentifier :"TermsAndConditionsViewController") as? TermsAndConditionsViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        present(TACVC!, animated: false, completion: nil)
        
        
    

    }

    @IBAction func privacyPolicy(_ sender: Any) {
        let PPVC = storyboard?.instantiateViewController(withIdentifier :"PrivacyPolicyViewController") as? PrivacyPolicyViewController
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        present(PPVC!, animated: false, completion: nil)
        // ModalService.present(PPVC!, presenter: TermsAndConditionsHomeViewController() , enterFrom: .left)


    }
    
    @IBAction func agreeAction(_ sender: Any) {
        // Create the dialog
        let msg = "I agree to Koble Technologies Terms and Conditions and Evey Privacy Policy"
        let attString = NSMutableAttributedString(string: msg)
//        let font_regular = UIFont.systemFont(ofSize: 17.0)
//        let font_bold = UIFont(name: ".SFUIText-Semibold", size: 17.0)
//        
//        attString.addAttribute(NSFontAttributeName, value: font_bold!, range: NSRange(location: 0, length: 20))
//        attString.addAttribute(NSFontAttributeName, value: font_regular, range: NSRange(location: 21, length: 597))


        let popup = PopupDialog(title: "Terms and Conditions", message:attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "Cancel") {
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "Agree") {
            let svc = self.storyboard?.instantiateViewController(withIdentifier: "OrganizationViewController")as! OrganizationViewController
            svc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            svc.modalTransitionStyle = UIModalTransitionStyle.partialCurl
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.present(svc, animated: false, completion: {
            })
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)

    }
    
    @IBAction func disagreeAction(_ sender: Any) {
        // Create the dialog
        let msg = "You must agree to the Terms and Conditions to use this application"
        let attString = NSMutableAttributedString(string: msg)

        
        

        let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK") {
        }
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
        
        

    }
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        titleLabel.frame =  CGRect(x: screenWidth/2.737, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        termsAndConditionsLbl.frame = CGRect(x: screenWidth/13.39, y: titleLabel.frame.origin.y+titleLabel.frame.height+screenHeight/35.105, width: screenWidth/1.175, height: screenHeight/15.511)

        topBorder.frame = CGRect(x: 0, y: termsAndConditionsLbl.frame.origin.y+termsAndConditionsLbl.frame.height+screenHeight/55.583, width: screenWidth, height: 1)

        importantLabel.frame = CGRect(x: screenWidth/23.437, y: topBorder.frame.origin.y+topBorder.frame.height+screenHeight/51.307, width: screenWidth/1.150, height: screenHeight/11.305)
        
        optionsView.frame = CGRect(x: 0, y: importantLabel.frame.origin.y+importantLabel.frame.height+screenHeight/35.105, width: screenWidth, height: screenHeight/6.67)
        
        
        firstLbl.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)

        termsAndConditionsA.frame = CGRect(x: screenWidth/16.304, y: firstLbl.frame.origin.y+firstLbl.frame.height+optionsView.frame.height/7.692, width: screenWidth/1.696, height: optionsView.frame.height/4.347)

        arrow1.frame =  CGRect(x: termsAndConditionsA.frame.origin.x+termsAndConditionsA.frame.width+screenWidth/4.166, y: firstLbl.frame.origin.y+firstLbl.frame.height+optionsView.frame.height/7.692, width: screenWidth/16.304, height: optionsView.frame.height/4.347)

        
        termsAndConditionsBtn.frame = CGRect(x: 0, y: 0, width: screenWidth, height: optionsView.frame.height/2.040)
        
        secondLbl.frame = CGRect(x: 0, y: termsAndConditionsA.frame.origin.y+termsAndConditionsA.frame.height+optionsView.frame.height/7.692, width: screenWidth, height: 1)

        
        privacyPolicyB.frame =  CGRect(x: screenWidth/16.304, y: secondLbl.frame.origin.y+secondLbl.frame.height+optionsView.frame.height/7.692, width: screenWidth/1.696, height: optionsView.frame.height/4.347)

        
        arrow2.frame = CGRect(x: privacyPolicyB.frame.origin.x+privacyPolicyB.frame.width+screenWidth/4.166, y: secondLbl.frame.origin.y+secondLbl.frame.height+optionsView.frame.height/7.692, width: screenWidth/16.304, height: optionsView.frame.height/4.347)

        
        privacyAndPolicyBtn.frame = CGRect(x: 0, y: secondLbl.frame.origin.y, width: screenWidth, height: optionsView.frame.height/2.040)

        
        thirdLbl.frame = CGRect(x: 0, y: privacyPolicyB.frame.origin.y+privacyPolicyB.frame.height+optionsView.frame.height/8.333, width: screenWidth, height: 1)


        textView.frame = CGRect(x: screenWidth/18.75, y: optionsView.frame.origin.y+optionsView.frame.height, width: screenWidth/1.126, height: screenHeight/2.253)
        
        buttonsView.frame = CGRect(x: 0, y: textView.frame.origin.y+textView.frame.height, width: screenWidth, height: screenHeight/12.584)

        disAgreeBtn.frame = CGRect(x: screenWidth/15, y: buttonsView.frame.height/4.818, width: screenWidth/5.281, height: buttonsView.frame.height/1.766)
        
        agreeBtn.frame = CGRect(x: disAgreeBtn.frame.origin.x+disAgreeBtn.frame.width+screenWidth/1.963, y: buttonsView.frame.height/4.818, width: screenWidth/7.075, height: buttonsView.frame.height/1.766)
        
        
        
    }

}
