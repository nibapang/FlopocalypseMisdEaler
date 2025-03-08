//
//  PPViewController.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import UIKit
import Adjust
import WebKit

class MisdEalerPPViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    // MARK: - IBOutlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indView: UIActivityIndicatorView!
    
    // MARK: - Properties
    @objc var urlStr: String?
    let ads: [String] = UserDefaults.standard.object(forKey: "ADSdatas") as? [String] ?? []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWebView()
        loadRequest()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backBtn.isHidden = (urlStr != nil)
        indView.hidesWhenStopped = true
        view.backgroundColor = .black
    }
    
    private func configureWebView() {
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        if ads.count > 3 {
            let userContentController = webView.configuration.userContentController
            let trackScript = WKUserScript(source: ads[1],
                                           injectionTime: .atDocumentStart,
                                           forMainFrameOnly: false)
            userContentController.addUserScript(trackScript)
            userContentController.add(self, name: ads[2])
            userContentController.add(self, name: ads[3])
        }
    }
    
    private func loadRequest() {
        indView.startAnimating()
        guard let urlString = urlStr, let url = URL(string: urlString) else {
            if let emptyURL = URL(string: "https://www.termsfeed.com/live/2e74cc69-f203-4116-92ea-4f0cd940a885") {
                webView.load(URLRequest(url: emptyURL))
            }
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopIndicator()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopIndicator()
    }
    
    private func stopIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.indView.stopAnimating()
        }
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return nil
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard ads.count >= 4 else { return }
        
        if message.name == ads[2],
           let data = message.body as? String,
           let url = URL(string: data) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if message.name == ads[3],
                  let data = message.body as? [String: Any],
                  let evTok = data["eventToken"] as? String,
                  !evTok.isEmpty {
            print("eventToken：\(evTok)")
            Adjust.trackEvent(ADJEvent(eventToken: evTok))
        }
    }
}
