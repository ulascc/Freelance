import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        print("this is a login")
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    self.showAlert(title: "Login Failed", message: "Invalid email or password. Please try again.")
                } else {
                    self.showAlert(title: "Login Successful", message: "You have successfully logged in.")
                    // Giriş başarılı ise 1 saniye sonra alert'i kapat
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.dismiss(animated: true, completion: nil)
                        // Ardından sayfaya yönlendir
                        self.performSegue(withIdentifier: K.loginSegue, sender: self)
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
