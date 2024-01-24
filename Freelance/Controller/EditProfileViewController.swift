import UIKit
import Firebase
import FirebaseFirestore

class EditProfileViewController: UIViewController {
    
    var fullName: String?
    var phoneNumber: String?
    var city: String?
    var about: String?
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is an edit profile screen")
        
        fullNameTextField.text = fullName
        phoneNumberTextField.text = phoneNumber
        cityTextField.text = city
        aboutTextField.text = about
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        // Oturum açmış kullanıcının e-posta adresini al
        if let userEmail = Auth.auth().currentUser?.email {
            let db = Firestore.firestore()
            
            // Kullanıcıların bulunduğu "users" koleksiyonundaki dokümanı güncelle
            let userRef = db.collection("users").whereField("email", isEqualTo: userEmail)
            
            userRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    // Her kullanıcı için döngü
                    for document in querySnapshot!.documents {
                        let documentID = document.documentID
                        
                        // TextField'ların değerleriyle Firestore dokümanını güncelle
                        let updatedData: [String: Any] = [
                            "about": self.aboutTextField.text ?? "",
                            "city": self.cityTextField.text ?? "",
                            "phoneNumber": self.phoneNumberTextField.text ?? "",
                            "fullName": self.fullNameTextField.text ?? ""
                        ]
                        
                        // Dokümanı güncelle
                        db.collection("users").document(documentID).updateData(updatedData) { error in
                            if let error = error {
                                print("Error updating document: \(error.localizedDescription)")
                                // Güncelleme başarısız ise hata bildirimi göster
                                self.showErrorAlert()
                            } else {
                                print("Document updated successfully")
                                
                                // Güncelleme başarılı ise bildirim göster ve ProfileViewController'a yönlendir
                                self.showSuccessAlert()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Successfully", message: "The profile has been updated successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            // ProfileViewController ekranına yönlendir ve ekranı reload et
            self.navigationController?.popViewController(animated: true)
            if let profileVC = self.navigationController?.viewControllers.last as? ProfileViewController {
                profileVC.fetchUserProfile()
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "An error occurred while updating the profile.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
