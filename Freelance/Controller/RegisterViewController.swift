import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is a register")
        
        // UIImageView'a tıklanınca galeriyi açma işlemi için UITapGestureRecognizer ekleyin
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    let db = Firestore.firestore()
    let storage = Storage.storage()


    @objc func handleImageTap() {
        // Fotoğraf seçme işlemi için UIImagePickerController'ı başlat
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            // Seçilen fotoğrafı ImageView'da göster
            profileImageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func RegisterButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text,
           let fullName = fullNameTextField.text {

            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error creating user: \(error.localizedDescription)")
                } else {
                    // Kullanıcı başarıyla oluşturulduysa
                    if let user = Auth.auth().currentUser {
                        let db = Firestore.firestore()
                        let userRef = db.collection("users").document(user.uid)

                        let userData: [String: Any] = [
                            "fullName": fullName,
                            "email": email,
                            "uid": user.uid
                            // Diğer kullanıcı bilgilerini buraya ekleyebilirsiniz.
                        ]

                        userRef.setData(userData, merge: true) { error in
                            if let error = error {
                                print("Firestore'ya kullanıcı bilgilerini eklerken hata oluştu: \(error.localizedDescription)")
                            } else {
                                print("Firestore'ya kullanıcı bilgileri başarıyla eklendi.")
                                
                                // Profil fotoğrafını Firebase Storage'a kaydet
                                if let profileImage = self.profileImageView.image,
                                   let imageData = profileImage.jpegData(compressionQuality: 0.5) {
                                    
                                    let storageRef = Storage.storage().reference().child("profile_images").child("\(user.uid).jpg")

                                    storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                                        if let error = error {
                                            print("Error uploading profile image: \(error.localizedDescription)")
                                        } else {
                                            print("Profile image uploaded successfully.")
                                            // Başarılı yükleme durumunda kullanıcıya bildirim gösterilebilir.
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
