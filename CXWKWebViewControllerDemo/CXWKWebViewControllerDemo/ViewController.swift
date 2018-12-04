//
//  ViewController.swift
//  CXWKWebViewControllerDemo
//
//  Created by Xu Chen on 2018/11/27.
//  Copyright © 2018 xu.yzl. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = CXWKWebBrowserController.cx_loadWkWebView(withUrlString:"https://www.jd.com/")
        present(vc, animated: true, completion: nil)
    }
}

