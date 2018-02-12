//
//  ViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 26/09/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import LocalAuthentication
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        let context:LAContext = LAContext();
        var error:NSError?
        var success:Bool;
        let reason:String = "Please authenticate using TouchID.";
        
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
        {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) -> Void in
           if error != nil {
            self.present(self.alertController("Error", message: "There was a problem verifying your identity.", style: .alert, actionTitle: "OK", actionStyle: .default), animated: true) { _ in }
                return
            }

            if (success) {
                  let SVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                 self.present(SVC!, animated: true, completion: {
                    
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
}

