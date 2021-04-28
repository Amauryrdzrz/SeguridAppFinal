//
//  ViewController.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 13/04/21.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    let defaults = UserDefaults()
    var url = "http://cisco16.tk/api/login"
    var local = "http://0.0.0.0:3333/api/login"
    struct LoginStruct: Decodable {
        var refreshToken : String
        var token : String
        var type: String
    }
    struct ErrorStruct: Decodable {
        var message: String
    }
    @IBOutlet weak var enterBTN: UIButton!
    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPwd: UITextField!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewContainer.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
        let headers: HTTPHeaders = [
         "Accept":"application/json"
        ]
        let parametros = ["password": self.defaults.object(forKey: "password"), "email": self.defaults.object(forKey: "email") ]
        AF.request(url, method: .post, parameters: parametros, encoding: JSONEncoding.default, headers: headers).responseJSON() { [self] response in
            switch response.result {
            case .success(let value):
                guard let jsonArray = value as? [String: Any] else {return}
                guard let token = jsonArray["token"] as? String else {return}
                self.defaults.set(token, forKey: "token")
                if self.defaults.string(forKey: "token") != ""{
                    enterBTN.sendActions(for: .touchUpInside)
                }
                let ac = UIAlertController(title: "Error", message: "Contraseña o usuario erroneo", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cerrar", style: .default))
                self.present(ac, animated: true, completion: nil)
            case .failure(let error):
                print(error)
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func Login(_ sender:UIButton){
        
               let headers: HTTPHeaders = [
            "Accept":"application/json"
        ]
        if isValidEmail(stringValue: TFEmail.text!){
            if  TFEmail.text != "" && TFPwd.text != ""{
                let params = ["password": TFPwd.text!, "email": TFEmail.text!]
                //print(params)
                guard let password = TFPwd.text else {return}
                guard let email = TFEmail.text else {return}
                self.defaults.setValue(password, forKey: "password")
                self.defaults.setValue(email, forKey: "email")
                AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON() { [self] response in
                    print(response)
                    switch response.result {
                    case .success(let value):
                        guard let jsonArray = value as? [String: Any] else {return}
                        guard let token = jsonArray["token"] as? String else {return}
                        self.defaults.set(token, forKey: "token")
                        if self.defaults.string(forKey: "token") != ""{
                            enterBTN.sendActions(for: .touchUpInside)
                        }
                        let ac = UIAlertController(title: "Error", message: "Contraseña o usuario erroneo", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Cerrar", style: .default))
                        self.present(ac, animated: true, completion: nil)
                    case .failure(let error):
                        print(error)
                        
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
                animation.fromValue = NSValue(cgPoint: CGPoint(x: loginButton.center.x - 10, y: loginButton.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: loginButton.center.x + 10, y: loginButton.center.y))

                loginButton.layer.add(animation, forKey: "position")
            }
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: loginButton.center.x - 10, y: loginButton.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: loginButton.center.x + 10, y: loginButton.center.y))

            loginButton.layer.add(animation, forKey: "position")
            }else{
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: loginButton.center.x - 10, y: loginButton.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: loginButton.center.x + 10, y: loginButton.center.y))

                loginButton.layer.add(animation, forKey: "position")
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
}

