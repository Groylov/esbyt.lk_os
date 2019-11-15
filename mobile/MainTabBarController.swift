//
//  MainTabBarController.swift
//  mobile
//
//  Created by Groylov on 05/02/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    /// Использование визуализаци загрузки данных
    private var useVisualLoadData: Bool = true
    /// Текущий лицевой счет
    private var currentAccount: String?
    /// Текщий токен
    private var currentToken: String?
    /// Переменная потока для загрузки данных
    private let dispatchBackLoadDataAccount = DispatchQueue(label: "dispatch.back.loadDataAccount")
    /// Индикатор визуального отображения загрузки
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    /// Функция вывода пользователю сообщения
    ///
    /// - Parameter mText: Текст сообщения
    private func showMessageError(messageText mText: String) {
        let LoginVC_messageTitle = NSLocalizedString("MainTabBarC_messageTitle", comment: "Читаэнергосбыт")
        let LoginVC_messageButtonOkTitle = NSLocalizedString("MainTabBarC_messageButtonOkTitle", comment: "Ок")
        let alertControll = UIAlertController(title: LoginVC_messageTitle, message: mText,preferredStyle: .alert)
        let alertButtonOk = UIAlertAction(title: LoginVC_messageButtonOkTitle, style: .default) { (alert) in
        }
        alertControll.addAction(alertButtonOk)
        DispatchQueue.main.sync {
            self.present(alertControll,animated: true,completion: nil)
        }
    }
    
    /// Функция вызова получения данных с бэка
    ///
    /// - Parameters:
    ///   - nAccount: Номер лицевого счета
    ///   - nToken: Токен лиевого счета
    private func getDataAccountBack(account nAccount: String, token nToken: String) {
        let returnFullData = backOffice.getFullDataAccount(account: nAccount, token: nToken, function:
            self.getDataAccountBack_postFunc)
        if returnFullData.isError() {
            let errorText = returnFullData.getErrorText()
            self.showMessageError(messageText: errorText)
            useVisualLoadData = false
        }
        NotificationCenter.default.post(name: MainWorkVC_refreshVisualData, object: nil)
    }
    
    /// Функция последующей обработки получения данных с бэка
    ///
    /// - Parameters:
    ///   - nAccount: Номер лицевого счета
    ///   - nToken: Токен лицевого счета
    ///   - returnFunc: Результат запроса к бэк офису
    func getDataAccountBack_postFunc(_ nAccount: String, _ nToken: String, _ returnFunc: BackOfficeMobileReturn) {
        if returnFunc.isError() {
            let returnErrorCode = returnFunc.getErrorCode()
            if returnErrorCode == 6 {
                // TODO: Ошибка пароля пользователя - необходима повторная авторизация
            } else {
                if useVisualLoadData {
                    let errorText = returnFunc.getErrorText()
                    showMessageError(messageText: errorText)
                }
            }
        } else {
            DispatchQueue.main.sync {
                self.activityIndicator.stopAnimating()
            }
        }
        NotificationCenter.default.post(name: MainWorkVC_refreshVisualData, object: nil)
    }
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        if dataUsers != nil {
            let currentUser = dataUsers!.getCurrentUser()
            if currentUser != nil {
                // получаем текущей номер лс и токен
                currentAccount = currentUser!.userName
                currentToken = currentUser!.userToken
                //формируем имя файла
                let dataFileNameString = "data_" + currentAccount! + ".json"
                let dataFileName = backOffice.getApplicationDirectory(fileName: dataFileNameString)
                dataAccount = DataAccounts()
                // если файл существует, то загружаем данные из него
                useVisualLoadData = false
                if dataFileName != nil {
                    let existsFileData = dataAccount.existsFileLoadDataAccount(file: dataFileName!)
                    if existsFileData {
                        let returnLoadData = dataAccount.loadDataAccount(file: dataFileName!)
                        if !returnLoadData {
                            useVisualLoadData = true
                        }
                    } else {
                        useVisualLoadData = true
                    }
                } else {
                    useVisualLoadData = true
                }
                if !useVisualLoadData {
                    dispatchBackLoadDataAccount.async {
                        self.getDataAccountBack(account: self.currentAccount!, token: self.currentToken!)
                    }
                } else {
                    self.getDataAccountBack(account: self.currentAccount!, token: self.currentToken!)
                }
            } else {
                let mainTabBarC_ErrorCurrenAccount = NSLocalizedString("MainTabBarC_ErrorCurrenAccount", comment: "Ошибка получения текущего пользователя")
                showMessageError(messageText: mainTabBarC_ErrorCurrenAccount)
            }
        } else {
            let mainTabBarC_ErrorReadDataUsers = NSLocalizedString("MainTabBarC_ErrorReadDataUsers", comment: "Ошибка получения настроек пользователей системы")
            showMessageError(messageText: mainTabBarC_ErrorReadDataUsers)
        }
    }
    
    /// Функция обработки события визуального открытия окна
    override func viewDidAppear(_ animated: Bool) {
        // проверяем что необходимо обновить информацию с визуализацией
        if useVisualLoadData {
            if currentAccount != nil && currentToken != nil {
                // подготавливаем анимацию процесса загрузки данных
                view.backgroundColor = UIColor.black
                view.addSubview(activityIndicator)
                activityIndicator.frame = view.bounds
                activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
                // показываем анимацию загрузки
                activityIndicator.startAnimating()
                // загружаем данные с бэка
                getDataAccountBack(account: currentAccount!, token: currentToken!)
            }
        }
    }
}
