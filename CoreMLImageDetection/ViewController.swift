//
//  ViewController.swift
//  CoreMLImageDetection
//
//  Created by Andrew Seeley on 12/6/17.
//  Copyright © 2017 Seemu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var myPhoto: UIImageView!
    @IBOutlet var lblResult: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detectImageContent()
        
    }
    
    func detectImageContent() {
        lblResult.text = "Thinking"
        
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            fatalError("Failed to load model")
        }
        
        // Create a vision request
        
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }
            
            // Update the Main UI Thread with our result
            DispatchQueue.main.async { [weak self] in
                self?.lblResult.text = "\(topResult.identifier) with \(Int(topResult.confidence * 100))% confidence"
            }
        }
        
        guard let ciImage = CIImage(image: self.myPhoto.image!)
            else { fatalError("Cant create CIImage from UIImage") }
        
        // Run the googlenetplaces classifier
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myPhoto.contentMode = .scaleToFill
            myPhoto.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        detectImageContent()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

