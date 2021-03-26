//
//  ViewController.swift
//  WKWebViewTest
//
//  Created by Rob Montgomery on 8/26/19.
//  Copyright © 2019 Rob Montgomery. All rights reserved.
//

import UIKit
import WebKit
import Foundation

class ViewController: UIViewController, WKNavigationDelegate {
  
    var webView: WKWebView!
  
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        // Intercept custom URI
       
        let surl = navigationAction.request.url?.absoluteString
        print(surl)
        print("*************************************************")

        if surl?.hasPrefix("atrium://") == true || surl?.hasPrefix("myapp://") == true || surl?.hasPrefix("mx://") == true {
            // Take action here
            let urlc = URLComponents(string: surl ?? "")
            let path = urlc?.path ?? ""
            // there is only one query param ("metadata") with each url, so just grab the first
            let metaDataQueryItem = urlc?.queryItems?.first
            
            if path == "/oauthRequested" {
                handleOauthRedirect(payload: metaDataQueryItem)
            }
            
            // Cancel request
            decisionHandler(.cancel)
            return
        }
        
        // Allow request
        decisionHandler(.allow)
    }
    
    /*
     * Handle the oauthRequested event. Parse out the oauth url from the event and open safari to that url
     * NOTE: This code is somewhat optimistic, you'll want to add error handling that makes sense for your app.
     */
    func handleOauthRedirect(payload: URLQueryItem?) {
        let metadataString = payload?.value ?? ""

        do {
            if let json = try JSONSerialization.jsonObject(with: Data(metadataString.utf8), options: []) as? [String: Any] {
                if let url = json["url"] as? String {
                    // open safari with the url from the json payload
                    print(url)
                    UIApplication.shared.open(URL(string: url)!)
                }
            }
        } catch let error as NSError {
            print("Failed to parse payload: \(error.localizedDescription)")
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://int-widgets.moneydesktop.com/md/connect/bh0yn2ncpwvgkszg2Avk4dw3AAZ5qkzk35xnk2A7jslts3qdhbvl6kr95m1mq339dkr0f9fsh3dny3fmjj8tz27sA7gzv5kcmtxqvmndy1x7lAh69hbgd3sj6b7z6516x481gd1n7Aqctvg19g5qbxjjz70fsctstAw83Amftd5twf9ltx34rklgsAd2ztxczwm3hpwqy56w6lg5yrb3wbhb96tptcr7pctwtmhckp5g8sc4wy45bzp2qrh3cvy45kyd4vs3cgswv871x3gkbyn5mknjxrmgzwyjyznm31f6bf1pynbtdvw9dp6kytxkm8ysyg2x7tl97fm5b9g68nty37nd5pb3rjAmzxlg/eyJpc19tb2JpbGVfd2VidmlldyI6dHJ1ZSwidWlfbWVzc2FnZV92ZXJzaW9uIjo0LCJ1aV9tZXNzYWdlX3dlYnZpZXdfdXJsX3NjaGVtZSI6Im15YXBwIn0%3D")!
        webView.customUserAgent = "ActiveRemote"
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
