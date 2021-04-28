//
//  MenuViewController.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 13/04/21.
//
import SideMenu
import UIKit
import Starscream
import Alamofire
import SwiftyJSON

class MenuViewController: UIViewController, MenuControllerDelegate, WebSocketDelegate {

    @IBOutlet weak var ViewHT: UIView!
    @IBOutlet weak var ViewPD: UIView!
    @IBOutlet weak var ViewR: UIView!
    @IBOutlet weak var ViewC: UIView!
    @IBOutlet weak var humLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var distLbl: UILabel!
    @IBOutlet weak var presenciaLbl: UILabel!
    @IBOutlet weak var refresh: UIBarButtonItem!
    @IBOutlet weak var personaIV: UIImageView!
    @IBOutlet weak var consP: UILabel!
    @IBOutlet weak var consMinT: UILabel!
    @IBOutlet weak var consMaxT: UILabel!
    @IBOutlet weak var consMinH: UILabel!
    @IBOutlet weak var consMaxH: UILabel!
    
    private var sideMenu: SideMenuNavigationController?
    private let settingsVC = SettingsViewController()
    private var isConnected = false
    private var socket:WebSocket!
    private var topic:String? = nil
    
    let defaults = UserDefaults.standard
    let url = "ws://cisco16.tk/seguridapp"
    let urlmaxtemp = "http://cisco16.tk/api/result/tempMax"
    let urlmintemp = "http://cisco16.tk/api/result/tempMin"
    let urlmaxhum = "http://cisco16.tk/api/result/tempMax"
    let urlminhum = "http://cisco16.tk/api/result/tempMin"
    let urlpresencias = "http://cisco16.tk/api/result/presenceCounter"
    
    let tokenprueba = UserDefaults.standard.object(forKey: "token")
    let humedad = ""
    private var pingTimer:Timer?
    
    let headers:HTTPHeaders = [
            "Authorization":"Bearer \(UserDefaults.standard.object(forKey: "token") ?? "")",
            "Accept":"aplication/json"
        ]
    override func viewDidLoad() {
        super.viewDidLoad()
        print(headers)
        wsconnect()
//        HumedadWS().getDataWS()
//        event("message", data: "movimiento")
        self.sendData()
        //ViewHT.alpha = 0.4
        ViewC.layer.cornerRadius = 10
        ViewHT.layer.cornerRadius = 10
        ViewPD.layer.cornerRadius = 10
        
        let menu = MenuController(with: ["Ajustes"])
        
        menu.delegate = self
        
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        // Do any additional setup after loading the view.
        addChildControllers()
        
        
    }
    
    struct strData:Decodable {
        var topic:String
        var event:String
        var message:String
        var data:String
    }
    
    @IBAction func Refrescarpantalla(_ sender: Any) {
        AF.request(urlmaxtemp, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON() { response in
            switch response.result{
                case .success(let value):
                    guard let jsonArray = value as? [String:Any] else {return}
                    guard let data = jsonArray["data"] as? String else {return}
                    self.consMaxT.text = data
                case .failure(let error):
                    print(error)
            }
        }
        AF.request(urlmintemp, method: .get, headers: headers).responseJSON(){
            response in

            switch response.result{
                case .success(let value):
                    guard let jsonArray = value as? [String:Any] else {return}
                    guard let data = jsonArray["data"] as? String else {return}
                    self.consMinT.text = data
                case .failure(let error):
                    print(error)
            }
        }
        AF.request(urlmaxhum, method: .get, headers: headers).responseJSON(){
            response in
            switch response.result{
                case .success(let value):
                    guard let jsonArray = value as? [String:Any] else {return}
                    guard let data = jsonArray["data"] as? String else {return}
                    self.consMaxH.text = data
                case .failure(let error):
                    print(error)
            }
        }
        AF.request(urlminhum, method: .get, headers: headers).responseJSON(){
            response in

            switch response.result{
                case .success(let value):
                    guard let jsonArray = value as? [String:Any] else {return}
                    guard let data = jsonArray["data"] as? String else {return}
                    self.consMinH.text = data
                case .failure(let error):
                    print(error)
            }
        }
        AF.request(urlpresencias, method: .get, headers: headers).responseJSON(){
            response in
            switch response.result{
                case .success(let value):
                    guard let jsonArray = value as? [String:Any] else {return}
                    guard let data = jsonArray["data"] as? String else {return}
                    self.consP.text = data
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    struct strResponse:Decodable {
        var t:String
        var d:strData
    }
    
    struct wsHumedad:Decodable {
        var data:String
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            wsdisconnect()
    }

    func viewWillAppear(){
        self.sendData()
    }

    func wsconnect(){
        var request = URLRequest(url: URL(string: "ws://cisco16.tk/seguridapp/?token=\(tokenprueba!)")!)
           request.timeoutInterval = 5
           socket = WebSocket(request: request)
           socket.delegate = self
           socket.connect()
       }

       func wsdisconnect(){
           socket.disconnect()
       }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
            switch event {
                case .connected(let headers):
                    isConnected = true
                    print("websocket is connected: \(headers)")
                    self.pingTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
                    self.pingTimer?.fire()
                case .disconnected(let reason, let code):
                    isConnected = false
                    print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let wsResponse):
                    print("Received text:\(wsResponse)")
                guard let jsonData = wsResponse.data(using: .utf8, allowLossyConversion: false) else {
                    print("Fail Convert To Data")
                    return
                }
                do {
               
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        if let dObject = jsonArray["d"] {
                            do {
                                let dataObject = try JSONSerialization.data(withJSONObject: dObject, options: .fragmentsAllowed)
                                do {
                                    if let dataArray = try JSONSerialization.jsonObject(with: dataObject, options: []) as? [String:Any] {
                                        if let topicws = dataArray["topic"]{
                                            if topicws as! String == "humedad"{
                                                if let dataH = dataArray["data"]{
                                                    humLbl.text = dataH as? String
                                                    
                                                }
                                            }
                                            if topicws as! String == "ultrasonico"{
                                                if let dataU = dataArray["data"]{
                                                    self.defaults.setValue(dataU, forKey: "ultrasonico")
                                                    distLbl.text = (self.defaults.object(forKey: "ultrasonico") as! String)
                                                    self.outDistancia()
                                                }
                                            }
                                            if topicws as! String == "pir"{
                                                if let dataP = dataArray["data"]{
                                                    self.defaults.setValue(dataP, forKey: "pir")
                                                    if self.defaults.object(forKey: "pir") as? String == "1" {
                                                        presenciaLbl.text = "Hay movimiento"
                                                        self.ViewPD.backgroundColor = .red
                                                        let animation = CABasicAnimation(keyPath: "position")
                                                        animation.duration = 0.07
                                                        animation.repeatCount = 4
                                                        animation.autoreverses = true
                                                        animation.fromValue = NSValue(cgPoint: CGPoint(x: personaIV.center.x - 10, y: personaIV.center.y))
                                                        animation.toValue = NSValue(cgPoint: CGPoint(x: personaIV.center.x + 10, y: personaIV.center.y))

                                                        personaIV.layer.add(animation, forKey: "position")
                                                    }else{
                                                        presenciaLbl.text = "No hay movimiento"
                                                    }
                                                        
                                                        self.outPIR()
                                                }
                                            }
                                            if topicws as! String == "temperatura"{
                                                if let dataT = dataArray["data"]{
                                                    self.defaults.setValue(dataT, forKey: "temperatura")
                                                    tempLbl.text = (self.defaults.object(forKey: "temperatura") as! String)
                                                    self.outTemperatura()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                } else {
                    print("Fail To Serialization")
                }
                } catch let error as NSError {
                    print(error)
                }
                
                case .binary(let data):
                    print("Received data: \(data)")
                    self.onNewData(data)
                case .ping(_):
                    break
                case .pong(_):
                    break
                case .viabilityChanged(_):
                    break
                case .reconnectSuggested(_):
                    break
                case .cancelled:
                    isConnected = false
                case .error(_):
                    isConnected = false
                }
        }

    @objc func ping() {
//         let packet = ["t":8] as [String : Any]
//            do {
//                let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
//                socket.write(data: data)
//                print("packetSend->",packet)
//            }catch {
//                print("Error de serializacion")
//            }
        self.getHumedad()
        self.getDistancia()
        self.getTemperatura()
        self.getPIR()
//        self.outHumedad()
//        self.outDistancia()
//        self.outTemperatura()
//        self.outPIR()
//
       }

//       func joinTopic(_ topic:String){
//        self.sendData(type: 1, data: ["topic":"pir"])
//           self.topic = topic
//       }
//
//       func leaveTopic(_ topic:String){
//           self.sendData(type: 2, data: ["topic":"pir"])
//           self.topic = nil
//       }
//
//       func event(_ event:String, data:String){
//           self.sendData(type: 1, data: ["topic":"pir", "event":"message", "data":"movimiento"])
//       }

       func onNewData(_ data:Data) {
           //let decoder = JSONDecoder()
           do {
               let text = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
               print("data received to text: \(text)")

           }catch {
               print("Error de serializacion")
           }
       }
    
    func getHumedad() {
        let packet = ["t":1,"d":["topic":"humedad"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }
    
    func outHumedad() {
        let packet = ["t":2,"d":["topic":"humedad"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }
    
    func getTemperatura() {
        let packet = ["t":1,"d":["topic":"temperatura"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }
    
    func outTemperatura() {
        let packet = ["t":2,"d":["topic":"temperatura"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }
    
    func getDistancia() {
        let packet = ["t":1,"d":["topic":"ultrasonico"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }
    
    func outDistancia() {
        let packet = ["t":2,"d":["topic":"ultrasonico"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }
    
    func getPIR() {
        self.presenciaLbl.text = "No hay movimiento"
        self.ViewPD.backgroundColor = UIColor(displayP3Red: 255.0, green: 255.0, blue: 255.0, alpha: 0.4)
        let packet = ["t":1,"d":["topic":"pir"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }

    func outPIR() {
        let packet = ["t":2,"d":["topic":"pir"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
    }

       func sendData(){
        self.getHumedad()
        self.getDistancia()
        self.getTemperatura()
        self.getPIR()
       }
    
    func pullData(type:Int, data:[String:Any]){
     let packet = ["t":type,"d":data] as [String : Any]
        do {
            let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
            socket.write(data: data)
            print("packetPull->",packet)
        }catch {
            print("Error de serializacion")
        }
    }
    
    private func addChildControllers(){
        addChild(settingsVC)
        
        view.addSubview(settingsVC.view)
        
        settingsVC.view.frame = view.bounds
        
        settingsVC.didMove(toParent: self)
    }
    
    @IBAction func didTapMenu(){
        present(sideMenu!, animated: true)
    }
    
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: {
        
            self.title = named
            
            if named == "Ajustes"{
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyBoard.instantiateViewController(withIdentifier: "settingsVC")
                self.navigationController?.pushViewController(mainViewController, animated: true)
            }
    
        })
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
