//
//  SettingsViewController.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 13/04/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var qrLbl: UILabel!
    let defaults = UserDefaults()
    @IBOutlet weak var qrButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
//    @IBAction func DMSwitch(_ sender: UISwitch) {
//        if (sender.isOn == true){
//            overrideUserInterfaceStyle = .dark
//        }
//        if (sender.isOn == false){
//            overrideUserInterfaceStyle = .light
//        }
//    }
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "token")
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
