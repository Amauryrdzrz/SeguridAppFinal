//
//  Scanner.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 13/04/21.
//

import UIKit
import AVFoundation

class Scanner: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var ajustesBTN: UIButton!
    var captureSession:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var Token = ""
    let defaults = UserDefaults()
    
    override func viewDidLoad() {
        
        print("entro a la vista")
        
        super.viewDidLoad()
        
        // Background Color
        //view.backgroundColor = .cyan
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {return}
        print(videoCaptureDevice)
        let videoInput:AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        }catch{
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }else{
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput){
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        // Do any additional setup after loading the view.
    }
    
    func Failed(){
        let ac = UIAlertController(title: "Not supported", message: "Tu dispositivo no es compatible con esta funcion", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning{
            captureSession.stopRunning()
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first{
            guard let readable = metadataObject as? AVMetadataMachineReadableCodeObject
            else {return}
            guard let stringValue = readable.stringValue else {return}
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundTextFromQR(stringValue)
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "settingsVC")
        self.navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    func foundTextFromQR(_ stringValue:String){
        print(stringValue)
        
        if let data = stringValue.data(using: .utf8){
            print(data)
            
            do{
                let message:Message = try! JSONDecoder().decode(Message.self, from: data)
                let ac = UIAlertController(title: "Contenido del QR", message: "Token: \(message.token) Message: \(message.message)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cerrar", style: .default))
                self.present(ac, animated: true, completion: nil)
                let msg = message.message
                self.defaults.setValue(msg, forKey: "msg")
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                }
            }
        }else{
            print("Error de serialización")
        }
    }
    
    
 
}
