//
//  RegistrationViewController.swift
//  mobile
//
//  Created by Groylov on 30/10/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import UIKit
import SafariServices

class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var accountEdit: UITextField!
    @IBOutlet weak var accountRegion: UISegmentedControl!
    @IBOutlet weak var emailEdit: UITextField!
    @IBOutlet weak var phoneEdit: UITextField!
    @IBOutlet weak var consentLabel1: UILabel!
    @IBOutlet weak var consentLabel2: UILabel!
    @IBOutlet weak var consentSwitch1: UISwitch!
    @IBOutlet weak var consentSwitch2: UISwitch!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var constaintsButtonTop1: NSLayoutConstraint!
    @IBOutlet weak var verificationCodeEdit: UITextField!

    private var verificationActive: Bool = false
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    /// Функция проверки электронной почты на формат
    ///
    /// - Returns: Истина, если почта прошла проверку и Ложь, если проверка не пройдена
    private func checkEmailEdit() -> Bool {
        if emailEdit.text != nil {
            let emailText = emailEdit.text!
            
            if emailText.isEmpty {
                return false
            }
            
            // Проверка вхождения символов
            let checkCharacterSet = CharacterSet.init(charactersIn: "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm0123456789!#$%&'*+-/=?^_`{|}~@.").inverted
            let returnCheckCharacterSet = emailText.rangeOfCharacter(from: checkCharacterSet)
            if returnCheckCharacterSet != nil {
                return false
            }
            
            // Проверка вхождения @
            let dogCharacterSet = CharacterSet.init(charactersIn: "@")
            let returnDogCharacterSet = emailText.rangeOfCharacter(from: dogCharacterSet)
            if returnDogCharacterSet == nil {
                return false
            }
            
            // Проверка вхождения символа точки
            let pointSharacterSet = CharacterSet.init(charactersIn: ".")
            let returnPointCharacterSet = emailText.rangeOfCharacter(from: pointSharacterSet)
            if returnPointCharacterSet == nil {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    /// Функция активации режима ввода кода подтверждения
    ///
    /// - Parameter active: Истина - включение режима ввода, Ложь - выключение
    private func activationEnterVerification(_ active: Bool) {
        verificationActive = active
        if active {
            constaintsButtonTop1.constant = 46
        } else {
            constaintsButtonTop1.constant = 27
        }
        verificationCodeEdit.isHidden = !active
        accountEdit.isEnabled = !active
        accountRegion.isEnabled = !active
        emailEdit.isEnabled = !active
        phoneEdit.isEnabled = !active
        consentSwitch1.isEnabled = !active
        consentSwitch2.isEnabled = !active
    }
    
    /// Функция выполняемая после ответа сервера на регистрацию пользователя
    ///
    /// - Parameters:
    ///   - account: Номер лицевого счета
    ///   - db: Идентификатор региона
    ///   - email: Адрес электронной почты
    ///   - phone: Телефон
    ///   - returnBack: Возвращаемое значение от сервера
    func postRegistrationFunction(_ account: String, _ db: Int, _ email: String, _ phone: String, _ returnBack: BackOfficeMobileReturn) {
        if returnBack.isError() {
            if returnBack.getErrorCode() == 14 {
                backOffice.tamperErrorVersion()
            } else {
                let errorText = returnBack.getErrorText()
                showMessageError(view: self, name: "RegistrationVC", message: errorText)
            }
        } else {
            DispatchQueue.main.async {
                self.activationEnterVerification(true)
                self.view.setNeedsLayout()
            }
        }
    }
    
    /// Функция выполняемая после получения ответа от сервера на ввод пароля
    ///
    /// - Parameters:
    ///   - account: Номер лицевого счета
    ///   - code: Отправляемый код
    ///   - result: Результат с ответом сервера
    func postEnterCodeFunction(_ account: String, _ code: String, _ result: BackOfficeMobileReturn) {
        if result.isError() {
            DispatchQueue.main.sync {
                verificationCodeEdit.text = ""
            }
            if result.getErrorCode() == 4 {
                // не правильный код
                let VerificationCodeVС_errorSendCode = NSLocalizedString("VerificationCodeVС_errorSendCode", comment: "Введен не верный код")
                DispatchQueue.main.sync {
                    showMessageError(view: self, name: "VerificationCodeVС", message: VerificationCodeVС_errorSendCode)
                }
            } else {
                // другая ошибка
                let errorText = result.getErrorText()
                DispatchQueue.main.sync {
                    showMessageError(view: self, name: "RegistrationVC", message: errorText)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.activationEnterVerification(false)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func enterVerificationCode(code uCode: String) {
        let accountNumber = accountEdit.text
        if accountNumber != nil {
            verificationCodeEdit.text = ""
            let returnBack = backOffice.sendValidationCode(account: accountNumber!, code: uCode, function: postEnterCodeFunction)
            if returnBack.isError() {
                let errorText = returnBack.getErrorText()
                showMessageError(view: self, name: "VerificationCodeVС", message: errorText)
            }
        } else {
            let verificationCodeVС_errorAccount = NSLocalizedString("VerificationCodeVС_errorAccount", comment: "Ошибка определения лицевого счета")
            showMessageError(view: self, name: "VerificationCodeVС", message: verificationCodeVС_errorAccount)
        }
    }
        
    /// Функция обработки события создания формы
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationColor(self)
        registrationButton.isEnabled = false
        self.hideKeyboard()
        
        activationEnterVerification(false)
        // установка обработки ввода лицевого счета
        accountEdit.delegate = self
        accountEdit.addTarget(self, action: #selector(changeAccountText), for: .editingChanged)
        // установка обработки ввода телефона
        phoneEdit.delegate = self
        phoneEdit.addTarget(self, action: #selector(changePhoneText), for: .editingChanged)
        // установка обработки ввода проверочного кода
        verificationCodeEdit.delegate = self
        verificationCodeEdit.addTarget(self, action: #selector(changeVerificationText), for: .editingChanged)
        
        // устанавливаем обработку нажатия на надпись согласия с правилами регистрации
        let tachConsent1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.openConsent1(_:)))
        consentLabel1.isUserInteractionEnabled = true
        consentLabel1.addGestureRecognizer(tachConsent1)
        
        // устанавливаем обработку нажатия на надпись согласия с пользовательским соглашением
        let tachConsent2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.openConsent2(_:)))
        consentLabel2.isUserInteractionEnabled = true
        consentLabel2.addGestureRecognizer(tachConsent2)
    }
    
    /// Функция обработки события нажатия кнопки Регистрации
    @IBAction func registrationTouch(_ sender: Any) {
        if verificationActive {
            return
        }
        let accountText = accountEdit.text ?? ""
        let regionCode = accountRegion.selectedSegmentIndex
        let phoneText = phoneEdit.text ?? ""
        let emailText = emailEdit.text ?? ""
        let returnBackOffice = backOffice.registrationAccount(account: accountText, db: regionCode, email: emailText, phone: phoneText, function: postRegistrationFunction(_:_:_:_:_:))
        if returnBackOffice.isError() {
            let textError = returnBackOffice.getErrorText()
            showMessageError(view: self, name: "RegistrationVC", message: textError)
        } else {
            let textMessage = NSLocalizedString("LoginVC_enterCode", comment: "Ожидается ввод кода авторизации")
            showMessageError(view: self, name: "RegistrationVC", message: textMessage)
        }
    }
    
    /// Функция обработки события изменение данных для разблокировки кнопки регистрации
    @IBAction func chahgedTextAndConsent(_ sender: Any) {
        // Проверка первой отметки согласия
        if !consentSwitch1.isOn || !consentSwitch2.isOn  {
            registrationButton.isEnabled = false
            return
        }
        registrationButton.isEnabled = true
    }
    
    /// Функция обработки события изменения строки в поле лицевого счета
    @objc func changeAccountText(_ sender: UITextField) {
        let textString = accountEdit.text
        if textString != nil {
            accountEdit.text = setAccountOnFormat(account: textString!)
        }
    }
    
    /// Функция обработки события изменения строки в поле номера телефона
    @objc func changePhoneText(_ sender: UITextField) {
        let textString = phoneEdit.text
        if textString != nil {
            phoneEdit.text = setPhoneOnFormat(phone: textString!)
        }
    }
    
    /// Функция обработки события изменения строки в поле проверочного кода
    @objc func changeVerificationText(_ sender: UITextField) {
        let textString = verificationCodeEdit.text
        if textString != nil {
            let newTextString = textString!.filter("0123456789".contains)
            if newTextString.count == 6 {
                enterVerificationCode(code: newTextString)
            }
        }
    }
    
    /// Функция обработки события нажатия на правила регистрации
    @objc func openConsent1(_ sender: UITapGestureRecognizer) {
        // Правила регистрации
        let RegistrationVC_registerRulesFile = NSLocalizedString("RegistrationVC_registerRulesFile", comment: "Файл с правилами регистрации")
        let urlAdress = URL(string: RegistrationVC_registerRulesFile)
        if urlAdress != nil {
            if UIApplication.shared.canOpenURL(urlAdress!) {
                let safariVC = SFSafariViewController(url: urlAdress!)
                present(safariVC,animated: true,completion: nil)
            }
        }
    }
    
    /// Функция обработки события нажатия на пользовательское соглашение
    @objc func openConsent2(_ sender: UITapGestureRecognizer) {
        // Пользовательское соглашение
        let RegistrationVC_agreementFile = NSLocalizedString("RegistrationVC_agreementFile", comment: "Файл с пользовательским соглашением")
        let urlAdress = URL(string: RegistrationVC_agreementFile)
        if urlAdress != nil {
            if UIApplication.shared.canOpenURL(urlAdress!) {
                let safariVC = SFSafariViewController(url: urlAdress!)
                present(safariVC,animated: true,completion: nil)
            }
        }
    }
}
