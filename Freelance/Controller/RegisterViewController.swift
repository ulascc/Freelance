//
//  RegisterViewController.swift
//  Freelance
//
//  Created by umutcancicek on 7.11.2023.
//


import Foundation
import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this is a register")
    }

    @IBAction func RegisterButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text,
           let fullName = fullNameTextField.text { // Yeni eklenen alanın değerini al
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    // Kullanıcının tam adını kaydetmek için
                    if let user = Auth.auth().currentUser {
                        let db = Firestore.firestore()
                        let userRef = db.collection("users").document(user.uid)

                        let userData: [String: Any] = [
                            "fullName": fullName,
                            "email": user.email ?? "", // Eğer kullanıcının e-posta bilgisi yoksa boş bir değer ekleyebilirsiniz.
                            "uid": user.uid
                            // Diğer kullanıcı bilgileri buraya ekleyebilirsiniz.
                        ]

                        userRef.setData(userData, merge: true) { error in
                            if let error = error {
                                print("Firestore'ya kullanıcı bilgilerini eklerken hata oluştu: \(error.localizedDescription)")
                            } else {
                                print("Firestore'ya kullanıcı bilgileri başarıyla eklendi.")
                            }
                        }
                    }
                    print("Successfully saved")
                }
            }
        }
    }
    
}

