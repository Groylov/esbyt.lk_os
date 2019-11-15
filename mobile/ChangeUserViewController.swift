//
//  ChangeUserViewController.swift
//  mobile
//
//  Created by Groylov on 06/06/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class usersCell: UITableViewCell {
    
    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var userNameText: UILabel!
}

class ChangeUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    private var arrayUsers: [StructUsers]?
    private var currentUser: StructUsers?
    private var selectUser: StructUsers?
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    var changeCurrentUser_postFunc: ((Bool) -> Void)?
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var mainPanel: UIView!
    
    private func renameSelectUser(name newName: String) {
        if selectUser != nil {
            let newReadName: String = newName == "" ? selectUser!.userName : newName
            dataUsers!.setPrintName(user: selectUser!.userName, printName: newReadName)
            arrayUsers = dataUsers?.getAllUsers()
            usersTable.reloadData()
        }
    }
    
    /// Функция анимации открытия окна
    private func moveIn() {
        self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.24) {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }
    }
    
    /// Функция анимации закрытия окна
    private func moveOut() {
        UIView.animate(withDuration: 0.24, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            self.view.alpha = 0.0
        }) { _ in
            self.view.removeFromSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayUsers != nil {
            return arrayUsers!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTable.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! usersCell
        let rowUsers = arrayUsers![indexPath.row]
        cell.userNameText.text = rowUsers.userPrintName
        if rowUsers.isEquival(currentUser) {
            let cellImage = UIImage(named: "MainVC_currentUser")
            if cellImage != nil {
                cell.currentUserImage?.image = cellImage!
                cell.currentUserImage?.highlightedImage = cellImage!
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if arrayUsers != nil {
                let rowUser = arrayUsers![indexPath.row]
                // если несколько пользователей в списке и мы удаляем текущего
                if rowUser.isEquival(currentUser) {
                    if arrayUsers!.count > 1 {
                        currentUser = arrayUsers![1]
                    }
                }
                dataUsers!.removeUser(userName: rowUser.userName)
                arrayUsers = dataUsers!.getAllUsers()
                usersTable.reloadData()
                if arrayUsers!.count == 0 {
                    if let loginNavigationVC = storyboard!.instantiateViewController(withIdentifier: "loginNavigationController") as? UINavigationController {
                        moveOut()
                        present(loginNavigationVC,animated: true,completion: nil)
                    }
                }
            }
        }
    }

    /// Функция обработки события создания формы
    override func viewDidLoad() {
        super.viewDidLoad()
        setPortableView(vc: self, panel: mainPanel)
        if dataUsers != nil {
            arrayUsers = dataUsers!.getAllUsers()
            currentUser = dataUsers!.getCurrentUser()
        }
    }
    
    /// Функция обработки события тапа
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchView = touch.view
        if touchView != nil {
            if touchView!.isEqual(self.view) {
                moveOut()
            }
        }
        return false
    }
    
    func addUser_postFunc(account uAccount: String, password uPassword: String, return returnFunction: BackOfficeMobileReturn) {
        DispatchQueue.main.sync {
            self.activityIndicator.stopAnimating()
        }
        dismiss(animated: true, completion: nil)
        
        if returnFunction.isError() {
            let errorText = returnFunction.getErrorText()
            showMessageError(view: self, name: "ChangeUserVC", message: errorText)
        } else {
            let token = returnFunction.getReturnData() as? String
            if token != nil {
                if dataUsers != nil {
                    let countUsers = dataUsers!.getCountUsers()
                    dataUsers!.addUser(userName: uAccount, userToken: token!, userPriority: countUsers)
                }
            }
        }
        arrayUsers = dataUsers!.getAllUsers()
        currentUser = dataUsers!.getCurrentUser()
        DispatchQueue.main.sync {
            self.usersTable.reloadData()
        }
    }
    
    @IBAction func addUserTouch(_ sender: Any) {
        if let loginForm = storyboard!.instantiateViewController(withIdentifier: "loginNavigationController") as? LoginNavigationViewController {
            loginForm.userListPostFunction = addUser_postFunc
            loginForm.activityIndicator = self.activityIndicator
            present(loginForm,animated: true,completion: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if arrayUsers != nil {
            selectUser = arrayUsers![indexPath.row]
            if !tableView.isEditing {
                if arrayUsers != nil && dataUsers != nil {
                    if !selectUser!.isEquival(currentUser) {
                        let _ = dataUsers!.setCurrentUser(userName: selectUser!.userName)
                        moveOut()
                        if changeCurrentUser_postFunc != nil {
                            changeCurrentUser_postFunc!(false)
                        }
                    }
                } else {
                    moveOut()
                }
            } else {
                let ChangeUserVC_messageTitle = NSLocalizedString("ChangeUserVC_messageTitle", comment: "Заголовок окна пользователя")
                let alertController = UIAlertController(title: ChangeUserVC_messageTitle, message: nil, preferredStyle: .alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "Имя пользователя"
                    textField.text = self.selectUser!.userPrintName
                }
                let ChangeUserVC_messageOK = NSLocalizedString("ChangeUserVC_messageOK", comment: "Кнопка ОК")
                let ChangeUserVC_messageCancel = NSLocalizedString("ChangeUserVC_messageCancel", comment: "Отмена")
                let alertActionOk = UIAlertAction(title: ChangeUserVC_messageOK, style: .default) { (alert) in
                    let textField = alertController.textFields![0].text
                    self.renameSelectUser(name: textField!)
                }
                let alertActionCancel = UIAlertAction(title: ChangeUserVC_messageCancel, style: .default, handler: nil)
                alertController.addAction(alertActionOk)
                alertController.addAction(alertActionCancel)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if arrayUsers != nil {
            let from = arrayUsers![sourceIndexPath.row]
            arrayUsers!.remove(at: sourceIndexPath.row)
            arrayUsers!.insert(from, at: destinationIndexPath.row)
        }
    }
    
    @IBAction func enterMoveRow(_ sender: UIButton) {
        let currentEditing = usersTable.isEditing
        usersTable.setEditing(!currentEditing, animated: true)
        if currentEditing {
            var priorityArray = [String:Int]()
            for (index,element) in arrayUsers!.enumerated() {
                priorityArray[element.userName] = index
            }
            dataUsers?.setUsersPriority(userPriority: priorityArray)
        }
    }
    

    
}
