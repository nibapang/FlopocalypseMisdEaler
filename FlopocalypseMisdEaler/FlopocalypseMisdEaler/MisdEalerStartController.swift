//
//  ViewController.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//

import UIKit
import Reachability

class MisdEalerStartController: UIViewController {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var reachability: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.activityView.hidesWhenStopped = true
        misdEalerLoadAdsData()
    }

    private func misdEalerLoadAdsData() {
        guard misdEalerNeedLoadAdBannData() else { return }
        
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to create Reachability: \(error)")
            return
        }
        
        if reachability.connection == .unavailable {
            reachability.whenReachable = { [weak self] _ in
                self?.reachability.stopNotifier()
                self?.misdEalerGetLoadAdsData()
            }
            reachability.whenUnreachable = { _ in }
            
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier: \(error)")
            }
        } else {
            misdEalerGetLoadAdsData()
        }
    }

    private func misdEalerGetLoadAdsData() {
        activityView.startAnimating()
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            activityView.stopAnimating()
            return
        }
        
        let hostUrl = misdEalerHostUrl()
        let endpoint = "https://open.ma\(hostUrl)/open/misdEalerGetLoadAdsData"
        
        guard let url = URL(string: endpoint) else {
            print("Invalid URL: \(endpoint)")
            activityView.stopAnimating()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "appSystemName": UIDevice.current.systemName,
            "appModelName": UIDevice.current.model,
            "appKey": "ed34d91892a649cfb9dff762d5adbc24",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            activityView.stopAnimating()
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    self.activityView.stopAnimating()
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary {
                            if let adsData = dataDic["jsonObject"] as? [String] {
                                UserDefaults.standard.set(adsData, forKey: "ADSdatas")
                                self.misdEalerShowAdView(adsData[0])
                                return
                            }
                        }
                    }
                    self.activityView.stopAnimating()
                
                } catch {
                    self.activityView.stopAnimating()
                 
                }
            }
        }
        
        task.resume()
    }
}

