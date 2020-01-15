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

        if surl?.hasPrefix("atrium://") == true || surl?.hasPrefix("mx://") == true {
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
        let url = URL(string: "http://10.17.31.24:3000/md/connect/bytgtx5zcftA6nq4h0x1d0gjc2Zs9n7d7A9pmsx782k0Av6sAw0x35vfzhnjgvrv71b5lz41mzsvm86ydrr79ndzcv5my5b89pb7ztg2fm636hql6qbcr8d977k94g1xqm59zAmdl9b9714lb2jA17lg9f44lc2s4sl27w1dkfk7yg05Ap4xm54mz70lvyyc8j8sxjl17s2vv07cAc2768cjf54x5q6w7800A2Alhkrqtj1055xfmg6dvpzmyrh2vfcd7vttn0djqd515wc1cn5mbn06bvw5j5xjtzqqj4dtw5c78xt61st3lvf3lsvbA9yjhmgrrxm1094gAA5Af1cns53psrgqk4z5cs1c/eyJpc19tb2JpbGVfd2VidmlldyI6dHJ1ZSwidWlfbWVzc2FnZV92ZXJzaW9uIjo0fQ%3D%3D")!
        webView.customUserAgent = "ActiveRemote"
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
