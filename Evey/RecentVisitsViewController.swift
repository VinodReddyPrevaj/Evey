//
//  RecentVisitsViewController.swift
//  EveyDemo
//
//  Created by PROJECTS on 23/11/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit
import CoreLocation
class RecentVisitsViewController: UIViewController , UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var closedBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var eveyTitle: UIImageView!
    
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var recentVisitsLbl: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    @IBOutlet weak var buttonsViewUpBorder: UILabel!
    
    @IBOutlet weak var visitsButtonsView: UIView!
    
    var screenNameStr = String()
    var tab1VC:OpenVisitsTableViewController! = nil
    var tab2VC:ClosedVisitsTableViewController! = nil
    var tab3VC:AllVisitsTableViewController! = nil
    
    private var pageController: UIPageViewController!
    private var arrVC:[UIViewController] = []
    private var currentPage: Int!
    //for beacon Detection
    var acceptableDistance = Double()
    var rssiArray = [0]
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "7878062c-1308-4ad0-9169-ec6f31c86bfa")!, identifier: "TestOne")
    
    var popup = PopupDialog(title: "", message: NSAttributedString(), buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        layOuts()
        currentPage = 0
        createPageViewController()
        segmentedController.addTarget(self, action: #selector(self.selectPageIndexBySegmentControl), for: UIControlEvents.valueChanged)
        segmentedController.layer.cornerRadius = segmentedController.frame.height/4.8333
        // to detect beacons
        
        locationManager.delegate=self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        locationManager.startMonitoring(for: region)
        acceptableDistance = 2.0
        rssiArray.removeAll()
        let msg = "Are you finished with your visit or are you continuing care?"
        let attString = NSMutableAttributedString(string: msg)
        popup = PopupDialog(title: "", message: attString, buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        if screenNameStr.characters.count != 0{
        if screenNameStr == "Menu" {
            UserDefaults.standard.set("MenuViewController", forKey: "from")

        }else{
            UserDefaults.standard.set("ResidentSelect", forKey: "from")
        }
        
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageController.reloadInputViews()
    }
    
    //MARK: - CreatePagination
    
    private func createPageViewController() {
        
        pageController = UIPageViewController.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
        
        pageController.view.backgroundColor = UIColor.clear
        pageController.delegate = self
        pageController.dataSource = self
        
        for svScroll in pageController.view.subviews as! [UIScrollView] {
            svScroll.delegate = self
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageController.view.frame = CGRect(x: 0, y: self.segmentedController.frame.origin.y+self.segmentedController.frame.height+self.view.frame.height/66.7, width: self.view.frame.size.width, height: self.view.frame.height/1.437)
            
            
            self.buttonsView.frame = CGRect(x: 0, y: (self.pageController.view.frame.origin.y+self.pageController.view.frame.height), width: self.view.frame.width, height: self.view.frame.height/12.584)
            
            self.cancelBtn.frame = CGRect(x: self.view.frame.width/15, y: self.buttonsView.frame.size.height/4.818, width: self.view.frame.width/5.281, height: self.buttonsView.frame.size.height/1.766)
            
            self.doneBtn.frame = CGRect(x: self.cancelBtn.frame.origin.x+self.cancelBtn.frame.size.width+self.view.frame.width/1.963, y: self.buttonsView.frame.size.height/4.818, width: self.view.frame.width/5.281, height: self.buttonsView.frame.size.height/1.766)
            
            self.buttonsViewUpBorder.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)

        }
        
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil)
        tab1VC = homeStoryboard.instantiateViewController(withIdentifier: "OpenVisitsTableViewController") as! OpenVisitsTableViewController
        tab2VC = homeStoryboard.instantiateViewController(withIdentifier: "ClosedVisitsTableViewController") as! ClosedVisitsTableViewController
        tab3VC = homeStoryboard.instantiateViewController(withIdentifier: "AllVisitsTableViewController") as! AllVisitsTableViewController
        
        arrVC = [tab1VC, tab2VC, tab3VC]
        tab1VC.height = self.view.frame.height
        pageController.setViewControllers([tab1VC], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        self.addChildViewController(pageController)
        self.view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
    }
    
    
    private func indexofviewController(viewCOntroller: UIViewController) -> Int {
        if(arrVC .contains(viewCOntroller)) {
            return arrVC.index(of: viewCOntroller)!
        }
        
        return -1
    }
    
    //MARK: - Pagination Delegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = indexofviewController(viewCOntroller: viewController)
        
        if(index != -1) {
            index = index - 1
        }
        
        if(index < 0) {
            return nil
        }
        else {
            return arrVC[index]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = indexofviewController(viewCOntroller: viewController)
        
        if(index != -1) {
            index = index + 1
        }
        
        if(index >= arrVC.count) {
            return nil
        }
        else {
            return arrVC[index]
        }
        
    }
    
    func pageViewController(_ pageViewController1: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if(completed) {
            currentPage = arrVC.index(of: (pageViewController1.viewControllers?.last)!)
            segmentedController.selectedSegmentIndex = currentPage
        }
        
    }
    
    //MARK: - Set Top bar after selecting Option from Top Tabbar

    @IBAction func cancelButton(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "from") as! String == "ResidentSelect" {
        //if screenNameStr == "ResidentSelect" {
          let residentSelect = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopMonitoring(for: region)
            self.locationManager.stopRangingBeacons(in: region)
            self.present(residentSelect, animated: false, completion: nil)
        }else{
            let dashBoardViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            let transition = CATransition()
            transition.duration = 0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.add(transition, forKey: kCATransition)
            self.locationManager.stopMonitoring(for: region)
            self.locationManager.stopRangingBeacons(in: region)

            self.present(dashBoardViewController, animated: false, completion: nil)
 
        }
    }
    
    
    @IBAction func menuBtnAction(_ sender: Any) {
        let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.locationManager.stopMonitoring(for: region)
        self.locationManager.stopRangingBeacons(in: region)

        self.present(menuViewController, animated: false, completion: nil)
    }
    func layOuts(){
        
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        backBtn.frame = CGRect(x: screenWidth/23.437, y: screenHeight/23, width: screenWidth/18.75, height: screenHeight/33.35)
        
        eveyTitle.frame = CGRect(x: backBtn.frame.origin.x+backBtn.frame.size.width+screenWidth/3.712, y: screenHeight/23.821, width: screenWidth/3.75, height: screenHeight/27.791)
        
        menuBtn.frame = CGRect(x: eveyTitle.frame.origin.x+eveyTitle.frame.size.width+screenWidth/4.213, y: screenHeight/23.437, width: screenWidth/11.363, height: screenHeight/31.761)
        
        
        recentVisitsLbl.frame = CGRect(x: screenWidth/23.437, y: eveyTitle.frame.origin.y+eveyTitle.frame.size.height+screenHeight/66.7, width: screenWidth/1.518, height: screenHeight/21.516)
        
        segmentedController.frame = CGRect(x: screenWidth/23.437, y: recentVisitsLbl.frame.origin.y+recentVisitsLbl.frame.height+screenHeight/55.583, width: screenWidth/1.093, height: screenHeight/19.057)
    }
    func selectPageIndexBySegmentControl(){
        
        switch segmentedController.selectedSegmentIndex {
        case 0:
            
            pageController.setViewControllers([arrVC[0]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
            currentPage = 0
            
        case 1:
            if currentPage > 1{
                pageController.setViewControllers([arrVC[1]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
                currentPage = 1
            }else{
                pageController.setViewControllers([arrVC[1]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                currentPage = 1
                
            }
        case 2:
            if currentPage < 2 {
                pageController.setViewControllers([arrVC[2]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                currentPage = 2
                
                
            }else{
                pageController.setViewControllers([arrVC[2]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
                currentPage = 2
                
            }
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{$0.proximity != CLProximity.unknown}
        if (knownBeacons.count>0) {
            let closeBeacon = knownBeacons[0] as CLBeacon
            var maj =  Int()
            maj =  8
            let previousBeaconArray : [Int] = UserDefaults.standard.value(forKey: "PreviousBeaconArray") as! [Int]
            if previousBeaconArray.count == 0 {
                if closeBeacon.major.intValue == maj {
                }else{
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-57-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 4.0 {
                        if dis <= 4.0{
                            UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "PreviousBeaconArray")
                            
                            popup.dismiss(animated: true, completion: {
                                UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                
                            })
                            locationManager.stopRangingBeacons(in: region)
                            locationManager.stopMonitoring(for: region)
                            let nvc = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                            self .present(nvc, animated: true, completion: {
                                UserDefaults.standard.set([], forKey: "SelectedArray")
                                UserDefaults.standard.set("", forKey: "Came From")
                            })
                        }
                    }
                }
                
            }else{
                if closeBeacon.major.intValue == maj {
                    rssiArray.append(closeBeacon.rssi)
                    if rssiArray.count == 1 {
                        let sumedrssi = rssiArray.reduce(0, +)
                        let processedrssi = sumedrssi/1
                        let base = Double(10)
                        let power = Double(-59-(processedrssi))/Double(10*2)
                        let dis = pow(Double(base), power)
                        print("\(closeBeacon.major.intValue)")
                        print("\(closeBeacon.rssi)")
                        print("accuracy \(closeBeacon.accuracy)")
                        print(dis)
                        rssiArray.removeAll()
                        //if closeBeacon.accuracy <= 3.0 {
                        if dis <= 3{
                            print("After")
                            UserDefaults.standard.set("Center", forKey: "PlaceOfAlert")
                            let msg = "Are you finished with your visit or are you continuing care?"
                            let attString = NSMutableAttributedString(string: msg)
                            
                            popup = PopupDialog(title: "", message: attString,  buttonAlignment: .vertical, transitionStyle: .zoomIn, gestureDismissal: false, completion: {
                                
                            })

                            let pauseButton = CancelButton(title: "Pause", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                        let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                        self.locationManager.stopMonitoring(for: region)
                                        self.locationManager.stopRangingBeacons(in: region)
                                    
                                            RSVC.alertForPause = true
                                    
                                        self.present(RSVC, animated: true, completion: {
                                            UserDefaults.standard.set([], forKey: "NamesArray")
                                            UserDefaults.standard.set([], forKey: "SelectedArray")
                                            UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                            UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                            
                                        })
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForPause = true
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }
                                
                            })
                            
                            let continueButtin = CancelButton(title: "Continue", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    
                                    RSVC.alertForContinue = true
                                    
                                    self.present(RSVC, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForContinue = true
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }

                            })
                            
                            let completeButton = CancelButton(title: "Complete", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count == 0 && selectedArray.count == 0 {
                                    let RSVC = self.storyboard?.instantiateViewController(withIdentifier: "ResidentSelectTestViewController") as! ResidentSelectTestViewController
                                    self.locationManager.stopMonitoring(for: region)
                                    self.locationManager.stopRangingBeacons(in: region)
                                    
                                    RSVC.alertForComplete = true
                                    
                                    self.present(RSVC, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "NamesArray")
                                        UserDefaults.standard.set([], forKey: "SelectedArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                }else{
                                    let nvc = self.storyboard?.instantiateViewController(withIdentifier: "CareSelectViewController") as! CareSelectViewController
                                    self.locationManager.stopRangingBeacons(in: region)
                                    self.locationManager.stopMonitoring(for: region)
                                    nvc.alertForComplete = true
                                    self.present(nvc, animated: true, completion: {
                                        UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                        
                                    })
                                    
                                }

                            })
                            
                            let deleteButton = DestructiveButton(title: "Delete", action: {
                                
                                UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                            })
                            popup.addButtons([pauseButton,continueButtin,completeButton,deleteButton])
                            
                            let hallwayBeaconArray : [Int] = UserDefaults.standard.value(forKey: "HallwayBeaconArray") as! [Int]
                            if hallwayBeaconArray.count == 0 {
                                let namesArray : [String] = UserDefaults.standard.value(forKey: "NamesArray") as! [String]
                                let selectedArray : [String] = UserDefaults.standard.value(forKey: "SelectedArray") as! [String]
                                if namesArray.count >= 1 && selectedArray.count == 0{
                                    let DVC = storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                                    UserDefaults.standard.set([], forKey: "HallwayBeaconArray")
                                    UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    UserDefaults.standard.set([], forKey: "NamesArray")
                                    UserDefaults.standard.set([], forKey: "SelectedArray")
                                    locationManager.stopRangingBeacons(in: region)
                                    locationManager.stopMonitoring(for: region)
                                    
                                    self.present(DVC, animated: true, completion: nil)
                                }else{
                                    

                                    self.present(popup, animated: true, completion: {
                                        UserDefaults.standard.set("Top", forKey: "PlaceOfAlert")

                                        UserDefaults.standard.set([closeBeacon.major.intValue], forKey: "HallwayBeaconArray")
                                        UserDefaults.standard.set([], forKey: "PreviousBeaconArray")
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }


}
