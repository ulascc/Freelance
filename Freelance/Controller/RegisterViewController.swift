import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    var cityPickerView = UIPickerView()
    let cities = Cities.cities
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is a register")
        
        emailTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        fullNameTextField.autocorrectionType = .no
        aboutTextField.autocorrectionType = .no
        phoneNumberTextField.autocorrectionType = .no
        
        cityTextField.inputView = cityPickerView
        cityPickerView.delegate = self
        cityPickerView.dataSource = self
        
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
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let fullName = fullNameTextField.text, !fullName.isEmpty,
              let about = aboutTextField.text, !about.isEmpty,
              let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty,
              let city = cityTextField.text, !city.isEmpty else {
            // Giriş alanlarından biri boşsa hata mesajı göster
            showAlert(title: "Hata", message: "Tüm alanları doldurmalısınız.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                if let user = Auth.auth().currentUser {
                    self.saveUserToFirestore(user, fullName: fullName, email: email, about: about, phoneNumber: phoneNumber, city: city)
                    self.uploadProfileImage(for: user)
                }
            }
        }
    }
    
    
    func saveUserToFirestore(_ user: User, fullName: String, email: String, about: String, phoneNumber: String, city: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        let userData: [String: Any] = [
            "fullName": fullName,
            "email": email,
            "uid": user.uid,
            "about": about,
            "phoneNumber": phoneNumber,
            "city": city
        ]
        
        userRef.setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore'ya kullanıcı bilgilerini eklerken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Firestore'ya kullanıcı bilgileri başarıyla eklendi.")
                self.showAlert(title: "successfully registered", message: "You have successfully registered. Check out the jobs now")
                DispatchQueue.main.async {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.fullNameTextField.text = ""
                    self.aboutTextField.text = ""
                    self.phoneNumberTextField.text = ""
                    self.cityTextField.text = "" // Şehir bilgisini ekledikten sonra temizleyebilirsiniz
                    self.profileImageView.image = nil
                }
            }
        }
    }
    
    
    func uploadProfileImage(for user: User) {
        if let profileImage = self.profileImageView.image,
           let imageData = profileImage.jpegData(compressionQuality: 0.5) {
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(user.uid).jpg")
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading profile image: \(error.localizedDescription)")
                } else {
                    // Fotoğraf başarıyla yüklendiyse, downloadURL'i al ve Firestore'a kaydet
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                        } else if let downloadURL = url {
                            // Firestore'a kullanıcı bilgilerini ve fotoğraf URL'ini kaydet
                            self.saveProfileImageURL(user, downloadURL: downloadURL.absoluteString)
                        }
                    }
                }
            }
        }
    }
    
    func saveProfileImageURL(_ user: User, downloadURL: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        let userData: [String: Any] = [
            "profileImageUrl": downloadURL
        ]
        
        userRef.setData(userData, merge: true) { error in
            if let error = error {
                print("Firestore'ya profil fotoğraf URL'sini eklerken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Firestore'ya profil fotoğraf URL'si başarıyla eklendi.")
            }
        }
    }
    
}

extension RegisterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case cityPickerView:
            return cities.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case cityPickerView:
            return cities[row]
        default:
            return "data not found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case cityPickerView:
            cityTextField.text = cities[row]
            cityTextField.resignFirstResponder()
        default:
            return
        }
    }
}
