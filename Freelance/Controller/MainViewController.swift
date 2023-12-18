import UIKit
import FirebaseFirestore

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var jobsTableView: UITableView!
    
    var jobs: [Job] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        jobsTableView.dataSource = self
        jobsTableView.delegate = self
       
        // Tableview'ın kenar boşluklarını ayarla
        jobsTableView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        jobsTableView.register(UINib(nibName: "JobCell", bundle: nil), forCellReuseIdentifier: "JobCell")

        let db = Firestore.firestore()

        // Firestore'daki "jobs" koleksiyonundan verileri çek
        db.collection("jobs").getDocuments { (snapshot, error) in
            if let error = error {
                print("Veri çekme hatası: \(error.localizedDescription)")
            } else {
                // Verileri çekme başarılı.
                if let documents = snapshot?.documents {
                    self.jobs = documents.compactMap { document in
                        // Document ID'yi al
                        let documentID = document.documentID
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let category = data["category"] as? String ?? ""
                        let city = data["city"] as? String ?? ""
                        let explanation = data["explanation"] as? String ?? ""
                        let price = data["price"] as? String ?? ""
                        let publisher = data["publisher"] as? String ?? ""
                        return Job(publisher: publisher, title: title, explanation: explanation, price: price, category: category, city: city, uid: documentID)
                    }
                    
                    // Verileri kontrol et
                    print("Jobs Dizisi: \(self.jobs)")

                    // TableView'ı güncelle
                    self.jobsTableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // "JobCell" olarak tanımlanan hücreyi kullan
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell

        let job = jobs[indexPath.row]
        
        // JobCell içindeki IBOutlet'leri kullanarak verileri ayarla
        cell.jobTitle.text = job.title
        cell.jobExplanation.text = job.explanation
        cell.jobPrice.text = "\(job.price) TL"
        cell.jobCity.text = job.city
        cell.jobUid.text = job.uid
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 130.0 // Örnek olarak 80 birim mesafe belirlendi, siz istediğiniz değeri kullanabilirsiniz.
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçili hücrenin seçimini kaldır
        tableView.deselectRow(at: indexPath, animated: true)

        // Storyboard üzerinde tanımladığınız segue'yi çalıştırın
        performSegue(withIdentifier: "JobDetailSegue", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           return UISwipeActionsConfiguration(actions: [])
       }
       
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           return UISwipeActionsConfiguration(actions: [])
       }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JobDetailSegue" {
            // Hedef view controller'ı alın
            if let destinationVC = segue.destination as? JobDetailViewController {
                // IndexPath'ten seçilen işi alın
                if let selectedRow = sender as? Int {
                    // Seçilen işi JobDetailViewController'a iletmek için gerekli bilgileri alın
                    let selectedJob = jobs[selectedRow]
                    print("Selected Job: \(selectedJob)")

                    // JobDetailViewController'ın IBOutlet'lerine değerleri atayın
                    destinationVC.jobTitle = selectedJob.title
                    destinationVC.jobExplanation = selectedJob.explanation
                    destinationVC.jobPuplisher = selectedJob.publisher
                    destinationVC.jobPrice = "\(selectedJob.price) TL"
                    destinationVC.jobCategory = selectedJob.category
                    destinationVC.jobCity = selectedJob.city
                    destinationVC.jobUid = selectedJob.uid
                }
            }
        }
    }


}
