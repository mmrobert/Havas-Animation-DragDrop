//
//  ViewController.swift
//  Havas
//
//  Created by boqian cheng on 2018-05-30.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import Moya
import Alamofire
import RxSwift

let netWorkProvider: MoyaProvider = MoyaProvider<FetchTimeAPI>()
let disposeBag = DisposeBag()

class ViewController: UIViewController {
    
    @IBOutlet weak var viewToDrag: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var slidingViewHeight: NSLayoutConstraint!
    
    private var originalCenter: CGPoint?
    
    private var fetchTimer: Timer!
    
    private var alertPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.viewToDrag.isUserInteractionEnabled = true
        self.originalCenter = self.viewToDrag.center
        
        self.view.bringSubview(toFront: self.viewToDrag)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.viewDragged(gesture:)))
        self.viewToDrag.addGestureRecognizer(gesture)
        
        self.viewToDrag.startRotating()
        
        fetchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchTimer.invalidate()
    }
    
    @objc func runTimedCode() {
        let parameters: [String:Any] = ["address": "Santa Clara US"]
        self.fetchTimeFromService(parameters: parameters)
    }
    
    @objc func viewDragged(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            self.slidingUp()
        }
        
        let transition = gesture.translation(in: self.view)
        let viewDrag = gesture.view!
        viewDrag.center = CGPoint(x: viewDrag.center.x + transition.x, y: viewDrag.center.y + transition.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
        
        if gesture.state == UIGestureRecognizerState.ended, let _originalCenter = originalCenter {
            
            // the center y of dragged view in moving
            let viewDragY = viewDrag.center.y
            // the center y of bottom sliding view after sliding up
            let slidingY = self.view.bounds.height - 75
            
            // the center of bottom sliding view for dropping
            let slidingCenter = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height - 75)
            // the center y distance between drag view and sliding view
            let centerDistance = slidingY - viewDragY
            
            // min y distance between drag view and sliding view for "at least 25% in the drawer area"
            // ??
            let minDistance: CGFloat = 125 - 50 * 0.25
            
            if centerDistance < minDistance {
                // drop view
                viewDrag.center = slidingCenter
            } else {
                viewDrag.center = _originalCenter
                self.slidingDown()
            }
        }
    }
    
    func slidingUp() {
        // animate constraint from storyboard
        self.slidingViewHeight.constant = 150
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.view.layoutIfNeeded() ?? ()
            }, completion: nil)
    }
    
    func slidingDown() {
        // animate constraint from storyboard
        self.slidingViewHeight.constant = 25
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.view.layoutIfNeeded() ?? ()
            }, completion: nil)
    }
    
    func fetchTimeFromService(parameters: [String:Any]) {
        
        netWorkProvider.rx.request(.fetch(paras: parameters)).subscribe { [unowned self] event in
            switch event {
            case .success(let response):
                do {
                    if let jsonResult = try response.mapJSON() as? [String:Any?] {
                        if let succ = jsonResult["success"] as? Bool, succ {
                            if let resultArr = jsonResult["results"] as? [[String:Any?]] {
                                if resultArr.count > 0 {
                                    self.parseNetworkData(resultArr: resultArr)
                                }
                            }
                        } else if let msg = jsonResult["msg"] as? String, !self.alertPresented {
                            self.presentAlert(aTitle: "Net Working for Time Fetch", withMsg: msg, confirmTitle: "OK")
                            self.alertPresented = true
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in fetch time: \(error.localizedDescription)")
                }
            case .error(let error):
                debugPrint("Networking Error in fetch time: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
    }
    
    func parseNetworkData(resultArr: [[String:Any?]]) {
        let result1 = resultArr[0]
        if let timeInfo = result1["time_info"] as? [String:Any?], let localTime = timeInfo["local_time"] as? [String:String], let timeH = localTime["format_4"] {
            let timeSplit = timeH.components(separatedBy: " ")
            if timeSplit.count > 1 {
                self.timeLabel.text = timeSplit[1]
            }
        }
    }
    
    func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(acts)
        self.present(alert, animated: true, completion: nil)
    }
}
