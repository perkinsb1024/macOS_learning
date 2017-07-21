//
//  ViewController.swift
//  GridBrowser
//
//  Created by Ben Perkins on 7/20/17.
//  Copyright © 2017 perkinsb1024. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate {
    
    var rows: NSStackView!
    var selectedWebView: WKWebView?
    let homepages = ["https://www.apple.com", "https://www.google.com", "https://news.google.com", "https://en.wikipedia.org", "https://www.amazon.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let columns = NSStackView(views: [makeWebView()])
        columns.distribution = .fillEqually
        
        rows.addArrangedSubview(columns)
 
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let windowController = webView.window?.windowController as? WindowController else { return }
        
        if webView == selectedWebView {
            windowController.urlBar.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        return gestureRecognizer.view as? WKWebView != selectedWebView
    }
    
    @IBAction func rowButtonClicked(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            let numCols = (rows.subviews[0] as? NSStackView)?.arrangedSubviews.count ?? 1
            let cols = NSStackView(views: (0 ..< numCols).map { _ in makeWebView() })
            cols.distribution = .fillEqually
            rows.addArrangedSubview(cols)
        case 1:
            guard rows.subviews.count > 1 else { return }
            guard let lastRow = rows.arrangedSubviews.last as? NSStackView else { return }
            for column in lastRow.subviews {
                column.removeFromSuperview()
            }
            rows.removeArrangedSubview(lastRow)

        default:
            break
        }
    }
    
    @IBAction func columnButtonClicked(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            for case let row as NSStackView in rows.subviews {
                row.addArrangedSubview(makeWebView())
            }
        case 1:
            for case let row as NSStackView in rows.subviews {
                guard row.subviews.count > 1 else { return }
                row.arrangedSubviews.last?.removeFromSuperview()
            }
        default:
            break
        }
    }

    @IBAction func urlBarChanged(_ sender: NSTextField) {
        guard selectedWebView != nil else { return }
        guard let urlBar = (selectedWebView!.window?.windowController as? WindowController)?.urlBar else { return }
        var urlString = urlBar.stringValue
        urlString = urlString.replacingOccurrences(of: "http:", with: "https:")
        if !urlString.contains("https:") {
            urlString = "https://" + urlString
        }
        guard let url = URL(string: urlString) else { return }
        selectedWebView!.load(URLRequest(url: url))
    }
    
    @IBAction func navButtonClicked(_ sender: NSSegmentedControl) {
        guard selectedWebView != nil else { return }
        switch sender.selectedSegment {
        case 0:
            selectedWebView!.goBack()
        case 1:
            selectedWebView!.goForward()
        default:
            break
        }
    }
    
    func makeWebView() -> WKWebView {
        let url = homepages[Int(arc4random_uniform(UInt32(homepages.count)))]
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: url)!))
        
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        clickRecognizer.delegate = self
        webView.addGestureRecognizer(clickRecognizer)
        
        if selectedWebView == nil {
            selectWebView(webView)
        }
        
        return webView
    }
    
    func selectWebView(_ webView: WKWebView) {
        selectedWebView?.layer?.borderWidth = 0
        
        webView.layer?.borderWidth = 4
        webView.layer?.borderColor = NSColor.blue.cgColor
        selectedWebView = webView
        
        let urlBar = (selectedWebView?.window?.windowController as? WindowController)?.urlBar
        urlBar?.stringValue = webView.url?.absoluteString ?? ""
    }
    
    func handleClick(_ sender: NSClickGestureRecognizer) {
        guard let _ = sender.view as? WKWebView else { return }
        selectWebView(sender.view as! WKWebView)
    }
}

