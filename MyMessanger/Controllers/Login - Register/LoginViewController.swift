//
//  LoginViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    //MARK: - Variables
    private enum AlerType: Int {
        case LoginInvalidPassword = 0
        case LoginEmptyEmailOrPassword = 1
    }
    
    private var alerts: [Alert] = []
    
    
    //MARK: - images
    private let logoImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "LoginLogo")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    //MARK: - scroll view
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    //MARK: - text fields
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Email Address..."
        textField.backgroundColor = .white
        // to solve the left typing issue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Password..."
        textField.backgroundColor = .white
        textField.isSecureTextEntry = true
        // to solve the left typing issue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    //MARK: - Buttons
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In ", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        
        return button
    }()
 
    //MARK: - login observer var
    private var loginObserver: NSObjectProtocol?
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //observe the notification so this view can listen to the notification that appDelegate will fire it
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification,
                                                               object: nil,
                                                               queue: .main) { [weak self] (_) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        
        //set the textFields delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //facebook login delegate
        facebookLoginButton.delegate = self
        
        //google sign in
        GIDSignIn.sharedInstance()?.presentingViewController = self

        
        
        //set title and view color
        title = "Log in "
        view.backgroundColor = .white
        
        //set alerts
        alerts.append(Alert(tille: "Invalid Passsword", message: "Password must be at least 6 characters long"))
        alerts.append(Alert(tille: "Invalid Email or Password", message: "Enter your email and your Password to log in"))
        
        
        //create the top button to go to register view controller
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegisterButton))
        //give an action to the login button
        loginButton.addTarget(self, action: #selector(didTaploginButton), for: .touchUpInside)
        
        
        //add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)

    }
    
    //MARK: - deinit
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    //MARK: - ViewDidLayoutSubViews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //scroll view frame
        scrollView.frame = view.bounds
        
        //logo image view frame
        let size = view.width / 3.0
        logoImageView.frame = CGRect(x: (scrollView.width - size) / 2.0 ,
                                     y: 20,
                                     width: size,
                                     height: size )
        
        //Email text field frame
        emailTextField.frame = CGRect(x: 30 ,
                                      y: logoImageView.bottom + 10,
                                      width: scrollView.width - 60,
                                      height: 52)
        
        //password text field frame
        passwordTextField.frame = CGRect(x: emailTextField.left ,
                                         y: emailTextField.bottom + 10,
                                         width: emailTextField.width,
                                         height: emailTextField.height)
        
        //login button frame
        loginButton.frame = CGRect(x: emailTextField.left ,
                                   y: passwordTextField.bottom + 10,
                                   width: emailTextField.width,
                                   height: emailTextField.height)
        
        //facebook login button
        facebookLoginButton.frame = CGRect(x: emailTextField.left ,
                                           y: loginButton.bottom + 10,
                                           width: emailTextField.width,
                                           height: emailTextField.height)
        
        //Google login button
        googleLoginButton.frame = CGRect(x: emailTextField.left ,
                                           y: facebookLoginButton.bottom + 10,
                                           width: emailTextField.width,
                                           height: emailTextField.height)
        
    }
    
    
    
    //MARK: - Actions
    @objc private func didTaploginButton (){
        
        //remove the keyboard
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        //if there is no data entered
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty
        else {
            //alert the user
            alertTheUser(alertType: .LoginEmptyEmailOrPassword)
            return
        }
        
        // if Invalid Password
        guard password.count >= 6 else {
            alertTheUser(alertType: .LoginInvalidPassword)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            guard let result = authResult, error == nil else {
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
            //TODO: complete login checks
            
        })
        
        
    }
    
    @objc private func didTapRegisterButton () {
        //jump to register page
        let nextVC = RegisterViewController()
        nextVC.title = "Create Account"
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    //MARK: - alert creation 
    private func alertTheUser(alertType: AlerType) {
        //show the user an alert
        let alert = UIAlertController(title: alerts[alertType.rawValue].tille, message: alerts[alertType.rawValue].message, preferredStyle: .alert)
        //add an action (a button) to the alert if you want
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
}


//MARK: - Text Field delegate methods
extension LoginViewController: UITextFieldDelegate {
    
    //when the user presses return inside the text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            //go to the next text field
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField {
            //press the login button
            didTaploginButton()
        }
        return true
    }
    
}

//MARK: - facebook login delegate
extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // do nothing
    }
    
    
    //when the user completes logining in with facebook
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        //get the token from the results
        guard let token = result?.token?.tokenString else {
            print("User failed to log in Facebook")
            return
        }
        
        //create a facebook request to get the user facebook email and name
        let facebookrequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        //start the request
        facebookrequest.start { (_, result, error) in
            guard let result = result as? [String: Any], error == nil else  {
                print("Failed to make facebook graph request")
                return
            }
            
            //TODO: we need to update this part of code
            //seperate the email and the user name
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                
                print("Failed to get email and name from facebook results ")
                return
            }
            
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            
            //check if this user is exists in the database
            DatabaseManager.shared.userExists(with: email) { (exists) in
                //if doesn't exist add it to the data base and complete the code to log him in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName,
                                                                        emailAddress: email))
                }
                //else if he exists complete the login in without saving the user data
            }
            
            // get the credential from the facebook (facebook authentication)
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            // give the credential to the firebase so we can sign the in
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self](authResult, error) in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    print("facebook credential login failed, MFA may be nedded")
                    print(error.debugDescription)
                    return
                }
                
                print("successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
}
