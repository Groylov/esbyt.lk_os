//
//  SettingsViewController.swift
//  mobile
//
//  Created by Groylov on 05/02/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController {

    @IBOutlet weak var usePasswordLabel: UILabel!
    @IBOutlet weak var usePasswordSwitch: UISwitch!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var useTouchIDLabel: UILabel!
    @IBOutlet weak var useTouchIDSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    private var usePassword: String? = nil
    
    /// Функция вывода сообщения пользователю
    ///
    /// - Parameter mText: Текст сообщения
    private func showMessageError(messageText mText: String) {
        let SettingsOneVC_messageTitle = NSLocalizedString("SettingsVC_messageTitle", comment: "Настройки")
        let SettingsOneVC_messageButtonOkTitle = NSLocalizedString("SettingsVC_messageButtonOkTitle", comment: "Ок")
        let alertControll = UIAlertController(title: SettingsOneVC_messageTitle, message: mText,preferredStyle: .alert)
        let alertButtonOk = UIAlertAction(title: SettingsOneVC_messageButtonOkTitle, style: .default) { (alert) in
        }
        alertControll.addAction(alertButtonOk)
        present(alertControll,animated: true,completion: nil)
    }
    
    /// Функция открытия окна ввода пароля пользователя
    ///
    /// - Parameter
    ///   - accessUseTouchID: Разрешение на авторизацию биометрическим методом
    ///   - postFunction: Функция выполняемая после работы формы ввода пароля
    private func authEnterPassword(useTouchID accessUseTouchID: Bool, function postFunction: @escaping ((Bool,String,Bool) -> Void)) {
        if let enterPasswordVC = storyboard!.instantiateViewController(withIdentifier: "enterPasswordViewController") as? EnterPasswordViewController {
            enterPasswordVC.accessUseTouchID = accessUseTouchID
            enterPasswordVC.enterPasswordFunction = postFunction
            present(enterPasswordVC,animated: true,completion: nil)
        } else {
            let SettingsOneVC_errorOpenFormEntorPassword = NSLocalizedString("SettingsVC_errorOpenFormEntorPassword", comment: "Ошибка открытия окна авторизации")
            showMessageError(messageText: SettingsOneVC_errorOpenFormEntorPassword)
        }
    }
    
    /// Функция сохранения настроек пользователя
    private func saveSettingsUser() {
        if dataUsers != nil {
            dataUsers!.setMobilePassword(userPassword: usePassword)
            dataUsers!.setUseTouchID(useTouchID: useTouchIDSwitch.isOn)
        }
    }
    
    /// Функция обработки ответа от формы ввода пароля пользователя
    ///
    /// - Parameters:
    ///   - accessUsertTouchID: Разрешение на использование биометрической авторизации
    ///   - enterPassword: Введенный пользователем пароль
    ///   - authTouchID: Авторизация была пройдена биометрическим методом
    func authEnterPasswordVC(_ accessUsertTouchID: Bool, _ enterPassword: String, _ authTouchID: Bool) {
        if accessUsertTouchID {
            useTouchIDSwitch.isOn = authTouchID
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
    
    /// Функция обработки ответа от формы ввода пароля пользователя при смене пароля
    ///
    /// - Parameters:
    ///   - accessUsertTouchID: Разрешение на использование биометрической авторизации
    ///   - enterPassword: Введенный пользователем пароль
    ///   - authTouchID: Авторизация была пройдена биометрическим методом
    func authEnterPasswordChangeVC(_ accessUsertTouchID: Bool, _ enterPassword: String, _ authTouchID: Bool) {
        if !enterPassword.isEmpty {
            usePassword = enterPassword
        }
    }
    
    /// Функция обработки ответа от формы ввода пароля пользователя
    ///
    /// - Parameters:
    ///   - accessUsertTouchID: Разрешение на использование биометрической авторизации
    ///   - enterPassword: Введенный пользователем пароль
    ///   - authTouchID: Авторизация была пройдена биометрическим методом
    func authEnterPasswordVCOff(_ accessUsertTouchID: Bool, _ enterPassword: String, _ authTouchID: Bool) {
        if accessUsertTouchID {
            if authTouchID {
                useTouchIDSwitch.isOn = false
            }
        }
        saveSettingsUser()
    }
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// настройка дизайна ViewController
        setNavigationColor(self)
        
        // получение и вывод версии приложения
        let version = readVersionBundleString()
        let bundle = readVersionBundle()
        if version != nil && bundle != nil {
            versionLabel.isHidden = false
            versionLabel.text = "Версия \(version!) (Сборка \(bundle!))"
        } else {
            versionLabel.isHidden = true
        }
        
        var dataUsers_usePassword: Bool
        var dataUsers_useTouchID: Bool
        
        // загрузка настроек пользователя
        if dataUsers != nil {
            dataUsers_usePassword = dataUsers!.getUsePassword()
            dataUsers_useTouchID = dataUsers!.getUseTouchID()
            usePassword = dataUsers!.getMobilePassword()
        } else {
            dataUsers_usePassword = false
            dataUsers_useTouchID = false
            usePassword = nil
        }
        
        // установка полей в соответствие с настройками
        usePasswordSwitch.isOn = dataUsers_usePassword
        changePasswordButton.isEnabled = dataUsers_usePassword
        useTouchIDLabel.isEnabled = dataUsers_usePassword
        useTouchIDSwitch.isEnabled = dataUsers_usePassword
        
        // установка названия поля в зависимости от доступного типа биометрической авторизации
        if authUser.getUseTouchID() {
            var useTouchIDCaptionName = ""
            if authUser.biometryTypeFaceID() {
                useTouchIDCaptionName = "SettingsVC_FaceID"
            } else {
                useTouchIDCaptionName = "SettingsVC_TouchID"
            }
            let useTouchIDCaptionText = NSLocalizedString(useTouchIDCaptionName, comment: "Надпись использования биометрии")
            useTouchIDLabel.text = useTouchIDCaptionText
            useTouchIDSwitch.isOn = dataUsers_useTouchID
        } else {
            useTouchIDLabel.isHidden = true
            useTouchIDSwitch.isHidden = true
        }
    }
    
    /// функция обработки события изменения установки пароля
    @IBAction func usePasswordSwitchTouch(_ sender: Any) {
        let usePasswordSwitch_let = usePasswordSwitch.isOn
        if usePasswordSwitch_let {
            // включено использование пароля
            changePasswordButton.isEnabled = true
            useTouchIDSwitch.isEnabled = true
            useTouchIDLabel.isEnabled = true
            authEnterPassword(useTouchID: false, function: authEnterPasswordVC)
        } else {
            // отключено использование пароля
            changePasswordButton.isEnabled = false
            useTouchIDSwitch.isEnabled = false
            useTouchIDLabel.isEnabled = false
            useTouchIDSwitch.isOn = false
            usePassword = nil
        }
        saveSettingsUser()
    }
    
    // функция обработки события изменения использования TouchID
    @IBAction func useTouchIDSwitchTouch(_ sender: Any) {
        if useTouchIDSwitch.isOn {
            authEnterPassword(useTouchID: true,function: authEnterPasswordVC)
        } else {
            authEnterPassword(useTouchID: true,function: authEnterPasswordVCOff)
        }
    }
    
    // функция обработки события нажатия на изменение пароля
    @IBAction func changePasswordTouch(_ sender: Any) {
        authEnterPassword(useTouchID: false,function: authEnterPasswordChangeVC)
    }
    
    // функция открытия почтового клиента для отправки письма
    private func openMailNetworkUrl(mail eMail: String) {
        let schemeUrl = NSURL(string: eMail) as URL?
        if schemeUrl != nil {
            if UIApplication.shared.canOpenURL(schemeUrl!) {
                UIApplication.shared.open(schemeUrl!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func sendDeveloperTouch(_ sender: Any) {
        openMailNetworkUrl(mail: "mailto:ios@e-sbyt.ru")
    }
}
