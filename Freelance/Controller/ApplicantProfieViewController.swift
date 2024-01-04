import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

import UIKit

class ApplicantProfieViewController: UIViewController {

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    // Segue ile gelen kullanıcı e-posta bilgisini tutmak için değişken
    var selectedUserEmail: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Segue ile gelen e-posta bilgisini kullanarak kullanıcı profiline gidin
                if let email = selectedUserEmail {
                    fetchUserProfile(for: email)
                }
    }

    func fetchUserProfile(for userEmail: String) {
            // E-posta bilgisini kullanarak Firestore'dan kullanıcı verilerini çek
            db.collection("users").whereField("email", isEqualTo: userEmail).getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching user profile: \(error.localizedDescription)")
                } else {
                    if let documents = snapshot?.documents, let userData = documents.first?.data() {
                        // Firestore'dan gelen veriyi kullanarak kullanıcının profil bilgilerini güncelle
                        self.fullnameLabel.text = userData["fullName"] as? String
                        self.aboutLabel.text = userData["about"] as? String
                        self.emailLabel.text = userData["email"] as? String
                        self.phoneNumberLabel.text = userData["phoneNumber"] as? String

                        // Profil fotoğrafını göstermek için Storage'dan URL al ve yükle
                        if let profileImageUrl = userData["profileImageUrl"] as? String {
                            self.loadProfileImage(with: profileImageUrl)
                        }
                    }
                }
            }
        }

    func loadProfileImage(with imageUrl: String) {
        let storageRef = storage.reference(forURL: imageUrl)

        // Storage'dan profil fotoğrafını indir
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading profile image: \(error.localizedDescription)")
            } else {
                // İndirilen veriyi kullanarak UIImage oluştur ve ImageView'da göster
                if let imageData = data, let profileImage = UIImage(data: imageData) {
                    self.profileImageView.image = profileImage
                }
            }
        }
    }
    


}
