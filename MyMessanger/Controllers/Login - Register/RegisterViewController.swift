//
//  RegisterViewController.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 16/12/2020.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    //MARK: - Variables
    private enum AlerType: Int {
        case loginInvalidPassword = 0
        case loginEmptyData = 1
        case emailAlreadyExists
    }
    
    private var alerts: [Alert] = [
        Alert(tille: "Invalid Passsword", message: "Password must be at least 6 characters long"),
        Alert(tille: "Invalid Data", message: "Pleasr enter all information to create a new account"),
        Alert(tille: "Invalid Email", message: "This email address already exists!")
    ]
    
    //MARK: - images
    private let userImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(systemName: "person.circle")
        imageview.tintColor = .gray
        imageview.contentMode = .scaleAspectFit
        imageview.layer.masksToBounds = true
        imageview.layer.borderWidth = 2
        imageview.layer.borderColor = UIColor.lightGray.cgColor
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
    
    
    //MARK: - spinner
    private let spinner = JGProgressHUD(style: .dark)
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the textFields delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
        
        //user image view frame
        let size = view.width / 3.0
        userImageView.frame = CGRect(x: (scrollView.width - size) / 2.0 ,
                                     y: 20,
                                     width: size,
                                     height: size )
        userImageView.layer.cornerRadius = userImageView.width / 2.0
        
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
        presentPhotoActionSheet()
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
            alertTheUser(alertType: .loginEmptyData)
            return
        }
        
        //if invalid password
        guard password.count >= 6 else {
            alertTheUser(alertType: .loginInvalidPassword)
            return
        }
        
        //show the spinner
        spinner.show(in: view)
        
        //check if the user email already exists
        DatabaseManager.shared.userExists(with: email , completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            //if the user exists
            guard !exists else {
                strongSelf.alertTheUser(alertType: .emailAlreadyExists)
                return
            }
            
            //create a user acoount
            Auth.auth().createUser(withEmail: email, password: password, completion: { authresult , error in
                guard authresult != nil, error == nil else {
                    print("Error Creating new User\(error.debugDescription)")
                    return
                }
                
                // save the user data in the database
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAddress: email))
                //Dismiss the register view to get back to conversations view
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
            
        })
        
        
        //TODO: Complete register checks
        
        
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


//MARK: - Image Picker delegate methods
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //present action sheet to ask the user the way he whould like to upload his profile picture
    func presentPhotoActionSheet() {
        let actionSheet  = UIAlertController(title: "Profile picture",
                                             message: "How would you like to select a picture",
                                             preferredStyle: .actionSheet)
        
        //cancel button
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        //camera option
        actionSheet.addAction(UIAlertAction(title: "Take photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                            }))
        //photos library option
        actionSheet.addAction(UIAlertAction(title: "Choose photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                            }))
        present(actionSheet, animated: true)
    }
    
    
    func presentCamera() {
        //go to image picker controller with source type .camera
        let vc = UIImagePickerController()
        //to open the camera
        vc.sourceType = .camera
        vc.delegate = self
        //to crop a square out of the image
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        //go to image picker controller with source type .photoLibrary
        let vc = UIImagePickerController()
        //to open the photo library
        vc.sourceType = .photoLibrary
        vc.delegate = self
        //to crop a square out of the image
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    //when user canels taking photo or photo selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //when the user takes a phote or selects a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //we can grab the image from inside the dictionary info
        
        //this will choose the cropped image if we allows editing
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        //this will choose the original image (full image)
        //let selectedImage = info[UIImagePickerController.InfoKey.originalImage]
        
        //update the user image view
        self.userImageView.image = selectedImage
        //dismiss the picker view
        picker.dismiss(animated: true, completion: nil)
    }
}
