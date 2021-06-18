//
//  ViewController.swift
//  Biometric_Authentication
//
//  Created by Alex on 17/06/21.
//

import UIKit

import LocalAuthentication

class ViewController: UIViewController {
    
    let context = LAContext()
    
    
    var biometryType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //  check biometry type
        switch context.biometryType {
        case .faceID:
            biometryType = "Face ID"
        case .touchID:
            biometryType = "Touch ID"
        default:
            biometryType = ""
        }
    }

    @IBAction func authenticateBtnAction(_ sender: Any) {
        
        var error: NSError?
        
        //  check if device can authenticate
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            //  device can authenticated with biometrics
            authenticateUser()
        } else {
            //  device cannot use biometric authentication
            if let error = error {
                switch error.code {
                    case LAError.Code.biometryNotEnrolled.rawValue:
                        showAlert(message: "\(biometryType) not Enrolled")
                case LAError.Code.passcodeNotSet.rawValue:
                    showAlert(message: "Passcode not added")
                case LAError.Code.biometryNotAvailable.rawValue:
                    showAlert(message: "Biometric authentication not available")
                default:
                    showAlert(message: "Unknown error")
                }
            }
        }
    }
    private func authenticateUser() {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Authentication required") {
            (sucess, error) in
            DispatchQueue.main.async {
                if sucess {
                    //  user sucessfully authenticated
                    self.performSegue(withIdentifier: "showInnerPage", sender: nil)
                } else if let err = error {
                    switch err._code {
                    case LAError.Code.systemCancel.rawValue:
                        self.showAlert(message: "Session canceled")
                    case LAError.Code.userCancel.rawValue:
                        self.showAlert(message: "Authentication canceled. Please try again")
                    case LAError.Code.userFallback.rawValue:
                        self.showAlert(message: "User chose to enter password")
                    case LAError.Code.biometryLockout.rawValue:
                        self.showAlert(message: "Too many attempts. Please try again later")
                    default:
                        self.showAlert(message: "Authentication failed")
                    }
                } else {
                    self.showAlert(message: "Unknown error")
                }
            }
        }
    }
    

    private func showAlert(with title: String = "Authentication", message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

