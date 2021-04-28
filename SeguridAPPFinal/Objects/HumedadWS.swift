//
//  HumedadWS.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 25/04/21.
//

import Foundation
import Starscream
import Alamofire

class HumedadWS: WebSocketDelegate {
    private var isConnected = false
    private var socket:WebSocket!
    private var topic:String? = nil
    
    let defaults = UserDefaults.standard
    let url = "ws://cisco16.tk/seguridapp"
    let tokenprueba = UserDefaults.standard.object(forKey: "token")
    let humedad = ""
    private var pingTimer:Timer?
    
    let headers:HTTPHeaders = [
            "Authorization":"Bearer \(UserDefaults.standard.object(forKey: "token") ?? "")",
            "Accept":"aplication/json"
        ]
    
    func getDataWS(){
        self.wsconnect()
        self.event("message", data: "movimiento")
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
                                            self.defaults.setValue(topicws, forKey: "topic")
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
           self.sendData(type: 8, data: nil)
       }

       func joinTopic(_ topic:String){
           self.sendData(type: 1, data: ["topic":"humedad"])
           self.topic = topic
       }

       func leaveTopic(_ topic:String){
           self.sendData(type: 2, data: ["topic":"humedad"])
           self.topic = nil
       }

       func event(_ event:String, data:String){
           self.sendData(type: 1, data: ["topic":"humedad", "event":"message", "data":"movimiento"])
           self.pullData(type: 1, data: ["topic":"humedad"])
       }

       func onNewData(_ data:Data) {
           //let decoder = JSONDecoder()
           do {
               let text = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
               print("data received to text: \(text)")

           }catch {
               print("Error de serializacion")
           }
       }


       func sendData(type:Int, data:[String:Any]?){
        let packet = ["t":1,"d":["topic":"humedad"]] as [String : Any]
           do {
               let data = try JSONSerialization.data(withJSONObject: packet, options: .fragmentsAllowed)
               socket.write(data: data)
               print("packetSend->",packet)
           }catch {
               print("Error de serializacion")
           }
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
}
