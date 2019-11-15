//
//  BackOfficeManager.swift
//  mobile
//
//  Created by Groylov on 30/10/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import Foundation
import CommonCrypto

/// Cтруктура хранения данных об ошибках полученных с сервера
struct JsonServerError {
    /// Код ошибки
    var errorCode: Int
    /// Сообщение ошибки
    var errorMessage: String
    /// Флаг ошибки на стороне сервере
    var errorServer: Bool
    
    /// Инициализация класса через данные
    ///
    /// - Parameters:
    ///   - eCode: Код ошибки
    ///   - eMessage: Сообщение ошибки
    ///   - eServer: Флаг ошибки сервера
    init(code eCode: Int, message eMessage: String, server eServer: Bool) {
        errorCode = eCode
        errorMessage = eMessage
        errorServer = eServer
    }
    
    /// Инициализация класса через ошибку
    ///
    /// - Parameters:
    ///   - eCode: Код ошибки
    ///   - eServer: Флаг ошибки сервера
    init(code eCode: Int, server eServer: Bool) {
        errorCode = eCode
        errorMessage = ""
        errorServer = eServer
    }
    
    /// Функция чтения наличие ошибки в результате
    ///
    /// - Returns: Истина, если ошибка есть
    func isError() -> Bool {
        return errorCode != 0
    }
    
    /// Функция чтения наличие ошибки сервера
    ///
    /// - Returns: Истина, если ошибка пришла с сервера
    func isErrorServer() -> Bool {
        return errorServer
    }
}

/// Класс результата выполнения запроса к бэк оффису
class BackOfficeMobileReturn {
    
    /// Код ошибки
    private var errorCode: Int
    /// Текст ошибки
    private var errorText: String
    /// Результат возврата сервера
    private var returnData: Any?
    
    /// Инициализация класса через код ошибки и данные
    init(errorCode eCode: Int, data eData: Any?) {
        errorCode = eCode
        let dictionaryName = "BackOfficeMobileReturnErrorCode_" + String(errorCode)
        let eText = NSLocalizedString(dictionaryName, comment: "Строка ошибки")
        errorText = eText
        returnData = eData
    }
    
    /// Инициализация класса через код, текст ошибки и данные
    init(errorCode eCode: Int, errorText eText: String, data eData: Any?) {
        errorCode = eCode
        errorText = eText
        returnData = eData
    }
    
    /// Функция проверки наличия ошибок в результате
    ///
    /// - Returns: Истина, если ошибки есть. Ложь в случае отсутствия ошибок
    func isError() -> Bool {
        return errorCode != 0
    }

    /// Функция получения кода ошибки
    ///
    /// - Returns: Код ошибки
    func getErrorCode() -> Int {
        return errorCode
    }
    
    /// Функция получения текста ошибки
    ///
    /// - Returns: Текст ошибки
    func getErrorText() -> String {
        return errorText
    }
    
    /// Функция проверки наличия результатов выполнения запроса
    ///
    /// - Returns: Истина, если результат есть и Ложь в случае отсутствия результата с бэк оффиса
    func isReturnData() -> Bool {
        return returnData != nil
    }

    /// Функция получения данных результата выполнения запроса
    ///
    /// - Returns: Данные, которые вернул бэк оффис
    func getReturnData() -> Any? {
        return returnData
    }
}

/// Класс работы с бэк оффисом приложения
class BackOfficeMobile {

    /// Функция получения ссылки файла в директории приложения
    ///
    /// - Parameter fName: Имя файла в директории
    /// - Returns: Ссылка на файл в директории приложения
    func getApplicationDirectory(fileName fName: String) -> URL? {
        let patch = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/" + fName
        let urlPatch = URL(fileURLWithPath: patch)
        return urlPatch
    }
    
    /// Функция получения основных параметров запроса
    ///
    /// - Returns: Формат ответа и версия приложения
    private func addParamRequired() -> String {
        let version = readVersionBundle() ?? "0"
        let returnString = "iversion="+version
        return returnString
    }
    
    /// Функция обработки ошибки криточно устаревшей версии
    func tamperErrorVersion() {
        
    }
    
    /// Функция получения результата от сервера на запрос авторизации
    ///
    /// - Parameter fileName: Имя файла для чтения данных
    /// - Returns: Полученные от сервера данные
    private func readJsonAuthAccount(file fileName: URL) -> String? {
        // получение данных из файла
        guard let data = try? Data(contentsOf: fileName) else {
            return nil
        }
        
        // получаем словарь
        guard let rootDictionaryAny = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return nil
        }
        // получаем основной словарь
        guard let rootDictionary = rootDictionaryAny as? Dictionary<String,Any> else {
            return nil
        }
        
        // чтения данных в словаре token
        let tokenData = rootDictionary["token"] as? String
        return tokenData
    }

    /// Функция получения результата от сервара на запрос добавления оплаты
    ///
    /// - Parameter fileName: Имя файла для чтения данных
    /// - Returns: Полученный от сервера ответ
    private func readJsonNewPayment(file fileName: URL) -> String? {
        // получение данных из файла
        guard let data = try? Data(contentsOf: fileName) else {
            return nil
        }
        
        // получаем словарь
        guard let rootDictionaryAny = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return nil
        }
        // получаем основной словарь
        guard let rootDictionary = rootDictionaryAny as? Dictionary<String,Any> else {
            return nil
        }
        
        // чтения данных в словаре formUrl
        let tokenData = rootDictionary["formUrl"] as? String
        return tokenData
    }

    /// Функция проверка ответа пользователя на наличие ошибок
    ///
    /// - Parameter fileName: Имя файла для чтения
    /// - Returns: Описание ошибки при наличие
    private func readJsonForError(file fileName: URL) -> JsonServerError {
        // получаем данные из файла обработки
        guard let data = try? Data(contentsOf: fileName) else {
            let errorResult = JsonServerError(code: 5,  server: false)
            return errorResult
        }
        // получаем словарь
        guard let rootDictionaryAny = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            let errorResult = JsonServerError(code: 6, server: false)
            return errorResult
        }
        // получаем основной словарь
        guard let rootDictionary = rootDictionaryAny as? Dictionary<String,Any> else {
            let errorResult = JsonServerError(code: 7, server: false)
            return errorResult
        }
        // чтения данных в словаре error
        let errorDictionary = rootDictionary["error"] as? Dictionary<String,Any>
        if errorDictionary != nil {
            let errorText = errorDictionary!["message"] as? String ?? ""
            let errorCode = errorDictionary!["code"] as? Int ?? 1
            let returnError = JsonServerError(code: errorCode, message: errorText, server: true)
            return returnError
        } else {
            let returnData = JsonServerError(code: 0, server: false)
            return returnData
        }
    }

    /// Функция сброса пароля пользователя
    ///
    /// - Parameters:
    ///   - aNumber: Лицевой счет
    ///   - aMethod: Метод восстановления пароля (true-Телефон,false-Почта)
    /// - Returns: Результат выполнения запроса на сервер
    func recoveryAccountPassword(account aNumber: String,method aMethod: Int) -> BackOfficeMobileReturn {
        // TODO: Сделать запрос к бэку на сброс пароля
        print("TODO - Выполнился запрос к серверу на восстановление пароля")
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }

    /// Функция авторизации пользователя по логину и паролю
    ///
    /// - Parameters:
    ///   - aNumber: Лицевой счет
    ///   - aPassword: Пароль от учетной записи
    ///   - postFunc: Функция, выполняемая после запроса бэк
    /// - Returns: Результат запроса на бэк офис
    func authAccount(account aNumber: String, password aPassword: String, function postFunc: @escaping ((String,String,BackOfficeMobileReturn) -> Void)) -> BackOfficeMobileReturn {
        
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString("BackOffice_authAccount_url", comment: "URL запроса для авторизации пользователя")
        guard let url = URL(string: urlString) else {
            let returnErrorData1 = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData1
        }
        
        // формируем хэш код пароля пользователя
        let passwordHash = aPassword
        
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // формируется и устанавливаются параметры для запроса к серверу
        let postParams = "format=json&account="+aNumber+"&hash="+passwordHash
        request.httpBody = postParams.data(using: .utf8)
        
        // получение данных с сервера
        let session = URLSession(configuration: .default)
        
        let downloadTask = session.downloadTask(with: request) {  (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "authUser_" + aNumber + ".json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)
                    
                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(aNumber,aPassword,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(aNumber,aPassword,returnErrorResult)
                        }
                        return
                    } else {
                        let tokenData = self.readJsonAuthAccount(file: urlToData!)
                        if tokenData != nil {
                            let returnData = BackOfficeMobileReturn(errorCode: 0, data: tokenData)
                            postFunc(aNumber,aPassword,returnData)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: 8, data: nil)
                            postFunc(aNumber,aPassword,returnErrorResult)
                        }
                    }
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(aNumber,aPassword,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(aNumber,aPassword,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }
    
    /// Функция регистрации нового пользователя
    ///
    /// - Parameters:
    ///   - aNumber: Номер лицевого счета
    ///   - nDB: Код подразделения
    ///   - aEmail: Адрес электронной почты
    ///   - aPhone: Телефон абонента
    /// - Returns: Результат запроса на бэк офис
    func registrationAccount(account aNumber: String, db nDB: Int, email aEmail: String, phone aPhone: String, function postFunc: @escaping ((String,Int,String,String,BackOfficeMobileReturn) -> Void)) -> BackOfficeMobileReturn {
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString("BackOffice_registration_url", comment: "URL запроса для регистрации пользователя")
        guard let url = URL(string: urlString) else {
            let returnErrorData1 = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData1
        }
        
        // определение базы данных для создания лицевого
        var dbName: String
        if nDB == 0 {
            dbName = "ches"
        } else {
            dbName = "bur"
        }
      
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // формируется и устанавливаются параметры для запроса к серверу
        var postParams = addParamRequired()
        postParams += "&username=" + aNumber
        postParams += "&db=" + dbName
        postParams += "&phone=" + aPhone
        postParams += "&email=" + aEmail
        postParams += "&regrule=1"
        postParams += "&privacy=1"
        request.httpBody = postParams.data(using: .utf8)
        // получение данных с сервера
        let session = URLSession(configuration: .default)
        
        let downloadTask = session.downloadTask(with: request) {  (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "registration_" + aNumber + ".json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)

                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(aNumber,nDB,aEmail,aPhone,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(aNumber,nDB,aEmail,aPhone,returnErrorResult)
                        }
                        return
                    } else {
                        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
                        postFunc(aNumber,nDB,aEmail,aPhone,returnData)
                    }
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(aNumber,nDB,aEmail,aPhone,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(aNumber,nDB,aEmail,aPhone,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }
    
    /// Функция отправки проверочного кода на сервер
    ///
    /// - Parameters:
    ///   - aNumber: Номер лицевого счета
    ///   - uCode: Проверочный код
    ///   - postFunc: Функция, выполняемая после завершения запроса на бэк офис
    /// - Returns: Функция возвращает результат запроса в бэк офис
    func sendValidationCode(account aNumber: String, code uCode: String, function postFunc: @escaping ((String,String,BackOfficeMobileReturn) -> Void)) -> BackOfficeMobileReturn {
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString("BackOffice_checkConfirmCode_url", comment: "URL запроса для отправки кода проверки")
        guard let url = URL(string: urlString) else {
            let returnErrorData1 = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData1
        }
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // формируется и устанавливаются параметры для запроса к серверу
        var postParams = addParamRequired()
        postParams += "&username=" + aNumber
        postParams += "&code=" + uCode

        request.httpBody = postParams.data(using: .utf8)
        // получение данных с сервера
        let session = URLSession(configuration: .default)
        
        let downloadTask = session.downloadTask(with: request) {  (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "validcode_" + aNumber + ".json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)
                    
                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(aNumber,uCode,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(aNumber,uCode,returnErrorResult)
                        }
                        return
                    } else {
                        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
                        postFunc(aNumber,uCode,returnData)
                    }
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(aNumber,uCode,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(aNumber,uCode,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }
    
    /// Функция получения всех данных по лицевому счету
    ///
    /// - Parameters:
    ///   - aNumber: Номер лицевого счета
    ///   - aToken: Токен лиевого счета
    ///   - postFunc: Функция, выполняемая после запроса на бэк
    /// - Returns: Результат запроса на бэк офис
    func getFullDataAccount(account aNumber: String, token aToken: String, function postFunc: @escaping ((String,String,BackOfficeMobileReturn) -> Void)) -> BackOfficeMobileReturn {
        
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString("BackOffice_getFullDataAccount_url", comment: "URL запроса для получения всех данных")
        guard let url = URL(string: urlString) else {
            let returnErrorData1 = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData1
        }
        
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // формируется и устанавливаются параметры для запроса к серверу
        let postParams = "token="+aToken+"&version=40"
        request.httpBody = postParams.data(using: .utf8)
        
        // получение данных с сервера
        let session = URLSession(configuration: .default)
            
        let downloadTask = session.downloadTask(with: request) { (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "data_" + aNumber + "_back.json"
                let toFileResultName = "data_" + aNumber + ".json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                let urlToResultData = self.getApplicationDirectory(fileName: toFileResultName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)
                    
                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(aNumber,aToken,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(aNumber,aToken,returnErrorResult)
                        }
                        return
                    }
                    dataAccount.update_queue.sync {
                        if dataAccount.loadDataAccount(file: urlToData!) {
                            // удаляем старый файл
                            try? FileManager.default.removeItem(at: urlToResultData!)
                            // копируем полученный с сервера файл в директорию программы
                            try? FileManager.default.copyItem(at: urlFile!, to: urlToResultData!)
                            let returnData = BackOfficeMobileReturn(errorCode: 0, data: dataAccount)
                            postFunc(aNumber,aToken,returnData)
                            return
                        } else {
                            let returnErrorData = BackOfficeMobileReturn(errorCode: 3, data: nil)
                            postFunc(aNumber,aToken,returnErrorData)
                            return
                        }
                        
                    }
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(aNumber,aToken,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(aNumber,aToken,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }

    /// Функция отправки сообщения от пользователя
    ///
    /// - Parameters:
    ///   - uPhone: Телефон пользователя
    ///   - uEmail: Адрес электронной почты пользователя
    ///   - Text: Текст сообщения
    ///   - uToken: Токен лицевого счета
    ///   - postFunc: Функция, выполняемая после отправки сообщения
    /// - Returns: Результат запроса на бэк офис
    func sendFeedbackMessage(phone uPhone: String, email uEmail: String, message Text: String, token uToken: String, function postFunc: @escaping ((String,String,String,BackOfficeMobileReturn)-> Void)) -> BackOfficeMobileReturn {
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString("BackOffice_sendFeedbackMessage_url", comment: "URL для отправки заявки")
        guard let url = URL(string: urlString) else {
            let returnErrorData = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData
        }
        
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // формируется и устанавливаются параметры для запроса к серверу
        let postParams = "token="+uToken+"&phone="+uPhone+"&email="+uEmail+"&text="+Text
        request.httpBody = postParams.data(using: .utf8)
        request.timeoutInterval = 30
        // получение данных с сервера
        let session = URLSession(configuration: .default)
        
        
        let downloadTask = session.downloadTask(with: request) { (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "data_feedback.json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)
                    
                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(uPhone,uEmail,Text,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(uPhone,uEmail,Text,returnErrorResult)
                        }
                        return
                    }
                    let returnData = BackOfficeMobileReturn(errorCode: 0, data: dataAccount)
                    postFunc(uPhone,uEmail,Text,returnData)
                    return
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(uPhone,uEmail,Text,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(uPhone,uEmail,Text,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }

    /// Функция добавления новой оплаты
    ///
    /// - Parameters:
    ///   - uOrg: Идентификатор подразделения (Бурятия или Чита)
    ///   - uPhone: Номер телефона абонента
    ///   - uEmail: Адрес поты абонента
    ///   - uAccount: Номер лицевого счета
    ///   - uServices: Соответствие сумм и услуг
    ///   - postFunc: Функция, выполняемая после создания оплаты
    /// - Returns: Результат запроса на бэк офис
    func addNewPayment(accountOrg uOrg: Int, phone uPhone: String, email uEmail: String,account uAccount: String, services uServices: [PaymentServices], function postFunc: @escaping ((String,[PaymentServices],BackOfficeMobileReturn)-> Void)) -> BackOfficeMobileReturn {
        // если лицевой счет бурятии, то берем ссылку для бурятии, если Чита - то для Читы
        var nameUrlLocalized: String = ""
        if uOrg == 2 {
            nameUrlLocalized = "BackOffice_createPaymentBur_url"
        } else {
            nameUrlLocalized = "BackOffice_createPaymentChita_url"
        }
        // TODO: Если у абонента нет не телефона не email - не отпарвлять запрос на сервер, а выдавать ошибку
        
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString(nameUrlLocalized, comment: "URL для создания оплаты")
        guard let url = URL(string: urlString) else {
            let returnErrorData = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData
        }
        
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // формирование параметров запроса
        var postParam = "account="+uAccount+"&phone="+uPhone+"&email="+uEmail+"&return_url=http://e-sbyt.ru&place=3"
        for serv in uServices {
            postParam += "&service="+String(serv.ServiceCode)
            postParam += "&amount="+String(format: "%.2f", arguments: [serv.Summary])
        }
        
        request.httpBody = postParam.data(using: .utf8)
        // получение данных с сервера
        let session = URLSession(configuration: .default)
        
        
        let downloadTask = session.downloadTask(with: request) { (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "data_newpayment.json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)
                    
                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(uAccount,uServices,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(uAccount,uServices,returnErrorResult)
                        }
                        return
                    }
                    let returnData = self.readJsonNewPayment(file: urlToData!)
                    if returnData != nil {
                        let returnData = BackOfficeMobileReturn(errorCode: 0, data: returnData!)
                        postFunc(uAccount,uServices,returnData)
                        return
                    } else {
                        let returnErrorData = BackOfficeMobileReturn(errorCode: 9, data: nil)
                        postFunc(uAccount,uServices,returnErrorData)
                    }
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(uAccount,uServices,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(uAccount,uServices,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }
    
    /// Функция передачи показания
    ///
    /// - Parameters:
    ///   - cplugid: Идентификатор прибора учета
    ///   - dateValue: Дата передачи показания
    ///   - countValue: Значение показания
    ///   - uToken: Токен лицевого счета
    ///   - postFunc: Функция, выполняемая после передачи показаний
    /// - Returns: Результат запроса к бэк офису
    func newIndication(cplug cplugid: String, date dateValue: Date, value countValue: Int, token uToken: String, function postFunc: @escaping ((String,Date,Int,BackOfficeMobileReturn)->Void)) -> BackOfficeMobileReturn {
        
        // формируется url для отправки запроса серверу
        let urlString =  NSLocalizedString("BackOffice_createIndication_url", comment: "URL для создания показания")
        guard let url = URL(string: urlString) else {
            let returnErrorData = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData
        }
        
        // формируется запрос к серверу
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let dateValueStr = ConverDateToBackOffice(date: dateValue)
        if dateValueStr == nil {
            let returnErrorData = BackOfficeMobileReturn(errorCode: 1, data: nil)
            return returnErrorData
        }
        let countValueStr: String = String(countValue)
        // формирование параметров запроса
        var postParam = "token=" + uToken
        postParam += "&cplug_id=" + cplugid
        postParam += "&date_add=" + dateValueStr!
        postParam += "&value=" + countValueStr
        
        request.httpBody = postParam.data(using: .utf8)
        // получение данных с сервера
        let session = URLSession(configuration: .default)
        
        let downloadTask = session.downloadTask(with: request) { (urlFile, responce, error) in
            if urlFile != nil {
                let toFileName = "data_newindication.json"
                let urlToData = self.getApplicationDirectory(fileName: toFileName)
                if urlToData != nil {
                    // удаляем старый файл
                    try? FileManager.default.removeItem(at: urlToData!)
                    // копируем полученный с сервера файл в директорию программы
                    try? FileManager.default.copyItem(at: urlFile!, to: urlToData!)
                    
                    // проверяем есть ли в ответе ошибки от сервера
                    let errorReturnServer = self.readJsonForError(file: urlToData!)
                    
                    // если в результате запроса пришли ошибки - заканчиваем обработку файла
                    if errorReturnServer.isError() {
                        if errorReturnServer.isErrorServer() {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, errorText: errorReturnServer.errorMessage, data: nil)
                            postFunc(cplugid,dateValue,countValue,returnErrorResult)
                        } else {
                            let returnErrorResult = BackOfficeMobileReturn(errorCode: errorReturnServer.errorCode, data: nil)
                            postFunc(cplugid,dateValue,countValue,returnErrorResult)
                        }
                        return
                    }
                    let returnData = BackOfficeMobileReturn(errorCode: 0, data: true)
                    postFunc(cplugid,dateValue,countValue,returnData)
                    return
                } else {
                    let returnErrorData = BackOfficeMobileReturn(errorCode: 4, data: nil)
                    postFunc(cplugid,dateValue,countValue,returnErrorData)
                    return
                }
            } else {
                let returnErrorData = BackOfficeMobileReturn(errorCode: 2, data: nil)
                postFunc(cplugid,dateValue,countValue,returnErrorData)
                return
            }
        }
        // вызов получения данных с сервера
        downloadTask.resume()
        let returnData = BackOfficeMobileReturn(errorCode: 0, data: nil)
        return returnData
    }
}

/// Переменная для запросов к бэк офису
let backOffice: BackOfficeMobile = BackOfficeMobile()
/// Переменная хранения пользователей
var dataUsers: DataUsers? = DataUsers()
/// Переменная хранения данных о лицевом счета
var dataAccount: DataAccounts = DataAccounts()
