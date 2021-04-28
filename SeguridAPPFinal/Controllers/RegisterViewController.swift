//
//  RegisterViewController.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 13/04/21.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {

    let defaults = UserDefaults()
    var url = "http://cisco16.tk/api/register"
    var local = "http://0.0.0.0/3333/api/login"

    @IBOutlet weak var TFName: UITextField!
    @IBOutlet weak var TFLName: UITextField!
    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPwd: UITextField!
    @IBOutlet weak var TFAge: UITextField!
    @IBOutlet weak var TFCel: UITextField!
    @IBOutlet weak var containerRegister: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 15
        backButton.backgroundColor = .darkGray
        containerRegister.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func Register(_ sender: UIButton) {
        
        let headers:HTTPHeaders = [
            "Accept":"application/json",
            "Content-Type": "application/json"
        ]
        if isValidEmail(stringValue: TFEmail.text!){
            if TFEmail.text! != "" && TFPwd.text! != "" && TFName.text! != "" && TFAge.text != "" && TFCel.text != "" && TFLName.text != "" {
                let params = ["email": TFEmail.text!, "password": TFPwd.text!, "name":TFName.text!, "last_name":TFLName.text!, "age": TFAge.text!, "cel": TFCel.text!
                ]
                AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON
                { [self] (response) in
                    print(response)
                    switch response.result {
                    case .success(let value):
                        print("entro")
                        guard let jsonArray = value as? [String: Any] else {return}
                        guard let status = jsonArray["status"] as? String else {return}
                        self.defaults.set(status, forKey: "status")
//                        let ac = UIAlertController(title: "Registro Exitoso", message: self.defaults.object(forKey: "status") as? String, preferredStyle: .alert)
//                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
//                        self.present(ac, animated: true, completion: nil)
//
                        loginBtn.sendActions(for: .touchUpInside)
                    case .failure(_):
                        print(response)
                    }
                }
            }else{
                let ac = UIAlertController(title: "Error", message: "Los campos estan incompletos", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(ac, animated: true, completion: nil)
                
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: registerButton.center.x - 10, y: registerButton.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: registerButton.center.x + 10, y: registerButton.center.y))

                registerButton.layer.add(animation, forKey: "position")
            }
        }else{
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: registerButton.center.x - 10, y: registerButton.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: registerButton.center.x + 10, y: registerButton.center.y))

            registerButton.layer.add(animation, forKey: "position")
            
            let ac = UIAlertController(title: "Error", message: "No es un email valido", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true, completion: nil)
        }
        
    }
    
    func isValidEmail(stringValue: String) ->Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: stringValue)
    }
     
    /*
    // MARK: - Navigation@
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
