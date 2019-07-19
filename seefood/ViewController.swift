//
//  ViewController.swift
//  seefood
//
//  Created by Diego Mendoza on 7/19/19.
//  Copyright © 2019 Diego Mendoza. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    var hotdogLabel: UILabel?
    var backgroundTop: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(preview)
        
        preview.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        
        
        backgroundTop = {
            let view = UIView()
            view.backgroundColor = .red
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        view.addSubview(backgroundTop!)
        
        backgroundTop?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundTop?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundTop?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundTop?.heightAnchor.constraint(equalToConstant: 160).isActive = true
            
        
        hotdogLabel = {
            let label = UILabel()
            label.text = "Not Hot Dog"
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            return label
        }()
        
        
        
        backgroundTop!.addSubview(hotdogLabel!)
        hotdogLabel?.centerYAnchor.constraint(equalTo: backgroundTop!.centerYAnchor, constant: 0).isActive = true
        hotdogLabel?.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model =  try?VNCoreMLModel(for: Resnet50FP16().model) else {return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            if (error != nil)  {
            } else {
                
                guard let results = finishedRequest.results as? [VNClassificationObservation] else {return}
                
                guard let firsObservation =  results.first else {return}
                
                if let prediction: String = "\(firsObservation)" {
                    DispatchQueue.main.async {
                        if prediction.contains("hot dog") || prediction.contains("hotdog") {
                            self.hotdogLabel?.text = "Hot Dog!"
                            self.backgroundTop?.backgroundColor = .green
                        } else {
                            self.hotdogLabel?.text = "Not Hot Dog"
                            self.backgroundTop?.backgroundColor = .red
                        }
                    }
//                    self.hotdogLabel?.text = prediction
                    
                }
            }
        }
        
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [: ]).perform([request])
    }


}

