import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.autocorrectionType = .no

        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        background.contentMode = .scaleAspectFill
    }
    
    @IBAction func SendNewPasswordButton(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if let error = error {
                print("Failed with error: \(error.localizedDescription)")
            } else {
                print("Password reset email successfully sent.")
                self.showAlert(title: "Forgot Password", message: "Check your Email address") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

