//
//  RegisterViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit

class RegisterViewController: UIViewController {
    
    //MARK: - Variables
    private enum AlerType: Int {
        case LoginInvalidPassword = 0
        case LoginEmptyData = 1
    }

    private var alerts: [Alert] = []

    
    
    //MARK: - images
    private let userImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "person")
        imageview.tintColor = .gray
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    //MARK: - scrollview
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    //MARK: - textFields
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "First Name..."
        textField.backgroundColor = .white
        // to solve the left typing issue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Last Name..."
        textField.backgroundColor = .white
        // to solve the left typing issue
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()


    
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
    
    //MARK: - buttons
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the textFields delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //set alerts
        alerts.append(Alert(tille: "Invalid Passsword", message: "Password must be at least 6 characters long"))
        alerts.append(Alert(tille: "Invalid Data", message: "Pleasr enter all information to create a new account"))

        
        //set the navigation title and the view color
        title = "Register"
        view.backgroundColor = .white
        
        //give an action to the login button
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        
        //add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(userImageView)
        scrollView.addSubview(firstNameTextField)
        scrollView.addSubview(lastNameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(registerButton)
        
        //make the image view and the scroll view interactable
        userImageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        //set action to the image 
        let gester = UITapGestureRecognizer(target: self,
                                            action: #selector(didTapChangeProfilePic))
        
        userImageView.addGestureRecognizer(gester)
    }
    
    //MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //scroll view frame
        scrollView.frame = view.bounds
        
        //logo image view frame
        let size = view.width / 3.0
        userImageView.frame = CGRect(x: (scrollView.width - size) / 2.0 ,
                                     y: 20,
                                     width: size,
                                     height: size )
        
        //first name text field fram
        firstNameTextField.frame = CGRect(x: 30 ,
                                          y: userImageView.bottom + 10,
                                          width: scrollView.width - 60,
                                          height: 52)
        
        //last name text field fram
        lastNameTextField.frame = CGRect(x: firstNameTextField.left ,
                                         y: firstNameTextField.bottom + 10,
                                         width: firstNameTextField.width,
                                         height: firstNameTextField.height)

        
        
        //Email text field frame
        emailTextField.frame = CGRect(x: firstNameTextField.left ,
                                      y: lastNameTextField.bottom + 10,
                                      width: firstNameTextField.width,
                                      height: firstNameTextField.height)
        
        //password text field frame
        passwordTextField.frame = CGRect(x: firstNameTextField.left ,
                                         y: emailTextField.bottom + 10,
                                         width: firstNameTextField.width,
                                         height: firstNameTextField.height)
        
        //login button frame
        registerButton.frame = CGRect(x: firstNameTextField.left ,
                                   y: passwordTextField.bottom + 10,
                                   width: firstNameTextField.width,
                                   height: firstNameTextField.height)
        
        
    }
    
    
    //MARK: - Actions
    
    @objc private func didTapChangeProfilePic() {
        print("Changed pic called")
    }
    @objc private func didTapRegisterButton (){
        //remove the keyboard
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

                
        //if there is no data entered
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty
        else {
            //alert the user
            alertTheUser(alertType: .LoginEmptyData)
            return
        }
        
        //if invalid password
        guard password.count >= 6 else {
            alertTheUser(alertType: .LoginInvalidPassword)
            return
        }
        
        //TODO: Firebase Registeration
        print("Registerd")
        
        
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
extension RegisterViewController: UITextFieldDelegate {
    
    //when the user presses return inside the text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            //go to the next text field
            lastNameTextField.becomeFirstResponder()
        }else if textField == lastNameTextField {
            //go to the next text field
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField {
            //go to the next text field
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField {
            //press the login button
            didTapRegisterButton()
        }
        return true
    }
    
}
