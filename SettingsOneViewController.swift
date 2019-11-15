//
//  SettingsOneViewController.swift
//  mobile
//
//  Created by Groylov on 30/01/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class SettingsOneViewController: UIViewController {

    @IBOutlet weak var usePasswordLabel: UILabel!
    @IBOutlet weak var usePasswordSwitch: UISwitch!
    @IBOutlet weak var useTouchIDLabel: UILabel!
    @IBOutlet weak var useTouchIDSwitch: UISwitch!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    /// Использование биометрической авторизации
    private var useTouchID: Bool = false
    /// Использование пароля для входа
    private var usePassword: String? = nil
    /// Описание функции после завершение настроек
    var endSettingsFunction: (()->Void)? = nil
    
    /// Функция вывода пользователю сообщения об ошибке
    ///
    /// - Parameter mText: Текст сообщения об ошибки
    private func showMessageError(messageText mText: String) {
        let SettingsOneVC_messageTitle = NSLocalizedString("SettingsVC_messageTitle", comment: "Настройки")
        let SettingsOneVC_messageButtonOkTitle = NSLocalizedString("SettingsVC_messageButtonOkTitle", comment: "Ок")
        let alertControll = UIAlertController(title: SettingsOneVC_messageTitle, message: mText,preferredStyle: .alert)
        let alertButtonOk = UIAlertAction(title: SettingsOneVC_messageButtonOkTitle, style: .default) { (alert) in
        }
        alertControll.addAction(alertButtonOk)
        present(alertControll,animated: true,completion: nil)
    }
    
    /// Функция открытия основного рабочего окна и закрытия окна настроек
    private func openMainWorkVC() {
        dismiss(animated: true, completion: nil)
        if endSettingsFunction != nil {
            endSettingsFunction!()
        }
    }
    
    /// Функция открытия окна ввода пароля пользователя
    ///
    /// - Parameter accessUseTouchID: Использование биометрии для авторизации
    private func authEnterPassword(useTouchID accessUseTouchID: Bool) {
        if let enterPasswordVC = storyboard!.instantiateViewController(withIdentifier: "enterPasswordViewController") as? EnterPasswordViewController {
            enterPasswordVC.accessUseTouchID = accessUseTouchID
            enterPasswordVC.enterPasswordFunction = authEnterPasswordVC
            present(enterPasswordVC,animated: true,completion: nil)
        } else {
            let SettingsOneVC_errorOpenFormEntorPassword = NSLocalizedString("SettingsVC_errorOpenFormEntorPassword", comment: "Ошибка открытия окна авторизации")
            showMessageError(messageText: SettingsOneVC_errorOpenFormEntorPassword)
        }
    }
    
    /// Функция сохранения настроек пользователя
    private func saveSettingsUser() {
        if dataUsers != nil {
            if usePassword != nil {
                dataUsers!.setMobilePassword(userPassword: usePassword!)
            }
            dataUsers!.setUseTouchID(useTouchID: useTouchID)
        }
    }
        
    /// Функция обработки ответа от формы ввода пароля пользователя
    ///
    /// - Parameters:
    ///   - accessUserTouchID: Разрешено использование биометрической авторизации
    ///   - enterPassword: Введенный пароль
    ///   - authTouchID: Авторизация через биометрию
    func authEnterPasswordVC(_ accessUserTouchID: Bool, _ enterPassword: String, _ authTouchID: Bool) {
        if accessUserTouchID {
            useTouchID = authTouchID
            useTouchIDSwitch.isOn = useTouchID
        } else {
            if !enterPassword.isEmpty {
                usePassword = enterPassword
                usePasswordSwitch.isOn = true
            } else {
                usePassword = nil
                usePasswordSwitch.isOn = false
            }
        }
        saveSettingsUser()
    }
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// настройка дизайна ViewController
        setNavigationColor(self)
        
        // получение глобальной функции
        endSettingsFunction = functionOpenMainWorkVC
        
        // начальная установка настроек
        usePasswordSwitch.isOn = false
        changePasswordButton.isEnabled = false
        useTouchIDLabel.isEnabled = false
        useTouchIDSwitch.isEnabled = false
        
        // если доступно авторизация по биометрии, то надпись с переключателем делается видимым
        if authUser.getUseTouchID() {
            // в зависимости от типа биометрии, используемой на устройстве
            var useTouchIDCaptionName = ""
            if authUser.biometryTypeFaceID() {
                useTouchIDCaptionName = "SettingsVC_FaceID"
            } else {
                useTouchIDCaptionName = "SettingsVC_TouchID"
            }
            let useTouchIDCaptionText = NSLocalizedString(useTouchIDCaptionName, comment: "Надпись использования биометрии")
            useTouchIDLabel.text = useTouchIDCaptionText
            useTouchIDLabel.isHidden = false
            useTouchIDSwitch.isHidden = false
        } else {
            useTouchIDLabel.isHidden = true
            useTouchIDSwitch.isHidden = true
        }
    }
    
    /// Функция обработки события нажатия на кнопку изменения пароля авторизации
    @IBAction func changePasswordTouch(_ sender: Any) {
        authEnterPassword(useTouchID: false)
    }
    
    /// Функция обработки события изменения переключателя использования пароля
    @IBAction func usePasswordChanged(_ sender: Any) {
        tapticEngine()
        let usePasswordBool = usePasswordSwitch.isOn
        if usePasswordBool {
            changePasswordButton.isEnabled = true
            useTouchIDSwitch.isEnabled = true
            useTouchIDLabel.isEnabled = true
            authEnterPassword(useTouchID: false)
        } else {
            changePasswordButton.isEnabled = false
            useTouchIDSwitch.isEnabled = false
            useTouchIDLabel.isEnabled = false
            useTouchIDSwitch.isOn = false
            usePassword = nil
            useTouchID = false
        }
        saveSettingsUser()
    }
    
    /// Функция обработки события изменения переключателя использования биометрической авторизации
    @IBAction func useTouchIDChanged(_ sender: Any) {
        tapticEngine()
        authEnterPassword(useTouchID: true)
    }
    
    /// Функция обработки события нажатия на кнопку закрытия формы настроек
    @IBAction func closeButtonTouch(_ sender: Any) {
        saveSettingsUser()
        openMainWorkVC()
    }
    
}
