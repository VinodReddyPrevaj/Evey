//
//  WakeUpViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 06/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import LocalAuthentication
class WakeUpViewController: UIViewController {
    var mybeacon = String()

    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var eveyImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        let loggedInUserName: UserDefaults? = UserDefaults.standard

        self.userNameTextField.text = loggedInUserName?.string(forKey: "loggedInUserName")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueBtnAction(_ sender: Any) {
        let context:LAContext = LAContext();
        var error:NSError?
        var _:Bool;
        let reason:String = "Please authenticate using TouchID.";
        
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
        {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) -> Void in
                if error != nil {
                    self.present(self.alertController("Error", message: "There was a problem verifying your identity.", style: .alert, actionTitle: "OK", actionStyle: .default), animated: true) { _ in }
                    return
                }
                
                if (success) {
                    let dashBoardVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController
                    dashBoardVC?.nameLabel.text = self.userNameTextField.text
                    self.present(dashBoardVC!, animated: true, completion: {
                        
                    })
                }
                else
                {
                    self.present(self.alertController("Error", message: "You are not the device owner.", style: .alert, actionTitle: "OK", actionStyle: .default), animated: true) { _ in }
                }
            });
        }else{
            present(alertController("Error", message: "Your device cannot authenticate using TouchID.", style: .alert, actionTitle: "OK", actionStyle: .default), animated: true) { _ in }
        }

    }

    func alertController(_ title: String, message: String, style: UIAlertControllerStyle, actionTitle: String, actionStyle: UIAlertActionStyle) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: actionTitle, style: actionStyle, handler: nil)
        alert.addAction(action)
        return alert
    }
    @IBAction func logInButton(_ sender: Any) {
        
        let SVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(SVC!, animated: false, completion: {
            
        })
  
    }
    
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        eveyImage.frame = CGRect (x: screenWidth/10.714, y: screenHeight/3.605, width: screenWidth/1.225, height: screenHeight/3.994)
        
        userNameTextField.frame = CGRect(x: screenWidth/15, y: eveyImage.frame.origin.y+eveyImage.frame.size.height+screenHeight/6.233, width: screenWidth/1.150, height: screenHeight/14.822)

        continueBtn.frame = CGRect(x: screenWidth/15, y: userNameTextField.frame.origin.y+userNameTextField.frame.size.height+screenHeight/30.318, width: screenWidth/1.150, height: screenHeight/13.34)

        logInBtn.frame = CGRect(x: screenWidth/15, y: continueBtn.frame.origin.y+continueBtn.frame.size.height+screenHeight/41.687, width: screenWidth/1.150, height: screenHeight/13.34)

    }
    
    

}
