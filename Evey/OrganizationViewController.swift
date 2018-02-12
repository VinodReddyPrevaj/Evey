//
//  OrganizationViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 01/12/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

class OrganizationViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var eveyImage: UIImageView!
    @IBOutlet weak var titleLabel: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var organizationIDTF: UITextField!
    var upArrow = UIBarButtonItem()
    var downArrow = UIBarButtonItem()
    
    var eveyImageFrame = CGRect()
    var organizationIDFrame = CGRect()
    var continueFrame = CGRect()
    let flexibleSpaceWidth = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
        organizationIDTF.inputAccessoryView = keyboardDoneButtonView
        organizationIDTF.textContentType = UITextContentType("")

        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        print(delegate.dt)
        layOuts()
    }
    
    
    func upArrowClicked(_ sender: Any) {
//        if passwordTF.isFirstResponder {
//            userNameTF.becomeFirstResponder()
//        }
    }
    func downArrowClicked(_ sender: Any) {
//        if userNameTF.isFirstResponder {
//            passwordTF.becomeFirstResponder()
//            
//        }
    }
    
    func dismissKeyboard() {
        
        cancelAnimation()
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animation()
//        UIView.animate(withDuration: 0.3, animations: {
//            let scrollPoint = CGPoint(x: 0, y: self.eveyImage.frame.origin.y+self.eveyImage.bounds.size.height)
//            self.scrollView.setContentOffset(scrollPoint, animated: true)
//            
//        })
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.continueBtn.backgroundColor = #colorLiteral(red: 0.2941176471, green: 0.7568627451, blue: 0.9254901961, alpha: 1)
            //UIColor(red: 75.0 / 255.0, green: 193.0 / 255.0, blue: 236.0 / 255.0, alpha: 1)
       // scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cancelAnimation()
        continueBtnAction(self)
        return true
    }

    @IBAction func continueBtnAction(_ sender: Any) {
        if (organizationIDTF.text?.characters.count)! > 0{
            cancelAnimation()
            let organizationID  = organizationIDTF.text?.replacingOccurrences(of: " ", with: "")
            let url:NSURL = NSURL(string: "http://13.58.78.59:6060/evey/api/client/\((organizationID)!)")!
            let sessionConfig = URLSessionConfiguration.default
           // sessionConfig.timeoutIntervalForRequest = 3.0
           // sessionConfig.timeoutIntervalForResource = 60.0
            let session = URLSession(configuration: sessionConfig)

            //let session = URLSession.shared
            let request = NSMutableURLRequest (url: url as URL)
            let task = session.dataTask(with: request as URLRequest){ (data,response,error)in
            if let data = data {
                let responseArray = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String:String]]
                    print(responseArray)
                if responseArray.count > 0 {
                    let clientDictionary =  responseArray[0]
                    UserDefaults.standard.set("\(clientDictionary["client_key"]!)", forKey: "OrganizationID")
                    DispatchQueue.main.async( execute: {
                            
                            let logInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                            
                            let transition = CATransition()
                            transition.duration = 0
                            transition.type = kCATransitionPush
                            transition.subtype = kCATransitionFromRight
                            self.view.window!.layer.add(transition, forKey: kCATransition)
                            
                            self.present(logInVC, animated: false, completion: nil)
                            print(clientDictionary["client_key"]!)
                    })
                }else{
                        
                    let msg = "Your login does not match our records"
                    let attString = NSMutableAttributedString(string: msg)
                    
                    let popup = PopupDialog(title: "Oops!", message: attString, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false) {
                            print("Completed")
                    }
                        
                        // Create first button
                    let buttonOne = DefaultButton(title: "Try Again") {
                            self.organizationIDTF.text = nil
                            
                    }
                    
                    popup.addButtons([buttonOne])
                        // Present dialog
                    self.present(popup, animated: true, completion: nil)
                }

        }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // do something here...
                        print("Internet Connection OK")
                    }
                    print("statusCode: \(httpResponse.statusCode)")
                }
        
         //to set timeout for urlsession
        if let error = error {
            print(error)
           print(error.localizedDescription)
        }
        //else

                
        }
            task.resume()

        }
        
        
        
        

    }
    func layOuts(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
       
        self.titleLabel.frame = CGRect(x: screenWidth/2.757, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        self.scrollView.frame = CGRect(x: screenWidth/8.152, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/3.004, width: screenWidth/1.329, height: screenHeight/1.472)
        self.scrollView.isHidden = true
       
        eveyImage.frame = CGRect(x: screenWidth/6.696, y: titleLabel.frame.origin.y+titleLabel.frame.size.height+screenHeight/3.004, width: screenWidth/1.425, height: screenHeight/5.605)
        
        organizationIDTF.frame = CGRect(x: screenWidth/8.152, y: eveyImage.frame.origin.y+eveyImage.frame.size.height+screenHeight/10.106, width: screenWidth/1.329, height: screenHeight/11.910)

        continueBtn.frame = CGRect(x: screenWidth/8.152, y: organizationIDTF.frame.origin.y+organizationIDTF.frame.size.height+screenHeight/37.055, width: scrollView.frame.size.width, height: screenHeight/11.910)
        
        self.view.addSubview(eveyImage)
        self.view.addSubview(organizationIDTF)
        self.view.addSubview(continueBtn)
        
        self.eveyImageFrame = self.eveyImage.frame
        self.organizationIDFrame = self.organizationIDTF.frame
        self.continueFrame = self.continueBtn.frame
    }
    
    
    func animation(){
        self.titleLabel.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.titleLabel.alpha = 1.0
            
        }) { (true) in
            self.titleLabel.isHidden = false
        }

        UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
            
            self.eveyImage.alpha = 1.0
            UIView.animate(withDuration: 3, delay: 0.01, options: [], animations: {() -> Void in
                self.eveyImage.frame = CGRect(x: self.eveyImage.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/10.106, width: self.eveyImage.frame.width, height: self.eveyImage.frame.height)
                
                self.eveyImage.alpha = 0.0
            }, completion: {(_ finished: Bool) -> Void in
                self.eveyImage.isHidden = true
                
            })
            
            UIView.animate(withDuration: 1, delay:0.0, options: [], animations: {
                
                self.organizationIDTF.frame = CGRect(x: self.organizationIDTF.frame.origin.x, y: (self.titleLabel.frame.origin.y+self.titleLabel.frame.height)+self.view.frame.height/3.605, width: self.organizationIDTF.frame.width, height: self.organizationIDTF.frame.height)
                
            }, completion: { (true) in
                
            })
            UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                self.continueBtn.frame = CGRect(x: self.continueBtn.frame.origin.x, y: self.organizationIDTF.frame.origin.y+self.organizationIDTF.frame.height+self.view.frame.height/37.055, width: self.continueBtn.frame.width, height: self.continueBtn.frame.height)
                
            }, completion: { (true) in
                
            })
            
            
        },completion: { (true) in
            
        })
    }
    
    func cancelAnimation(){
        if organizationIDTF.isFirstResponder{
            self.titleLabel.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.titleLabel.alpha = 0.0
            }) { (true) in
                self.titleLabel.isHidden = true
            }
            
            self.eveyImage.alpha = 1.0
            UIView.animate(withDuration: 0.3, delay:0, options: [], animations: {
                UIView.animate(withDuration: 1, delay:0, options: [], animations: {
                    self.continueBtn.frame = self.continueFrame
                    UIView.animate(withDuration: 1, delay:0.2, options: [], animations: {
                        
                        self.eveyImage.frame = self.eveyImageFrame
                        
                        self.eveyImage.alpha = 1.0
                        self.eveyImage.isHidden = false
                    }, completion: { (true) in
                    })
                    
                }, completion: { (true) in
                    
                })
                UIView.animate(withDuration: 1, delay:0.1, options: [], animations: {
                    self.organizationIDTF.frame = self.organizationIDFrame
                    
                }, completion: { (true) in
                    
                })

                self.eveyImage.alpha = 0.0
                UIView.animate(withDuration: 1, delay:0.3, options: [], animations: {
                    self.eveyImage.frame = self.eveyImageFrame
                    self.organizationIDTF.resignFirstResponder()
                    self.eveyImage.alpha = 1.0
                    
                }, completion: { (true) in
                    self.eveyImage.isHidden = false
                })
                
                
                
            }, completion: { (true) in
                
            })
            
        }
    }


}
