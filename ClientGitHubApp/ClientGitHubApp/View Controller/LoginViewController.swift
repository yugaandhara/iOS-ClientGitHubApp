//
//  LoginViewController.swift
//  ClientGitHubApp
//
//  Created by Yugandhara Bodhekar on 07/04/23.
//

import Foundation
import UIKit
import WebKit


final class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var LoginButton: UIButton!
    
    // MARK: - Variables
    
    var webView = WKWebView()
        
    var githubDisplayName = ""
            
    var githubAccessToken = ""
    
    // MARK: - Constant
    
    let authenticationViewController = UIViewController()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
    }
    
    // MARK: - IBAction
    
    @IBAction func onClickLoginButton(_ sender: Any) {
        clientGitHubAuthentication()
    }
    
    // MARK: - Internal Methods
    
    private func clientGitHubAuthentication() {
        webView.navigationDelegate = self
        authenticationViewController.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: authenticationViewController.view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: authenticationViewController.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: authenticationViewController.view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: authenticationViewController.view.bottomAnchor)
        ])
        loadURLRequest()
        setUpNavigationControllerForWebView()
    }
    
    private func loadURLRequest() {
        let uuid = UUID().uuidString
        let authURLFull = "https://github.com/login/oauth/authorize?client_id=" + Constants.CLIENT_ID + "&scope=" + Constants.SCOPE + "&redirect_uri=" + Constants.REDIRECT_URI + "&state=" + uuid
        guard let url = URL(string: authURLFull) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    private func setUpNavigationControllerForWebView() {
        let navigationController = UINavigationController(rootViewController: authenticationViewController)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        authenticationViewController.navigationItem.leftBarButtonItem = cancelButton
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshAction))
        authenticationViewController.navigationItem.rightBarButtonItem = refreshButton
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        authenticationViewController.navigationItem.title = "github.com"
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        navigationController.modalTransitionStyle = .coverVertical
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshAction() {
        self.webView.reload()
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "repoListSegue" {
            if let repositoriesListViewController = segue.destination as? RepositoriesListViewController {
                repositoriesListViewController.githubDisplayName = self.githubDisplayName
                repositoriesListViewController.githubAccessToken = self.githubAccessToken
            }
        }
    }
}

extension LoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.requestForCallbackURL(request: navigationAction.request)
        decisionHandler(.allow)
    }
    
    func requestForCallbackURL(request: URLRequest) {
        guard let requestURLString = request.url?.absoluteString else { return }
        if requestURLString.hasPrefix(Constants.REDIRECT_URI) {
            if requestURLString.contains("code=") {
                if let range = requestURLString.range(of: "=") {
                    let githubCode = requestURLString[range.upperBound...]
                    if let range = githubCode.range(of: "&state=") {
                        let githubCodeFinal = githubCode[..<range.lowerBound]
                        githubRequestForAccessToken(authCode: String(githubCodeFinal))
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func githubRequestForAccessToken(authCode: String) {
        let grantType = "authorization_code"
        let postParams = "grant_type=" + grantType + "&code=" + authCode + "&client_id=" + Constants.CLIENT_ID + "&client_secret=" + Constants.CLIENT_SECRET
        let postData = postParams.data(using: String.Encoding.utf8)
        guard let url = URL(string: Constants.TOKENURL) else { return }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, _) -> Void in
                guard let data = data else {
                    return
                }
                do {
                    let results = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any]
                    guard let accessToken = results?["access_token"] as? String else { return }
                    self.fetchGitHubUserProfile(accessToken: accessToken)
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
        }
        task.resume()
    }
    
    func fetchGitHubUserProfile(accessToken: String) {
        let tokenURLFull = "https://api.github.com/user"
        guard let verify = NSURL(string: tokenURLFull) else { return }
        let request = NSMutableURLRequest(url: verify as URL)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if error == nil {
                guard let data = data else {
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any]
                    self.githubAccessToken = accessToken
                    if let githubDisplayName = (result?["login"] as? String) {
                        self.githubDisplayName = githubDisplayName
                    }
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "repoListSegue", sender: self)
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}

