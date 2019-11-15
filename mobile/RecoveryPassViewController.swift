//
//  RecoveryPassViewController.swift
//  mobile
//
//  Created by Groylov on 30/10/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import UIKit

class RecoveryPassViewController: UIViewController {

    @IBOutlet weak var accountEditor: UITextField!
    @IBOutlet weak var recoveryMethod: UISegmentedControl!
    
    var accountLoginForm: String?
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    private func showMessageError(messageText mText: String) {
        let RecoveryPassVC_messageTitle = NSLocalizedString("RecoveryPassVC_messageTitle", comment: "Заголовок сообщений")
        let alertControll = UIAlertController(title: RecoveryPassVC_messageTitle, message: mText,preferredStyle: .alert)
        let RecoveryPassVC_messageButtonOkTitle = NSLocalizedString("RecoveryPassVC_messageButtonOkTitle", comment: "Заголовок кнопки ок")
        let alertButtonOk = UIAlertAction(title: RecoveryPassVC_messageButtonOkTitle, style: .default) { (alert) in
        }
        alertControll.addAction(alertButtonOk)
        present(alertControll,animated: true,completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationColor(self)
        self.hideKeyboard()
        if accountLoginForm != nil {
            accountEditor.text = accountLoginForm!
        }
    }
    
    // Нажатие на кнопку восстановления пароля
    @IBAction func recoveryTouch(_ sender: UIButton) {
        let accountNumber: String? = accountEditor.text
        // проверяем, что пользователь указал лицевой счет
        if accountNumber != nil && !accountNumber!.isEmpty {
            // запускаем анимацию загрузки
            view.backgroundColor = UIColor.white
            view.addSubview(activityIndicator)
            activityIndicator.frame = view.bounds
            activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
            activityIndicator.startAnimating()
            
            // обращаемся к бэку для сброса пароля
            let returnRecovery: BackOfficeMobileReturn = backOffice.recoveryAccountPassword(account: accountNumber!, method: recoveryMethod.selectedSegmentIndex)
            // останавливаем анимацию загрузки
            self.activityIndicator.stopAnimating()
            if !returnRecovery.isError() {
                // если пароль сброшен, то возвращаемся на начальный экран
                navigationController?.popViewController(animated: true)
            } else {
                // если ошибка восстановления пароля то выдаем ошибку пользователю и остаемся на текущем экране
                let errorText: String = returnRecovery.getErrorText()
                showMessageError(messageText: errorText)
            }
        } else {
            // если пользователь не указал лицевой - выводим сообщение об ошибке
            let RecoveryPassVC_errorEnterAccount = NSLocalizedString("RecoveryPassVC_errorEnterAccount", comment: "Не введен лицевой счет пользователем")
            showMessageError(messageText: RecoveryPassVC_errorEnterAccount)
        }
    }
}
