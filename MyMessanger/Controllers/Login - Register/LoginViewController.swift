//
//  LoginViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit

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
    
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the textFields delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
        
        //TODO: Firebase login
        print("Logged in")
        
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
