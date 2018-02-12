//
//  ResetLogInViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 10/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class ResetLogInViewController: UIViewController ,UITextFieldDelegate{
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()

    @IBOutlet weak var titleLabel: UIImageView!
    
    @IBOutlet weak var resetLoginButton: UIButton!
    @IBOutlet weak var userNameTF: UITextField!

    @IBOutlet weak var scrollView: UIScrollView!
    
    var userNameframe = CGRect()
    var resetLogInFrame = CGRect()
    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        doneButton.tintColor = #colorLiteral(red: 0.2941176471, green: 0.7568627451, blue: 0.9254901961, alpha: 1)
            //UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        
        upArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "UpArrow"), style: .plain, target: self, action: #selector(self.upArrowClicked))
        upArrow.tintColor=UIColor.gray
        downArrow = UIBarButtonItem(image: #imageLiteral(resourceName: "DownArrow"), style: .plain, target: self, action: #selector(self.downArrowClicked))
        downArrow.tintColor=UIColor.gray
        
        let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.items = [upArrow, downArrow, flexibleSpaceWidth, doneButton]
        userNameTF.inputAccessoryView = keyboardDoneButtonView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        userNameTF.textContentType = UITextContentType("")


    }

    @IBAction func resetLoginAction(_ sender: Any) {
        dismissKeyboard()
        if userNameTF.text == "john_joseph" {
            
            // Create the dialog
            
            let msg = "Email Deliver a temporary password"
            let attString = NSMutableAttributedString(string: msg)
        
            let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                print("Completed")
            }
            
            // Create first button
            let buttonOne = DefaultButton(title: "OK") {
                let NPVC = self.storyboard?.instantiateViewController(withIdentifier :"NewPasswordViewController") as? NewPasswordViewController
                
                let transition = CATransition()
                transition.duration = 0
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.present(NPVC!, animated: false, completion: nil)
                
            }
            popup.addButtons([buttonOne])
            
            self.present(popup, animated: true, completion: nil)
        }else{
            
            // Create the dialog
            let msg = "Your details does not match with our records"
            let attString = NSMutableAttributedString(string: msg)

            
            
            
            let popup = PopupDialog(title: "", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                print("Completed")
            }
            
            // Create first button
            let buttonOne = DefaultButton(title: "Try again") {
            }
            popup.addButtons([buttonOne])
            
            self.present(popup, animated: true, completion: nil)
        }

    }
    func upArrowClicked(_ sender: Any) {
    }
    func downArrowClicked(_ sender: Any) {
    }

    func dismissKeyboard() {
        cancelAnimation()
        
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        animation()
       // titleLabel.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
          //  let scrollPoint = CGPoint(x: 0, y: self.view.frame.size.height/3.2)
           // self.scrollView.setContentOffset(scrollPoint, animated: true)
            
        })
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       // titleLabel.isHidden = true
        
       // self.continueBtn.backgroundColor = UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancelAnimation()
        resetLoginAction(self)
        return true
    }

    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        self.scrollView.frame = CGRect(x: screenWidth/8.152, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/5.442, width: screenWidth/1.329, height: screenHeight/1.472)
        self.scrollView.isHidden = true
        
        userNameTF.frame = CGRect(x: screenWidth/8.152, y:self.titleLabel.frame.origin.y+self.titleLabel.frame.height+screenHeight/1.638, width: screenWidth/1.329, height: screenHeight/11.910)

        resetLoginButton.frame = CGRect(x: screenWidth/8.152, y: userNameTF.frame.origin.y+userNameTF.frame.size.height+screenHeight/37.055, width: screenWidth/1.329, height: screenHeight/11.910)
        
        self.view.addSubview(userNameTF)
        self.view.addSubview(resetLoginButton)
        
        self.userNameframe = self.userNameTF.frame
        self.resetLogInFrame = self.resetLoginButton.frame
        
    }
    func animation(){
        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            
            
            UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {
                
                self.userNameTF.frame = CGRect(x: self.userNameTF.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/4.042, width: self.userNameTF.frame.width, height: self.userNameTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.resetLoginButton.frame = CGRect(x: self.resetLoginButton.frame.origin.x, y: self.userNameTF.frame.origin.y+self.userNameTF.frame.height+self.view.frame.height/37.055, width: self.resetLoginButton.frame.width, height: self.resetLoginButton.frame.height)
                
            }, completion: { (true) in
                
            })
            
            
            
        }, completion: { (true) in
        })
    }
    
    func cancelAnimation(){
        if userNameTF.isFirstResponder{
            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
                UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                    self.resetLoginButton.frame = self.resetLogInFrame

                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.userNameTF.frame = self.userNameframe
                    self.userNameTF.resignFirstResponder()


                }, completion: { (true) in
                    
                })
                
                
                
            }, completion: { (true) in
                
            })
            
        }
    }
    


}
