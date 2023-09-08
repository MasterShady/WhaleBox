//
//  YQYQHGebController.swift
//  YQHG
//
//  Created by wyy on 2023/2/7.
//

import UIKit
import WebKit

class WebViewController: BaseVC {
    
    var urlStr: String?
    
    init(urlStr: String? = nil) {
        self.urlStr = urlStr
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configSubViews() {
        view.addSubview(webview)
        view.addSubview(progress)
        addObserver(self,forKeyPath: #keyPath(webview.estimatedProgress),options: [.new,.old],context: nil)
        webview.snp.makeConstraints { make in
            make.top.equalTo(kNavBarMaxY)
            make.left.bottom.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
        progress.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(self.webview)
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(2)
        }
        
        if let url = URL(string: urlStr ?? "") {
            let request = URLRequest(url: url)
            webview.load(request)
        }
    }
    
    func reloadData() {
        webview.reload()
    }

    
    // MARK: - lazy
    @objc private lazy var webview: WKWebView = {
        let web = WKWebView(frame: .zero)
        web.navigationDelegate = self
        return web
    }()
    
    private lazy var progress: UIProgressView = {
        let progress = UIProgressView()
        progress.trackTintColor = .clear
        progress.progressTintColor = .red
        return progress
    }()
}

extension WebViewController: WKNavigationDelegate
{
    
    // 监听网页加载进度
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        self.progress.progress = Float(webview.estimatedProgress)
        printLog(webview.estimatedProgress)
    }
    
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        printLog("开始加载...")
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        printLog("当内容开始返回...")
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        printLog("页面加载完成...")
        /// 获取网页title
        self.navigationItem.title = webview.title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progress.isHidden = true
        }
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        printLog("页面加载失败...")
        UIView.animate(withDuration: 0.5) {
            self.progress.progress = 0.0
            self.progress.isHidden = true
        }
        /// 弹出提示框点击确定返回
        let alertView = UIAlertController.init(title: "提示", message: "加载失败", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in
            _=self.navigationController?.popViewController(animated: true)
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
 
}

