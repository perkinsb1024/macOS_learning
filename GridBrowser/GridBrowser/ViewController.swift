//
//  ViewController.swift
//  GridBrowser
//
//  Created by Ben Perkins on 7/20/17.
//  Copyright © 2017 perkinsb1024. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {
    
    var rows: NSStackView!
    
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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
        
    }
    
    @IBAction func navButtonClicked(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            print("Go back")
        case 1:
            print("Go forward")
        default:
            break
        }
    }
    
    func makeWebView() -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com/")!))
        
        return webView
    }
}

