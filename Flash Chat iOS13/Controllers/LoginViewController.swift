

import UIKit
import Firebase
class LoginViewController: UIViewController {

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
        navigationItem.titleView?.tintColor = UIColor(named: "white")
    }
    func showSimpleAlert(message: String) {
        let alert = UIAlertController(title: "Error Message", message: message,         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: { _ in
                //Cancel Action
            }))
           
            self.present(alert, animated: true, completion: nil)
        }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
       
        if let safeEmail = emailTextfield.text, let safePassword = passwordTextfield.text {
            Auth.auth().signIn(withEmail: safeEmail, password: safePassword){ result, error in
                if error != nil{
                    self.showSimpleAlert(message: error!.localizedDescription)
                    print("Login error")
                }
                else if result != nil{
                    print("Sussces login")
                    self.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                }
            }
            
        }
    }
    
}
