

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    let db = Firestore.firestore()
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.appName
        
        sendButton.isEnabled = false
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        messageTextfield.delegate = self
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        loadMessages()
        
    }
    func loadMessages(){
        
        db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dateField)
            .addSnapshotListener { [self] querrySnapshot, error in
                if error != nil{
                    print("Error getting documents")
                } else{
                    if let query = querrySnapshot?.documents{
                        messages = []
                        for doc in query{
                            //print (doc.data())
                            if let newBody = doc.data()[Constants.FStore.bodyField] as? String, let newSender = doc.data()[Constants.FStore.senderField] as? String{
                                let newMessage = Message(sender: newSender, body: newBody)
                                self.messages.append(newMessage)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func insertMessageToDB(message: String,sender: String ){
        
        db.collection(Constants.FStore.collectionName).addDocument(data: [
            Constants.FStore.senderField : sender,
            Constants.FStore.bodyField: message,
            Constants.FStore.dateField: Date().timeIntervalSince1970
            
        ]){error in
            if error != nil{
                print("Can't save to FS")
            } else{
                print("Succesfully saved data")
                DispatchQueue.main.async {
                    self.messageTextfield.text = ""
                }
            }
        }
        sendButton.isEnabled = false
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            
            if !messageBody.isEmpty {
                insertMessageToDB(message: messageBody, sender: messageSender)
            }
        }
    }
    
    @IBAction func logOutButtonPresed(_ sender: UIBarButtonItem) {
        let auth = Auth.auth()
        do{
            try auth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError{
            print("Error singing out: %@", signOutError)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = messages[indexPath.row].body
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
        } else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.lightPurple)
        }
        
        
        return cell
    }
    
    
}

extension ChatViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            
            if !messageBody.isEmpty {
                insertMessageToDB(message: messageBody, sender: messageSender)
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let oldText = textField.text else {
            return false
        }
        
        let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
        sendButton.isEnabled = !newText.isEmpty
       
        return true
    }
    
}
