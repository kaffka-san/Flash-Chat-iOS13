

import UIKit
import Firebase



class RegisterViewController: UIViewController  {
        
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "e-mail",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    
    func showSimpleAlert(message: String) {
        let alert = UIAlertController(title: "Error Message", message: message,         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().createUser(withEmail: email, password: password){ result, error in
                if let safeError = error  {
                    
                    // self.delegate?.didFinishWithError(error: safeError.localizedDescription)
                    
                    self.showSimpleAlert(message: safeError.localizedDescription)
                    print("Could not create a User")
                    
                }
                if let _ = result {
                    self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
                    
                }
            }
        }
    }
}
