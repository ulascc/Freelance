//
//  PreferencesViewController.swift
//  Freelance
//
//  Created by ulascancicek on 24.01.2024.
//

import UIKit

class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var microphoneAndCameraSwitch: UISwitch!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is a preferences screen")
        
        // Kullanıcının tercihine göre temayı ayarla
        updateTheme()
    }
    
    // Switch değeri değiştiğinde bu fonksiyon çağrılır
    @IBAction func darkThemeSwitchValueChanged(_ sender: UISwitch) {
        // Kullanıcının tercihini sakla
        UserDefaults.standard.set(sender.isOn, forKey: "DarkThemeEnabled")
        
        // Tüm uygulamadaki temayı güncelle
        updateGlobalTheme()
    }
    
    func updateTheme() {
        // Switch değerine göre koyu tema veya varsayılan tema seçimi
        let darkThemeEnabled = UserDefaults.standard.bool(forKey: "DarkThemeEnabled")
        darkModeSwitch.isOn = darkThemeEnabled
        updateGlobalTheme()
    }
    
    func updateGlobalTheme() {
        // UserDefaults'tan kullanıcının tercihini al
        let darkThemeEnabled = UserDefaults.standard.bool(forKey: "DarkThemeEnabled")
        
        // Tüm uygulamadaki temayı güncelle
        if darkThemeEnabled {
            // Koyu tema
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .forEach { windowScene in
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .dark
                    }
                }
        } else {
            // Varsayılan tema
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .forEach { windowScene in
                    windowScene.windows.forEach { window in
                        window.overrideUserInterfaceStyle = .light
                    }
                }
        }
    }
}
