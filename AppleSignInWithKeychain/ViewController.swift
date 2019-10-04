//
//  ViewController.swift
//  AppleSignInWithKeychain
//
//  Created by Will Chen on 2019/10/3.
//  Copyright © 2019 rukurouc. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    let defaultAppleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleSignInWithAppleButtonPress), for: .touchUpInside)
        return button
    }()
    let customAppleSignInButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitle("Sign in with Apple", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleSignInWithAppleButtonPress), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [defaultAppleSignInButton, customAppleSignInButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc
    func handleSignInWithAppleButtonPress() {
        let appleIdProviderRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleIdProviderRequest.requestedScopes = [.fullName, .email]
        let requests = [
            appleIdProviderRequest,
            ASAuthorizationPasswordProvider().createRequest()]
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print(appleIDCredential)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            print(passwordCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

