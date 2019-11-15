//
//  LoginViewController.swift
//  mobile
//
//  Created by Groylov on 25/10/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    @IBOutlet weak var infoPhoneNumber: UILabel!
    @IBOutlet weak var infoSiteAdress: UILabel!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var constaintUserNameBottom: NSLayoutConstraint!
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var labelAccountCHS: UILabel!
    
    /// Индикатор для отображения процесса загрузки
    private var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    /// Количество попыток пользователя ввести пароль
    private var countPasswordTry: Int = 0
    /// Переменная вызова функции пост обработки для случая, если ввод логина происходит не при первом запуске, а при добавление пользователя через меню списка пользователей
    var userListPostFunction: ((String,String,BackOfficeMobileReturn) -> Void)? = nil
    
    /// Функция открытия формы ввода пароля пользователя
    ///
    /// - Parameters:
    ///   - accessTouchID: Использование авторизации по биометрии
    ///   - messageUser: Текст сообщения пользователю при вводе пароля
    private func openEnterPasswordVC(_ accessTouchID: Bool,message messageUser: String? = nil) {
        if let enterPasswordVC = storyboard!.instantiateViewController(withIdentifier: "enterPasswordViewController") as? EnterPasswordViewController {
            enterPasswordVC.accessUseTouchID = accessTouchID
            enterPasswordVC.enterPasswordFunction = authEnterPasswordVC
            enterPasswordVC.messageEnterPassword = messageUser
            // если есть сообщение пользователю, то необходимо окрасить его в красный
            if messageUser != nil {
                enterPasswordVC.messageEnterPasswordColor = .red
            }
            present(enterPasswordVC,animated: true,completion: nil)
        } else {
            let LoginVC_errorOpenFormEntorPassword = NSLocalizedString("LoginVC_errorOpenFormEntorPassword", comment: "Ошибка открытия окна авторизации")
            showMessageError(view: self, name: "LoginVC", message: LoginVC_errorOpenFormEntorPassword)
        }
    }
    
    /// Функция авторизации пользователя в приложение
    private func autoAuth() {
        // подготавливаем анимацию процесса загрузки данных
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        view.backgroundColor = UIColor.white
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        // получаем данные с хранилища и выводим статус загрузки
        activityIndicator.startAnimating()
        dataUsers = DataUsers()
        activityIndicator.stopAnimating()
        
        // проверяем авторизацию пользователя
        // если пользователь есть и у него включена защита паролем, то проверяется включена биометрическая защита или по вводу пароля. И в соответствие с настройками производится авторизация пользователя
        if dataUsers != nil {
            if dataUsers!.checkUsers() {
                if dataUsers!.getUseTouchID() {
                    // авторизация по TouchID
                    openEnterPasswordVC(true)
                } else if dataUsers!.getUsePassword() {
                    // авторизация по паролю
                    openEnterPasswordVC(false)
                } else {
                    // нет авторизации в приложение
                    openMainWorkVC()
                }
            }
        }
    }

    /// Функция вызываемая после ввода пароля пользователя
    ///
    /// - Parameters:
    ///   - accessUserTouchID: Флаг разрешения использования авторизации по биометрии
    ///   - enterPassword: Введенный пользователем пароль
    ///   - authTouchID: Флаг авторизации пользователя биометрически
    func authEnterPasswordVC(_ accessUserTouchID: Bool, _ enterPassword: String, _ authTouchID: Bool) {
        // если пользователь авторизовался через биометрию, то сразу открываем основное окно, если пользователь ввел пароль, то пароль сравнивается с данными в настройках пользователя и если пароль не совпадает, то выводится сообщение пользователю о не верном пароле и снова открывается форма ввода пароля
        if authTouchID {
            DispatchQueue.main.sync {
                openMainWorkVC()
            }
        } else if !enterPassword.isEmpty {
            if dataUsers != nil {
                let accessPassword = dataUsers!.authCurrentUserPassword(userPassword: enterPassword)
                if accessPassword {
                    openMainWorkVC()
                } else {
                    countPasswordTry += 1
                    // если пользователь ввел неверный пароль 3 раза, то сообщаем пользователю, что если еще раз он введет пароль не верно, то авторизация будет сброшена
                    if countPasswordTry > 3 {
                        return
                    } else if countPasswordTry == 3 {
                        let LoginVC_errorEnterPassword3 = NSLocalizedString("LoginVC_errorEnterPassword3", comment: "Не верный пароль 3 раза")
                        openEnterPasswordVC(accessUserTouchID,message: LoginVC_errorEnterPassword3)
                        return
                    } else {
                        let LoginVC_errorEnterPassword = NSLocalizedString("LoginVC_errorEnterPassword", comment: "Не верный пароль")
                        openEnterPasswordVC(accessUserTouchID,message: LoginVC_errorEnterPassword)
                        return
                    }
                }
            } else {
                let LoginVC_errorAuthUsers = NSLocalizedString("LoginVC_errorAuthUsers", comment: "Ошибка авторизации приложения")
                showMessageError(view: self, name: "LoginVC", message: LoginVC_errorAuthUsers)
            }
        }
    }
    
    /// Функция открытия основного рабочего окна приложения
    func openMainWorkVC() {
        if let mainWorkViewController = storyboard!.instantiateViewController(withIdentifier: "mainTabBarController") as? MainTabBarController {
            present(mainWorkViewController,animated: true,completion: nil)
        } else {
            let SettingsOneVC_errorOpenMainVC = NSLocalizedString("SettingsOneVC_errorOpenMainVC", comment: "Ошибка открытия основного окна")
            showMessageError(view: self, name: "SettingsOneVC", message: SettingsOneVC_errorOpenMainVC)
        }
    }
    
    /// Функция вызова после авторизации пользователя на бэк офисе
    ///
    /// - Parameters:
    ///   - aNumber: Номер лицевого счета
    ///   - aPassword: Введенный пользователем пароль
    ///   - returnFunc: Результат выполнения функции на бэк офисе
    func authSingInTouch_postFunc(account aNumber: String, password aPassword: String, result returnFunc: BackOfficeMobileReturn) {
        DispatchQueue.main.sync {
            activityIndicator.stopAnimating()
        }
        if !returnFunc.isError() {
            let userTokenBack = returnFunc.getReturnData()
            // если бэк вернул нам токен пользователя, то очищается вся база пользователей и считаем, что это первый запуск
            if userTokenBack != nil {
                if dataUsers != nil {
                    // очищаем всех пользователей и добавляем нового
                    dataUsers!.removeAllUsers()
                    dataUsers!.addUser(userName: aNumber, userToken: userTokenBack as? String ?? "", userPriority: 1)
                    let resultSetCurrent = dataUsers!.setCurrentUser(userName: aNumber)
                    if resultSetCurrent {
                        // открывается форма настроек первого запуска
                        if let navigationSettingsVC = storyboard!.instantiateViewController(withIdentifier: "navigationSettingsOneViewController") as? UINavigationController {
                            functionOpenMainWorkVC = openMainWorkVC
                            DispatchQueue.main.sync {
                                self.present(navigationSettingsVC,animated: true,completion: nil)
                            }
                        }
                    }
                }
            }
            let LoginVC_errorCreateAccount = NSLocalizedString("LoginVC_errorCreateAccount", comment: "Ошибка создания пользователя")
            DispatchQueue.main.sync {
                showMessageError(view: self, name: "LoginVC", message: LoginVC_errorCreateAccount)
            }
        } else {
            let errorText = returnFunc.getErrorText()
            DispatchQueue.main.sync {
                showMessageError(view: self, name: "LoginVC", message: errorText)
            }
        }
        
    }
    
    /// Функция обработки события открытия окна
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationLogin = self.navigationController as? LoginNavigationViewController
        if navigationLogin != nil {
            userListPostFunction = navigationLogin!.userListPostFunction
            if navigationLogin!.activityIndicator != nil {
                self.activityIndicator = navigationLogin!.activityIndicator!
            }
        }
        self.hideKeyboard()
        
        cancelButton.isHidden = userListPostFunction == nil
        labelWelcome.isHidden = !(userListPostFunction == nil)
        labelAccountCHS.isHidden = !(userListPostFunction == nil)
        
        if userListPostFunction == nil {
            constaintUserNameBottom.constant = 86
        } else {
            constaintUserNameBottom.constant = 19
        }

        
        // if userListPostFunction == nil {
        //     userNameField.text = "1038928375"
        // } else {
        //     userNameField.text = "1039597165"
        // }
        //userNameField.text = "010416360"
        // userPasswordField.text = "Skotobaza357"
        //dataUsers?.removeAllUsers()
        
        setNavigationColor(self)
        
        let butImage = UIImage(named: "MainVC_showPassword")
        if butImage != nil {
            showPasswordButton.setImage(butImage?.maskWithColor(color: .gray), for: .normal)
        }
                
        // устанавливаем обработку нажатия на надпись с телефоном
        let tachPhoneNumber: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.callPhoneNumber(_:)))
        infoPhoneNumber.isUserInteractionEnabled = true
        infoPhoneNumber.addGestureRecognizer(tachPhoneNumber)
        
        // устанавливаем обработку нажатия на надпись с сайтом
        let tachSiteAdress: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.openSiteBrowser(_:)))
        infoSiteAdress.isUserInteractionEnabled = true
        infoSiteAdress.addGestureRecognizer(tachSiteAdress)
        // если форма открыта не из списка добавления пользователей то пробуем произвести авторизацию в приложение
        if userListPostFunction == nil {
            autoAuth()
        }
    }
    
    /// Передача параметров в другие формы
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdent = segue.destination.restorationIdentifier {
            // передача параметров в форму восстановления пароля
            if segueIdent == "recoveryPassViewController" {
                let recoveryForm = segue.destination as! RecoveryPassViewController
                recoveryForm.accountLoginForm = userNameField.text
            }
        }
    }
    
    /// Функция обработки события нажатия кнопки входа в систему
    @IBAction func authSingInTouch(_ sender: UIButton) {
        let fromAccount = userNameField.text
        let fromPassword = userPasswordField.text
        
        if fromAccount != nil && fromPassword != nil {
            // проверка поля Лицевой счет
            if fromAccount!.isEmpty {
                let LoginVC_errorEnterAccountEdit = NSLocalizedString("LoginVC_errorEnterAccountEdit", comment: "Не введен лицевой счет")
                showMessageError(view: self, name: "LoginVC", message: LoginVC_errorEnterAccountEdit)
                return
            }
            // проверка поля Пароль
            if fromPassword!.isEmpty {
                let LoginVC_errorEnterPasswordEdit = NSLocalizedString("LoginVC_errorEnterPasswordEdit", comment: "Не введен пароль")
                showMessageError(view: self, name: "LoginVC", message: LoginVC_errorEnterPasswordEdit)
                return
            }
            //view.backgroundColor = UIColor.black
            view.addSubview(activityIndicator)
            activityIndicator.frame = view.bounds
            activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
            // показываем анимацию загрузки
            activityIndicator.startAnimating()
            // подключаемся к бэку и авторизуемся
            var returnSingIn: BackOfficeMobileReturn
            if userListPostFunction != nil {
                returnSingIn = backOffice.authAccount(account: fromAccount!, password: fromPassword!,function: userListPostFunction!)
            } else {
                returnSingIn = backOffice.authAccount(account: fromAccount!, password: fromPassword!,function: self.authSingInTouch_postFunc(account:password:result:))
            }

            if returnSingIn.isError() {
                activityIndicator.stopAnimating()
                let errorText = returnSingIn.getErrorText()
                showMessageError(view: self, name: "LoginVC", message: errorText)
            }
        } else {
            let LoginVC_errorReadAccountPassword = NSLocalizedString("LoginVC_errorReadAccountPassword", comment: "Ошибка чтения данных о логине и пароле с формы")
            showMessageError(view: self, name: "LoginVC", message: LoginVC_errorReadAccountPassword)
        }
    }

    @IBAction func showPasswordTouch(_ sender: Any) {
        var butImage: UIImage?
        if userPasswordField.isSecureTextEntry {
            userPasswordField.isSecureTextEntry = false
            butImage = UIImage(named: "MainVC_hidePassword")
        } else {
            userPasswordField.isSecureTextEntry = true
            butImage = UIImage(named: "MainVC_showPassword")
        }
        if butImage != nil {
            showPasswordButton.setImage(butImage?.maskWithColor(color: .gray), for: .normal)
        }
    }
    
    /// Функция набора номера при нажатие на надпись с телефоном
    @objc func callPhoneNumber(_ sender: UITapGestureRecognizer) {
        let LoginVC_phoneCallNumber = NSLocalizedString("LoginVC_phoneCallNumber", comment: "Телефон для вызова")
        let nsurlPhone = NSURL(string: LoginVC_phoneCallNumber)
        if nsurlPhone != nil {
            let urlPhone = nsurlPhone!.absoluteURL
            if urlPhone != nil {
                if UIApplication.shared.canOpenURL(urlPhone!) {
                    UIApplication.shared.open(urlPhone!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    /// Функция открытия сайта организации при нажатие на надпись с сайтом
    @objc func openSiteBrowser(_ sender: UITapGestureRecognizer) {
        let LoginVC_siteOpenAdress = NSLocalizedString("LoginVC_siteOpenAdress", comment: "Адрес окрываемого сайта")
        let urlAdress = URL(string: LoginVC_siteOpenAdress)
        if urlAdress != nil {
            if UIApplication.shared.canOpenURL(urlAdress!) {
                let safariVC = SFSafariViewController(url: urlAdress!)
                present(safariVC,animated: true,completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTouch(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

/// Описание функции открытия основной формы приложения
var functionOpenMainWorkVC: (()->Void)?
