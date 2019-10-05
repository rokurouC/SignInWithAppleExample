//
//  ViewController.swift
//  AppleSignInWithKeychain
//
//  Created by Will Chen on 2019/10/3.
//  Copyright © 2019 rukurouc. All rights reserved.
//

import UIKit
import AuthenticationServices

// MARK: Constant

private enum Constant: String {
    case notLogin = "You're not logged in."
    case login = "You're already logged in."
}

class ViewController: UIViewController {
    
    // MARK: Properties
    
    ///Indicate whether user is logined or not.
    private let indicatorUserState: UILabel = {
       let label = UILabel()
        return label
    }()
    ///Default button for signing in with apple.
    private let defaultAppleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleSignInWithAppleButtonPress), for: .touchUpInside)
        return button
    }()
    ///Custom button for signing in with apple.
    private let customAppleSignInButton: UIButton = {
        let button = UIButton(type: .system)
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
    ///Button for logging out
    private let logOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Log out", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleLogOut), for: .touchUpInside)
        return button
    }()
    
    // MARK: ViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        updateUserLoginStatus()
    }
    
    // MARK: Initial method
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [defaultAppleSignInButton, customAppleSignInButton, logOutButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(indicatorUserState)
        indicatorUserState.translatesAutoresizingMaskIntoConstraints = false
        indicatorUserState.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        indicatorUserState.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20).isActive = true
    }
    
    // MARK: Update login status
    
    private func updateUserLoginStatus() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: Keychain.currentUserIdentifier) {[weak self] (credentialState, error) in
            var userLoginStr = ""
            switch credentialState {
            case .authorized:
                userLoginStr = Constant.login.rawValue
                break;
            case .notFound:
                userLoginStr = Constant.notLogin.rawValue
                break
            case .revoked, .transferred:
                //handle exceptions
                fallthrough
            @unknown default:
                break;
            }
            DispatchQueue.main.async {
                self?.indicatorUserState.text = userLoginStr
            }
        }
    }
    
    // MARK: Selector action
    
    @objc
    private func handleSignInWithAppleButtonPress() {
        let appleIdProviderRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleIdProviderRequest.requestedScopes = [.fullName, .email]
        let requests = [appleIdProviderRequest]
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc
    private func handleLogOut() {
        Keychain.deleteCurrentUserIdentifier()
        updateUserLoginStatus()
    }
}

// MARK: About ASAuthorization

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            Keychain.setCurrentUserIdentifier(appleIDCredential.user)
            updateUserLoginStatus()
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

