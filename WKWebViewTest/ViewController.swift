//
//  ViewController.swift
//  WKWebViewTest
//
//  Created by Rob Montgomery on 8/26/19.
//  Copyright © 2019 Rob Montgomery. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
  
  var webView: WKWebView!
  
  func webView(_ webView: WKWebView, decidePolicyFor
    navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
    
    // Intercept custom URI
    let surl = webView.url?.absoluteString
    if  (surl?.hasPrefix("mx://"))! {
      // Take action here
      
      // Cancel request
      decisionHandler(.cancel)
      return
    }
    
    // Allow request
    decisionHandler(.allow)
    
  }
  
  override func loadView() {
    webView = WKWebView()
    webView.navigationDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let url = URL(string: "https://apps.americafirst.com/")!
    webView.customUserAgent = "ActiveRemote"
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true
  }


}

