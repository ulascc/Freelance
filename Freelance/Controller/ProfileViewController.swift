import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePhotoImageView: UIImageView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Image picker ayarları
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false

        // UIImageView'a tıklama (tap) olayını ekleyin
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePhotoTapped))
        profilePhotoImageView.addGestureRecognizer(tapGesture)
        profilePhotoImageView.isUserInteractionEnabled = true
    }

    // Fotoğraf seçme butonuna basıldığında çağrılır
    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Seçilen fotoğrafı image view'e ata
            profilePhotoImageView.image = selectedImage

            // Fotoğrafı Firestore Storage'a yükle ve kullanıcının profil fotoğrafını güncelle
            uploadImageToStorage(selectedImage)
        }

        dismiss(animated: true, completion: nil)
    }

    // Fotoğrafı Firestore Storage'a yükleyen metod
    func uploadImageToStorage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        let userID = Auth.auth().currentUser?.uid ?? "unknownUser"
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userID).jpg")

        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                print("Hata: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            // Fotoğraf yüklendikten sonra Firestore'daki kullanıcı belgesine referans ekleyin
            self.updateUserProfileImageURL(storageRef)
        }
    }

    // Firestore kullanıcı belgesine profil fotoğrafı URL'sini ekleyen metod
    func updateUserProfileImageURL(_ storageRef: StorageReference) {
        storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("Hata: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            // Firestore'daki kullanıcı belgesine fotoğraf URL'sini ekleyin
            let userID = Auth.auth().currentUser?.uid ?? "unknownUser"
            let userRef = Firestore.firestore().collection("users").document(userID)

            userRef.updateData(["profileImageURL": downloadURL.absoluteString]) { (error) in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                } else {
                    print("Profil fotoğrafı başarıyla güncellendi.")
                }
            }
        }
    }

    // UIImageView'a tıklama (tap) olayını işleyen metod
    @objc func profilePhotoTapped() {
        // Fotoğraf seçme ekranını aç
        present(imagePicker, animated: true, completion: nil)
    }
}
