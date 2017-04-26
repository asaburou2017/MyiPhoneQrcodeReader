//
//  ViewController.swift
//  7Leaves Card
//
//  Created by Jason McCoy on 12/17/16.
//  Copyright © 2016 Jason McCoy. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    lazy var reader = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
        $0.showTorchButton = true
    })
    
    
    @IBAction func editTapped(_ sender: UIButton) {
        //showAlert()
        showQRAlert()
        //checkForRedeemable()
        editOutlet.isHidden = true
        redeemStarsLblTxt.isHidden = true
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        latteButtonTapped(sender)
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        saveDefaults()
        doneOutlet.isHidden = true
        editOutlet.isHidden = false
        isAuthorized = false
        updateUI()
        redeemStarsLblTxt.isHidden = true
    }
    
    @IBAction func redeemTapped(_ sender: UIButton) {
        if isAuthorized == true {
        latteStamps = 0
        redeemOutlet.isHidden = true
        updateUI()
        doneTapped(doneOutlet) 
        }
    }
    
    
    
    @IBOutlet weak var redeemStarsLblTxt: UIImageView!
    @IBOutlet weak var doneOutlet: UIButton!
    @IBOutlet weak var editOutlet: UIButton!
    @IBOutlet weak var redeemOutlet: UIButton!
    @IBOutlet var latteButtonCollection: Array<UIButton>?
    
    var verificationCode = "qeAuyF9nzFLbHmqm4qQsx8bkBPx4qzFyxQp9XSH5xRBtfQdK4Ax6rC7tYchkVqYpYxJ4Ranpcsn4K9crL4xgj7rTegkt8qdsKVHHzGS9S3VUvzXpaTwJUx8bNR6DtTWesDgyMCZhjZ3myVCpmwy7dzwpKwZJRHpD73u5K4GxxWAFbHXvB6EfaKdewDARwX8eVBTtfNwW64KYjZXfjTnZYx5SZMZ9nvTZDJu2B73b4DDQbZHc4yBBLFHDsJEdP9veaQcQJBzuf7cUZd3H76m3dkdSvvfp8KVbsWcXwes9apepXr5dX9hDjDaTkLVh7R3CktUvC3xx7C7nLXSEMSVw9BuUWwL3EUkfJhyX7RDQDLvs4b9pFFXqmQLkuUpGyLgWvVuN6NdC5sV7U6ZCqZsu9FpznyBrDvSQHXJn7pct3VLfMbTLGUhbXVrag3cJYnBn4yRbTPMj3s4n3WMUNtG2ARzBnR4jVQtVw6NRTbMcaLNnNDkZSPmjp3qVPjr7YB85"
    var latteStamps = 0
    var coffeeStamps = 0
    var isAuthorized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDefaults()
        //checkForRedeemable()
        updateUI()
        
    }

    //MARK: - Button functions
    
    func latteButtonTapped(_ sender:UIButton) {
        if isAuthorized == true {
            if sender.isSelected == true {
                latteStamps = latteStamps - 1
                sender.isSelected = false
            } else {
                latteStamps = latteStamps + 1
                sender.isSelected = true
            }
        }
        
        //checkForRedeemable()
        
        print("stamps equals \(latteStamps)")
        
    }
    
    //MARK: - Alert set up
    
    func showAlert() {
        
        let alertController = UIAlertController(title: "Password Required!", message: "Please allow the store employee to type the super secret password onto your phone please!", preferredStyle: .alert)
        
        // Added another text field, but fixed hiding password
        alertController.addTextField {
            (textField) -> Void in
            
            textField.placeholder = "Type in the super secret password"
            textField.isSecureTextEntry = true
        }
        //
        
        let verifyAction = UIAlertAction(title: "Authorize", style: .default) {
            (verifyAction) -> Void in
            
        let textField = alertController.textFields?.first
            
            // test for verification
            if textField!.text == self.verificationCode { // TO DO: Show "Success!" image or popup.
                print("Approved!")
                self.latteStamps = 0
                self.coffeeStamps = 0
                self.loadDefaults()
                self.updateUI()
                self.doneOutlet.isHidden = false
                self.editOutlet.isHidden = true
                self.isAuthorized = true
                
            } else { // TO DO: Show "Failed!" image or popup.
                // fails authorization
                self.redeemStarsLblTxt.isHidden = true
                self.editOutlet.isHidden = false
                print("Authorization Failed!")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (alertAction) -> Void in
            
            self.editOutlet.isHidden = false
            self.redeemStarsLblTxt.isHidden = true
            
        }
        alertController.addTextField {
            (textField) -> Void in
        }
        
        alertController.addAction(verifyAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showQRAlert() {
        do {
            if try QRCodeReader.supportsMetadataObjectTypes() {
                reader.modalPresentationStyle = .formSheet
                reader.delegate               = self
                
                reader.completionBlock = { (result: QRCodeReaderResult?) in
                    if let result = result {
                        print("Completion with result: \(result.value) of type \(result.metadataType)")
                    }
                }
                
                present(reader, animated: true, completion: nil)
            }
        } catch let error as NSError {
            switch error.code {
            case -11852:
                let alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:])
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
                
                
                
            case -11814:
                let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            default:()
            }
        }
    }
    
    
    //MARK: - UI interaction functions
    func checkForRedeemable() {
        
        if self.latteStamps == 11 {
            self.latteStamps = 1
            //self.redeemOutlet.isHidden = false
        } else {
            //self.redeemOutlet.isHidden = true
        }
    }

    
    func updateUI() {
        
        for button in latteButtonCollection! {
            button.isSelected = false
            
            if button.tag <= latteStamps {
                button.isSelected = true
            }
            
        }
        
    }
    
    //MARK: - NSUserDefaults functions
    func saveDefaults() {
        print("saved")
        let defaults = UserDefaults.standard
        let numberOfLattes = NSNumber(value: self.latteStamps)
        let numberOfCoffees = NSNumber(value: self.coffeeStamps)
        defaults.setValue(numberOfLattes, forKey: "stampsNumber")
        defaults.setValue(numberOfCoffees, forKey: "coffeeStamps")
        defaults.synchronize()
        
    }
    
    func loadDefaults() {
        let defaults = UserDefaults.standard
        if let value = defaults.value(forKey: "stampsNumber") as? NSNumber {
            self.latteStamps = value.intValue
        }
        if let coffeeValue = defaults.value(forKey: "coffeeStamps") as? NSNumber {
            self.coffeeStamps = coffeeValue.intValue
        }
        print("loaded stamps \(latteStamps)")
        
    }
    
    // MARK: - QRCodeReader Delegate Methods
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true){ [weak self] in
            if result.value == self?.verificationCode { // TO DO: Show "Success!" image or popup.
                print("Approved!")
                
                
                let alert = UIAlertController(title: "", message: "Stamp Added!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    DispatchQueue.main.async {
                        self?.latteStamps += 1
                        self?.coffeeStamps = 0
                        self?.checkForRedeemable()
                        self?.updateUI()
                        self?.saveDefaults()
                        self?.doneOutlet.isHidden = true
                        self?.editOutlet.isHidden = false
                        self?.isAuthorized = false
                        self?.updateUI()
                        self?.redeemStarsLblTxt.isHidden = true
                    }
                }))
                self?.present(alert, animated: true, completion: nil)
                
            } else { // TO DO: Show "Failed!" image or popup.
                // fails authorization
                
                let alert = UIAlertController(
                    title: "",
                    message: "Invalid QR Code!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:  { (_) in
                    DispatchQueue.main.async {
                        //self?.ScanQRCode(scannedString: "", isSuccess: false)
                        self?.redeemStarsLblTxt.isHidden = true
                        self?.editOutlet.isHidden = false
                        print("Authorization Failed!")
                    }
                }))
                self?.present(alert, animated: true, completion: nil)
                
                /*
                self?.redeemStarsLblTxt.isHidden = true
                self?.editOutlet.isHidden = false
                print("Authorization Failed!")
                
                */
            }
        
        /*
         
        if result.value == self.verificationCode { // TO DO: Show "Success!" image or popup.
            print("Approved!")
            self.latteStamps = 0
            self.coffeeStamps = 0
            self.loadDefaults()
            self.updateUI()
            self.doneOutlet.isHidden = false
            self.editOutlet.isHidden = true
            self.isAuthorized = true
            
        } else { // TO DO: Show "Failed!" image or popup.
            // fails authorization
            self.redeemStarsLblTxt.isHidden = true
            self.editOutlet.isHidden = false
            print("Authorization Failed!")
         
            */
        }
        
        // dismiss(animated: true)
        
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
        self.editOutlet.isHidden = false
        self.redeemStarsLblTxt.isHidden = true
    }
    
}
