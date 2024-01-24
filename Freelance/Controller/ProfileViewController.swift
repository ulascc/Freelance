import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        // Kullanıcının UID'sini al
        if let user = Auth.auth().currentUser {
            let userRef = db.collection("users").document(user.uid)
            
            // Firestore'daki kullanıcı verilerini çek
            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let userData = document.data()!
                    
                    // Firestore'dan gelen veriyi kullanarak kullanıcının profil bilgilerini güncelle
                    self.fullnameLabel.text = userData["fullName"] as? String
                    self.aboutLabel.text = userData["about"] as? String
                    self.emailLabel.text = userData["email"] as? String
                    self.phoneNumberLabel.text = userData["phoneNumber"] as? String
                    self.cityLabel.text = userData["city"] as? String
                    
                    // Profil fotoğrafını göstermek için Storage'dan URL al ve yükle
                    if let profileImageUrl = userData["profileImageUrl"] as? String {
                        self.loadProfileImage(with: profileImageUrl)
                    }
                } else {
                    print("Document does not exist")
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
    
    
    @IBAction func EditProfileButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "EditProfileSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfileSegue" {
            if let destinationVC = segue.destination as? EditProfileViewController {
                // Verileri güvenli bir şekilde atamak için nil kontrolü yapın
                destinationVC.fullName = fullnameLabel.text ?? ""
                destinationVC.about = aboutLabel.text ?? ""
                destinationVC.phoneNumber = phoneNumberLabel.text ?? ""
                destinationVC.city = cityLabel.text ?? ""
            }
        }
    }
}
