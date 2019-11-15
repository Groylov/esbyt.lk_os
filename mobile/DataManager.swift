//
//  DataManager.swift
//  mobile
//
//  Created by Groylov on 26/10/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import Foundation
import LocalAuthentication

/// Переменная обработки события обновления данных формы
let MainWorkVC_refreshVisualData = NSNotification.Name(rawValue: "MainWorkVC_refreshVisualData")

/// Класс возвращаемых ошибок обновления данных
enum ErrorDataAccount: Error {
    /// Ошибка данных платежного агента
    case errorReadData_Accepter
    /// Ошибка данных услуг
    case errorReadData_Service
    /// Ошибка данных организации
    case ErrorReadData_Org
    /// Ошибка данных контактной информации
    case ErrorReadData_Contacts
    /// Ошибка данных платежей
    case ErrorReadData_Payment
    /// Ошибка данных баланса лицевого счета
    case ErrorReadData_Balance
    /// Ошибка данных показаний
    case ErrorReadData_Countval
    /// Ошибка данных меток карты
    case ErrorReadData_Map
    /// Ошибка данных типов показаний
    case ErrorReadData_Cvaltype
    /// Ошибка данных расшифровки оплаты
    case ErrorReadData_Paymentdist
    /// Ошибка данных приборов учета
    case ErrorReadData_Cplug
    /// Ошибка данных тарифа
    case ErrorReadData_Tarif
}

/// Тип хранения данных о пользователи
struct StructUsers: (Codable) {
    /// Имя пользователя
    var userName: String
    /// Печатное имя пользователя для выввода на экран
    var userPrintName: String
    /// Токен пользователя
    var userToken: String
    /// Приоритет пользователя
    var userPriority: Int
    
    /// Функция инициализации данных
    ///
    /// - Parameters:
    ///   - uName: Имя пользователя
    ///   - uToken: Токен пользователя
    ///   - uPriority: Приоритет пользователя
    init(userName uName: String = "", userToken uToken: String = "", userPriority uPriority: Int = 0) {
        userName = uName
        userToken = uToken
        userPriority = uPriority
        userPrintName = uName
    }
    
    /// Функция проверки эквивалентности пользователей
    ///
    /// - Parameter element: Сравниваемый аэлемент
    /// - Returns: Истина - если переданный пользователь эквивалентен текущему пользователю и Ложь в противном случае
    func isEquival(_ element: StructUsers?) -> Bool {
        if element != nil {
            return element!.userName == self.userName && element!.userToken == self.userToken && element!.userPriority == self.userPriority
        } else {
            return false
        }
    }
}

/// Класс работы с пользователями в хранилище данных
class DataUsers {
    /// Текущий пользователь
    private var currentUser: StructUsers? = nil
    /// Все пользователи системы
    private var allUsers: Array<StructUsers>
    /// Пароль пользователя приложения
    private var mobilePassword: String = ""
    /// Использование TouchID/FaceID для авторизации приложение
    private var useTouchID: Bool = false
    
    /// Инициализация класса
    init() {
        allUsers = []
        
        // Получение списка пользователей и установка текущего пользователя
        if let dataAllUsers = UserDefaults.standard.array(forKey: "mobileUsers") as? Array<Data> {
            let decodeAllUsers = decodeStructUsersArray(structUsers: dataAllUsers)
            allUsers = decodeAllUsers
            sortAllUsers()
            if !allUsers.isEmpty {
                currentUser = allUsers[0]
            }
        }
        
        if currentUser == nil {
            return
        }
        
        // Получение параметра использования био авторизации
        useTouchID = UserDefaults.standard.bool(forKey: "useTouchID")
        // Получение пароля приложения
        mobilePassword = UserDefaults.standard.string(forKey: "mobilePassword") ?? ""
    }
    
    /// Деинициализация класса
    deinit {
        saveData()
    }
    
    /// Функция декодирования массива StructUsers из массива json
    ///
    /// - Parameter uArray: Массив пользователей декодирования
    /// - Returns: Возвращается декодированный массив пользователей
    private func decodeStructUsersArray(structUsers uArray: Array<Data>) -> Array<StructUsers> {
        var returnArray: Array<StructUsers> = []
        for user in uArray {
            let decodeUser = try? JSONDecoder().decode(StructUsers.self, from: user)
            if decodeUser != nil {
                returnArray.append(decodeUser!)
            }
        }
        return returnArray
    }
    
    /// Функция кодирования массива StructUsers в массив json
    ///
    /// - Parameter uArray: Массив пользователей для кодирования
    /// - Returns: Кодированный массив пользователей
    private func encodeStructUsersArray(structUsers uArray: Array<StructUsers>) -> Array<Data> {
        var returnArray: Array<Data> = []
        for user in uArray {
            let encodeUser = try? JSONEncoder().encode(user)
            if encodeUser != nil {
                returnArray.append(encodeUser!)
            }
        }
        return returnArray
    }
    
    /// Функция сортировки массива пользователей по приоритетам
    private func sortAllUsers() {
        allUsers = allUsers.sorted(by: {$0.userPriority < $1.userPriority})
    }
    
    /// Функция записи текущего пользователя в массив пользователей, для случия изменения
    private func saveCurrenUser() {
        if currentUser != nil {
            saveUser(userName: currentUser!.userName, userToken: currentUser!.userToken, userPriority: currentUser!.userPriority)
        }
    }

    /// Функция изменения пользователя в списке
    ///
    /// - Parameters:
    ///   - uName: Имя пользователя для изменения
    ///   - uToken: Токен пользователя
    ///   - uPriority: Приоритет пользователя
    private func saveUser(userName uName: String, userToken uToken: String, userPriority uPriority: Int) {
        for (index,user) in allUsers.enumerated() {
            if user.userName == uName {
                allUsers[index].userToken = uToken
                allUsers[index].userPriority = uPriority
                saveData()
                return
            }
        }
    }
    
    /// Поиск пользователя по имени
    ///
    /// - Parameter uName: Имя пользователя для поиска
    /// - Returns: Индекс пнайденного пользователя
    private func findUser(userName uName: String) -> Int? {
        for (index,user) in allUsers.enumerated() {
            if user.userName == uName {
                return index
            }
        }
        return nil
    }
    
    /// Функция записи всех данных в хранилище
    private func saveData() {
        sortAllUsers()
        let encodeAllUsers = encodeStructUsersArray(structUsers: allUsers)
        UserDefaults.standard.set(encodeAllUsers, forKey: "mobileUsers")
        UserDefaults.standard.set(useTouchID, forKey: "useTouchID")
        UserDefaults.standard.set(mobilePassword, forKey: "mobilePassword")
    }
    
    /// Функция проверки наличия текущего пользователя
    ///
    /// - Returns: Истина, если текущий пользователь указан
    func checkUsers() -> Bool {
        return currentUser != nil
    }
    
    /// Функция получения текущего пользователя
    ///
    /// - Returns: Данные о текущем пользователе
    func getCurrentUser() -> StructUsers? {
        if currentUser != nil {
            return currentUser!
        } else {
            return nil
        }
    }
    
    /// Функция получения массива всех пользователей
    ///
    /// - Returns: Массив всех пользователей системы
    func getAllUsers() -> [StructUsers] {
        return allUsers
    }
    
    /// Функция получения имен всех пользователей
    ///
    /// - Returns: Массив именем всех пользователей
    func getAllUsersName() -> [String] {
        var returnArray: [String] = []
        for user in allUsers {
            returnArray.append(user.userName)
        }
        return returnArray
    }
    
    /// Функция получения токена по имени пользователя
    ///
    /// - Parameter uName: Имя пользователя для получения токена
    /// - Returns: Токен указаного пользователя
    func getTokenUser(userName uName: String) -> String? {
        for user in allUsers {
            if user.userName == uName {
                return user.userToken
            }
        }
        return nil
    }
    
    /// Функция получения количества зарегистрированных пользователей
    ///
    /// - Returns: Возвращается количество зарегестрированных пользователей
    func getCountUsers() -> Int {
        return allUsers.count
    }
    
    /// Функция установки текущего пользователя системы
    ///
    /// - Parameter uName: Имя пользователя для установке текущем
    /// - Returns: Истина, если текущий пользователь установлен успешно и Ложь в противном случае
    func setCurrentUser(userName uName: String) -> Bool {
        for user in allUsers {
            if user.userName == uName {
                currentUser = user
                saveData()
                return true
            }
        }
        return false
    }
    
    // Функция изменения токена текущего пользователя
    ///
    /// - Parameter nToken: Токен для установки пользователю
    /// - Returns: Истина, если токен установлен успешно
    func setTokenCurrentUser(newToken nToken: String) -> Bool {
        if currentUser != nil {
            currentUser!.userToken = nToken
            saveCurrenUser()
            saveData()
            return true
        } else {
            return false
        }
    }
    
    /// Функция изменения приоритета пользователей
    ///
    /// - Parameter dPriority: Массив словарей с данными с именем пользователя и значением приоритета
    func setUsersPriority(userPriority dPriority: [String:Int]) {
        for (uName,uPriority) in dPriority {
            for (index,user) in allUsers.enumerated() {
                if user.userName == uName {
                    allUsers[index].userPriority = uPriority
                }
            }
        }
        sortAllUsers()
        saveData()
    }
    
    /// Функция изменения петного имени пользователя
    ///
    /// - Parameters:
    ///   - sUser: Имя пользователя
    ///   - newName: Новое печатное имя пользователя
    func setPrintName(user sUser: String, printName newName: String) {
        for (index,user) in allUsers.enumerated() {
            if user.userName == sUser {
                allUsers[index].userPrintName = newName
            }
        }
        saveData()
    }
    
    /// Функция добавления пользователя в массив
    ///
    /// - Parameters:
    ///   - uName: Имя нового пользователя
    ///   - uToken: Токен нового пользователя
    ///   - uPriority: Приоритет нового пользователя
    func addUser(userName uName: String, userToken uToken: String = "", userPriority uPriority: Int = 0) {
        let indexUser: Int? = findUser(userName: uName)
        if indexUser == nil {
            let newUser: StructUsers = StructUsers(userName: uName,userToken: uToken, userPriority: uPriority)
            self.allUsers.append(newUser)
        } else {
            saveUser(userName: uName, userToken: uToken, userPriority: uPriority)
        }
        saveData()
    }
    
    /// Функция удаления пользователя
    ///
    /// - Parameter uName: Имя удаляемого пользователя
    func removeUser(userName uName: String) {
        let indexUser: Int? = findUser(userName: uName)
        if indexUser != nil {
            allUsers.remove(at: indexUser!)
            saveData()
        }
    }
    
    /// Функция полной очистки информации о пользователях
    func removeAllUsers() {
        allUsers = []
        currentUser = nil
        useTouchID = false
        mobilePassword = ""
        saveData()
    }
    
    /// Функция получения свойства проверки доступа по TouchID
    ///
    /// - Returns: Истина, если свойство авторизации по TouchID включено и Ложь в противном случае
    func getUseTouchID() -> Bool {
        return useTouchID
    }
    
    /// Функция получения использования пароля для доступа к приложению
    ///
    /// - Returns: Истина, если вход по паролю включен и Ложь в противном случае
    func getUsePassword() -> Bool {
        return !mobilePassword.isEmpty
    }
    
    /// Функция получения пароля для авторизации в приложение
    ///
    /// - Returns: Пароль авторизации приложения
    func getMobilePassword() -> String? {
        return mobilePassword
    }
    
    /// Установка пароля для доступа к приложению
    ///
    /// - Parameter uPassword: Новый пароль доступа к приложению
    func setMobilePassword(userPassword uPassword: String?) {
        if uPassword == nil {
            mobilePassword = ""
        } else {
            mobilePassword = uPassword!
        }
        saveData()
    }
    
    /// Функция изменения настройки авторизации по биометрии
    ///
    /// - Parameter uTouchID: новое значение свойства аторизации по биометрии
    func setUseTouchID(useTouchID uTouchID: Bool) {
        useTouchID = uTouchID
        saveData()
    }
    
    /// Функция авторизации пользователя по паролю
    ///
    /// - Parameter uPassword: Пароль введенный пользователем
    /// - Returns: Истина, если пароль пользователя совпадает с паролем настроек и Ложь в противном случае
    func authCurrentUserPassword(userPassword uPassword: String) -> Bool {
        return uPassword == mobilePassword
    }
}

/// Структура хранения данных о платежных агентах
struct StructAccepter {
    /// Идентификатор платежного агента
    var accepter_id: String
    /// Наименование платежного агента
    var accepter_name: String?
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let accepter_id_nil = rec["accepter_id"] as? String else {
            throw ErrorDataAccount.errorReadData_Accepter
        }
        accepter_id = accepter_id_nil
        accepter_name = rec["accepter_name"] as? String
    }
}

/// Структура хранения данных об услугах
struct StructService {
    /// Идентификато услуги
    var service_id: Int
    /// Наименование услуги
    var service_name: String?
    /// Код услуги
    var service_code: Int?
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws  {
        guard let service_id_nil = rec["service_id"] as? Int else {
            throw ErrorDataAccount.errorReadData_Service
        }
        service_id = service_id_nil
        service_name = rec["service_name"] as? String
        service_code = rec["kod"] as? Int
    }
}

/// Структура хранения данных об организациях
struct StructOrg: (Codable) {
    /// Идентификатор организации
    var org_id: Int
    /// Наименование орагнизации
    var org_name: String
    /// КПП организации
    var org_kpp: String?
    /// ИНН организации
    var org_inn: String?
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let org_id_nil = rec["org_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Org
        }
        org_id = org_id_nil
        guard let org_name_nil = rec["org_name"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Org
        }
        org_name = org_name_nil
        org_kpp = rec["kpp"] as? String
        org_inn = rec["inn"] as? String
    }
}

/// Структура хранения контактных данных организации
struct StructContacts: (Codable) {
    /// Идентификатор организации
    var org_id: Int
    /// Идентификатор сортировки данных
    var order_id: Int
    /// Наименование контктных данных
    var name: String
    /// Описание контактных данных
    var descr: String?
    /// Тип контактных данных
    var type: String
    /// Параметры контактных данных
    var param: String?
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let org_id_nil = rec["org_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Contacts
        }
        org_id = org_id_nil
        guard let order_id_nil = rec["order_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Contacts
        }
        order_id = order_id_nil
        guard let name_nil = rec["name"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Contacts
        }
        name = name_nil
        descr = rec["descr"] as? String
        guard let type_nil = rec["type"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Contacts
        }
        type = type_nil
        param = rec["param"] as? String
    }
}

/// Структура хранения данных об оплатах
struct StructPayment: (Codable) {
    /// Идентификатор оплаты
    var payment_id: Int
    /// Идентификатор платежного агента
    var accepter_id: String?
    /// Дата оплаты
    var txn_date: Date
    /// Период оплаты
    var period: Date
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let payment_id_nil = rec["payment_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Payment
        }
        payment_id = payment_id_nil
        accepter_id = rec["accepter_id"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let txn_date_nil = rec["txn_date"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Payment
        }
        guard let txn_date_nil_convert = dateFormatter.date(from: txn_date_nil) else {
            throw ErrorDataAccount.ErrorReadData_Payment
        }
        txn_date = txn_date_nil_convert
        guard let period_nil = rec["period"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Payment
        }
        guard let period_nil_convert = dateFormatter.date(from: period_nil) else {
            throw ErrorDataAccount.ErrorReadData_Payment
        }
        period = period_nil_convert
    }
    
    /// Функция получения суммы оплаты по текущей оплате
    ///
    /// - Parameter uPaymentDist: Массив расшифровок оплат
    /// - Returns: Сумма оплаты
    func GetSummPayment(arrayPaymentDist uPaymentDist: [StructPaymentdist]?) -> Double? {
        var returnSumm: Double?
        if uPaymentDist != nil {
            for indexPayment in uPaymentDist! {
                if indexPayment.payment_id == payment_id {
                    if returnSumm == nil {
                        returnSumm = indexPayment.summ
                    } else {
                        returnSumm = returnSumm! + indexPayment.summ
                    }
                }
            }
        }
        return returnSumm
    }
    
    /// Функция получения платежного агента текущей оплаты
    ///
    /// - Parameter uArrayAccepter: Массив платежных агентов
    /// - Returns: Наименование платежного агента текущей оплаты
    func GetAccepterPayment(arrayAccepters uArrayAccepter: [StructAccepter]?) -> String? {
        if accepter_id == nil {
            return nil
        }
        if uArrayAccepter != nil {
            for indexAccepter in uArrayAccepter! {
                if indexAccepter.accepter_id == accepter_id {
                    return indexAccepter.accepter_name
                }
            }
        }
        return nil
    }
}

/// Структура хранения баланса
struct StructBalance: (Codable) {
    /// Период расчета
    var period: Date
    /// Идентификатор услуги
    var service_id: Int
    /// Начальное сальдо по услуге
    var begin_balance: Double?
    /// Начисления по услуге
    var accruals: Double?
    /// Перерасчеты по услуге
    var recalculations: Double?
    /// Поступления по услуге
    var receipts: Double?
    /// Сторно по услуге
    var storno_receipts: Double?
    /// Конечное сальдо по услуге
    var end_balance: Double?
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let period_nil = rec["period"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Balance
        }
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        guard let period_nil_convert = dateFormatter.date(from: period_nil) else {
            throw ErrorDataAccount.ErrorReadData_Balance
        }
        period = period_nil_convert
        
        guard let service_id_nil = rec["service_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Balance
        }
        service_id = service_id_nil
        begin_balance = rec["begin_balance"] as? Double
        accruals = rec["accruals"] as? Double
        recalculations = rec["recalculations"] as? Double
        receipts = rec["receipts"] as? Double
        storno_receipts = rec["storno_receipts"] as? Double
        end_balance = rec["end_balance"] as? Double
    }
}

/// Структура хранения сальдо по услугам
struct StructServiceBalance {
    /// Идентификатор услуги
    var service_id: Int
    /// Наименование услуги
    var service_name: String
    /// Баланс по услуге
    var balance: Double
    
    /// Функция инициализации данных по балансу услуг
    ///
    /// - Parameters:
    ///   - uID: Идентификатор услуги
    ///   - uName: Наименование услуги
    ///   - uBalance: Баланс по услуге
    init(id uID: Int, name uName: String, balance uBalance: Double) {
        service_id = uID
        service_name = uName
        balance = uBalance
    }
    
    /// Функция получения кода услуги по идентификатору
    ///
    /// - Parameter aService: Массив услуг
    /// - Returns: Код услуги по идентификатору
    func getServiceCode(arrayServices aService: [StructService]) -> Int {
        for rec in aService {
            if rec.service_id == self.service_id {
                let serviceCode =  rec.service_code ?? 0
                return serviceCode
            }
        }
        return 0
    }
}

/// Cтруктура хранения показаний
struct StructCountval: (Codable) {
    /// Идентификатор прибора учета
    var cplug_id: String
    /// Идентификатор показания
    var countval_id: Int
    /// Дата показания
    var countval_date: Date
    /// Значение показания
    var countval_nval: Int
    /// Тип показания
    var cvaltype_id: Int
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let cplug_id_nil = rec["cplug_id"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        cplug_id = cplug_id_nil
        guard let countval_id_nil = rec["countval_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        countval_id = countval_id_nil
        guard let countval_nval_nil = rec["countval_nval"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        countval_nval = countval_nval_nil
        guard let cvaltype_id_nil_string = rec["cvaltype_id"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        let cvaltype_id_nil_int = cvaltype_id_nil_string.replacingOccurrences(of: " ", with: "")
        guard let cvaltype_id_nil = Int(cvaltype_id_nil_int) else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        cvaltype_id = cvaltype_id_nil
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let countval_date_nil = rec["countval_date"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        guard let countval_date_nil_convert = dateFormatter.date(from: countval_date_nil) else {
            throw ErrorDataAccount.ErrorReadData_Countval
        }
        countval_date = countval_date_nil_convert
    }
    
    /// Функция получения строкового наименования типа показания
    ///
    /// - Parameter arrayCvaltype: Массив типов показаний
    /// - Returns: Наименование типа показания
    func getCvaltypeString(cvaltype arrayCvaltype: [StructCvaltype]) -> String? {
        for rec in arrayCvaltype {
            if rec.cvaltype_id == self.cvaltype_id {
                return rec.cvaltype_abbr
            }
        }
        return nil
    }
    
    /// Функция получения категории типа показания
    ///
    /// - Parameter arrayCvaltype: Массив типов показаний
    /// - Returns: Идентификатор категории показаний
    func getCvaltypeCategoty(cvaltype arrayCvaltype: [StructCvaltype]) -> Int? {
        for rec in arrayCvaltype {
            if rec.cvaltype_id == self.cvaltype_id {
                if rec.category > 2 || rec.category < 0 {
                    return 0
                } else {
                    return rec.category
                }
            }
        }
        return nil
    }
}

/// Структура для хранения точек на карте
struct StructMap: (Codable) {
    /// Наименование точки
    var title: String?
    /// Описание точки
    var description: String?
    /// Адрес точки
    var addr: String?
    /// Рабочее время точки
    var worktime: String?
    /// Телефон точки
    var phone: String?
    /// Широта точки
    var lat: String
    /// Долгота точки
    var lng: String
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let lat_nil = rec["lat"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Map
        }
        lat = lat_nil
        guard let lng_nil = rec["lng"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Map
        }
        lng = lng_nil
        title = rec["title"] as? String
        description = rec["description"] as? String
        addr = rec["addr"] as? String
        worktime = rec["worktime"] as? String
        phone = rec["phone"] as? String
    }
    
    /// Функция получения широты в виде числа
    ///
    /// - Returns: Широта точки
    func getLatitude() -> Double {
        let doubleLat = Double(self.lat) ?? 0
        return doubleLat
    }

    /// Функция получения долготы в виде числа
    ///
    /// - Returns: Долгота точки
    func getLongitude() -> Double {
        let doubleLng = Double(self.lng) ?? 0
        return doubleLng
    }
}

/// Структура хранения типов показаний
struct StructCvaltype: (Codable) {
    /// Идентификатор типа показаний
    var cvaltype_id: Int
    /// Наименование типа показаний
    var cvaltype_abbr: String
    /// Категория типа показаний
    var category: Int
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let cvaltype_id_nil_string = rec["cvaltype_id"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Cvaltype
        }
        let cvaltype_id_nil_int = cvaltype_id_nil_string.replacingOccurrences(of: " ", with: "")
        guard let cvaltype_id_nil = Int(cvaltype_id_nil_int) else {
            throw ErrorDataAccount.ErrorReadData_Cvaltype
        }
        cvaltype_id = cvaltype_id_nil
        guard let cvaltype_abbr_nil = rec["cvaltype_abbr"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Cvaltype
        }
        cvaltype_abbr = cvaltype_abbr_nil
        category = rec["category"] as? Int ?? 0
    }
}

/// Структура для хранения расшифровки оплат
struct StructPaymentdist: (Codable) {
    /// Идентификатор оплаты
    var payment_id: Int
    /// Идентификатор расшифровки оплаты
    var paydist_id: Int
    /// Идентификатор услуги платежа
    var service_id: Int
    /// Сумма оплаты
    var summ: Double
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let payment_id_nil = rec["payment_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Paymentdist
        }
        payment_id = payment_id_nil
        guard let paydist_id_nil = rec["paydist_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Paymentdist
        }
        paydist_id = paydist_id_nil
        guard let service_id_nil = rec["service_id"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Paymentdist
        }
        service_id = service_id_nil
        summ = rec["summ"] as? Double ?? 0
    }
    
    /// Функция получения наименование услуги оплатй
    ///
    /// - Parameter uServ: Массив услуг
    /// - Returns: Наименование услуги оплаты
    func getServiceString(services uServ: [StructService]) -> String? {
        for serv in uServ {
            if serv.service_id == self.service_id {
                return serv.service_name
            }
        }
        return nil
    }
}

/// Структура для хранения приборов учета
struct StructCplug: (Codable) {
    /// Идентификатор прибора учета
    var cplug_id: String
    /// Номер прибора учета
    var counter_no: String
    /// Наименование типа прибора учета
    var countype_abbr: String
    /// Значность прибора учета
    var digits: Int
    /// Марка прибора учета
    var scale_abbr: String
    /// Коэффициент трансформации прибора учета
    var ct: Int
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        guard let cplug_id_nil = rec["cplug_id"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Cplug
        }
        cplug_id = cplug_id_nil
        guard let counter_no_nil = rec["counter_no"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Cplug
        }
        counter_no = counter_no_nil
        guard let countype_abbr_nil = rec["countype_abbr"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Cplug
        }
        countype_abbr = countype_abbr_nil
        guard let digits_nil = rec["digits"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Cplug
        }
        digits = digits_nil
        guard let scale_abbr_nil = rec["scale_abbr"] as? String else {
            throw ErrorDataAccount.ErrorReadData_Cplug
        }
        scale_abbr = scale_abbr_nil
        guard let ct_nil = rec["ct"] as? Int else {
            throw ErrorDataAccount.ErrorReadData_Cplug
        }
        ct = ct_nil
    }
    
    /// Функция получения списка показаний по прибору текущему прибору учета
    ///
    /// - Parameter aCountval: Массив показаний приборов учета
    /// - Returns: Отсортированный по дате массив показаний текущего прибора учета
    func getCountvalCplug(arrayCountval aCountval: [StructCountval]) -> [StructCountval] {
        var returnArray: [StructCountval] = []
        for recCountval in aCountval {
            if recCountval.cplug_id == self.cplug_id {
                returnArray.append(recCountval)
            }
        }
        // сортировка списка показаний по дате
        returnArray = returnArray.sorted(by: {$0.countval_date > $1.countval_date})
        return returnArray
    }
    
    /// Функция получения наименования прибора учета для вывода пользователю
    ///
    /// - Returns: Наименование прибора учета составленое из номера и марки
    func getCplugName() -> String {
        return counter_no + " | " + scale_abbr
    }
}

/// Структура хранения информации о тарифе
struct StructTarif: (Codable) {
    /// Имя тарифа
    var tarifName: String?
    /// Значение тарифа 1 (норма)
    var tarif1: Double
    // Значение тарифа 2 (сверх норма)
    var tarif2: Double
    
    /// Функция инициализации объекта
    ///
    /// - Parameter rec: Запись словаря с параметрами инициализации
    /// - Throws: Исключение несоответствия переданного словаря загружаемым данным
    init(dictionary rec: Dictionary<String,Any>) throws {
        tarifName = rec["tariff_name"] as? String
        guard let tarif1_nil = rec["tariff1"] as? Double else {
            throw ErrorDataAccount.ErrorReadData_Tarif
        }
        tarif1 = tarif1_nil
        guard let tarif2_nil = rec["tariff2"] as? Double else {
            throw ErrorDataAccount.ErrorReadData_Tarif
        }
        tarif2 = tarif2_nil
    }
}

/// Структура хранения баланса по периодам
struct StructPeriodBalance: (Codable) {
    
    /// Период баланса
    var period: Date
    /// Сумма баланса на период
    var balance: Double
    
    /// Функция инициализирования записи
    ///
    /// - Parameters:
    ///   - pDate: Дата баланса
    ///   - sBalance: Сумма баланса
    init(period pDate: Date, balance sBalance: Double) {
        period = pDate
        balance = sBalance
    }
}

/// Класс чтения хранения данных по лицевому счету
class DataAccounts {

    /// Дата обновления данных в классе
    var update_time: Date = Date()
    /// Поток для обновления данных в классе
    var update_queue = DispatchQueue(label: "queueUpdateDataAccount")
    /// Идентификатор организации 1-Чита 0-Бурятия
    var account_org_id: Int = 1
    /// Номер лицевого счета
    var account_no: String = ""
    /// ФИО абонента
    var account_fio: String = ""
    /// Токен для отправки сообщений
    var account_ntoken: Int = 0
    /// Адрес лицевого счета
    var account_addr: String = ""
    /// Короткий адрес лицевого счета
    var account_shortaddr: String = ""
    /// Категория помещения лицевого счета
    var account_categoty: String? = nil
    /// Площадь лицевого счета
    var account_area: Double? = 0
    /// Количество фактически проживающих
    var account_factcount: Int? = nil
    /// Количество прописанных
    var account_perscount: Int? = nil
    /// Количество комнат
    var account_roomcount: Int? = nil
    /// Телефон лицевого счета
    var account_phone: String? = nil
    /// Email лицевого счета
    var account_email: String? = nil
    /// Тариф
    var account_tarif: StructTarif? = nil
    
    /// Таблица платежных агентов
    var accepters: [StructAccepter] = []
    /// Таблица услуг
    var services: [StructService] = []
    /// Таблица организаций
    var orgs: [StructOrg] = []
    /// Таблица контактной информации
    var contacts: [StructContacts] = []
    /// Таблица оплат
    var payments: [StructPayment] = []
    /// Таблица изменение баланса
    var balances: [StructBalance] = []
    /// Таблица показаний
    var countvals: [StructCountval] = []
    /// Таблица точек на карте
    var maps: [StructMap] = []
    /// Таблица типов показаний
    var cvaltypes: [StructCvaltype] = []
    /// Таблица расшифровок оплат
    var paymentsdist: [StructPaymentdist] = []
    /// Таблица приборов учета
    var cplugs: [StructCplug] = []
    
    /// Функция получения максимального периода таблицы баланса
    ///
    /// - Returns: Возвращет дату с максимальным период по таблице баланса, если дата не определена - возвращается текущая дата
    private func getMaxPeriodBalance() -> Date {
        var currentDate: Date? = nil
        for cRecord in balances {
            if currentDate != nil {
                if currentDate! < cRecord.period {
                    currentDate = cRecord.period
                }
            } else {
                currentDate = cRecord.period
            }
        }
        if currentDate == nil {
            currentDate = Date()
        }
        return currentDate!
    }

    /// Функция получения услуги по идентификатору
    ///
    /// - Parameter uId: Идентификатор услуги
    /// - Returns: Наименование услуги, соответствующей идентификатору, если такого идентификатора нет - возвращется пустая строка
    func getServiceById(id uId: Int) -> String {
        for cRecord in services {
            if uId == cRecord.service_id {
                if cRecord.service_name != nil {
                    return cRecord.service_name!
                } else {
                    return ""
                }
            }
        }
        // если нет такой услуги в таблице - возвращаем пустую строку
        return ""
    }
    
    /// Функция получения массива периодов баланса
    ///
    /// - Returns: Масив периодов баланса с сортировкой от ближайшей даты к более ранней
    private func getArrayPeriodBalance() -> [Date] {
        var returnArray: [Date] = Array()
        for elementBalance in balances {
            let currentPeriod = elementBalance.period
            let findPeriod = returnArray.firstIndex(of: currentPeriod)
            if findPeriod == nil {
                returnArray.append(currentPeriod)
            }
        }
        returnArray = returnArray.sorted(by: {$0 > $1})
        return returnArray
    }
    
    /// Функция получения записей баланса за период
    ///
    /// - Parameter uPeriod: Период за который необходимо получить баланс
    /// - Returns: Массив баланса за указанный период
    private func getArrayBalanceOfPeriod(period uPeriod: Date) -> [StructBalance] {
        var returnArray: [StructBalance] = Array()
        for recBalance in balances {
            if recBalance.period == uPeriod {
                returnArray.append(recBalance)
            }
        }
        return returnArray
    }
    
    /// Функция получения суммы баланса за период
    ///
    /// - Parameter uPeriod: Период для получения суммы
    /// - Returns: Сумма баланса за переданный период
    private func getSummBalanceOfPeriod(period uPeriod: Date) -> Double {
        var returnSumm: Double = 0
        for recBalance in balances {
            if recBalance.period == uPeriod {
                if recBalance.end_balance != nil {
                    returnSumm += recBalance.end_balance!
                }
            }
        }
        return returnSumm
    }
    
    /// Функция получения разбивки баланса по периодам
    ///
    /// - Returns: Массив балансов, разбитых по периодам отсортированный от позней даты к ранней
    func getArrayPeriodSummBalance() -> [StructPeriodBalance] {
        var returnArray: [StructPeriodBalance] = Array()
        let periodBalance = getArrayPeriodBalance()
        for period in periodBalance {
            let summPeriod = getSummBalanceOfPeriod(period: period)
            let newRecordArray = StructPeriodBalance(period: period, balance: summPeriod)
            returnArray.append(newRecordArray)
        }
        returnArray = returnArray.sorted(by: {$0.period > $1.period})
        return returnArray
    }
    
    /// Функция получения массива баланса услуг за период
    ///
    /// - Parameter uPeriod: Период за который необходимо получить баланс услуг
    /// - Returns: Отсортированный массив с балансом услуг за период
    func getArrayServicePeriodBalance(period uPeriod: Date) -> [StructBalance] {
        var returnArray: [StructBalance] = Array()
        for recBalance in balances {
            if recBalance.period == uPeriod {
                returnArray.append(recBalance)
            }
        }        
        returnArray = returnArray.sorted(by: {$0.service_id < $1.service_id})
        return returnArray
    }
    
    /// Функция загрузки данных в класс из файла
    ///
    /// - Parameter fileName: Адрес файла для загрузки
    /// - Returns: Истина, если загрузка прошла успешно и Ложь в противном случае
    func loadDataAccount(file fileName: URL) -> Bool {
        NSLog("Начало чтения файла %@",fileName.absoluteString)
        // получаем данные из файла обработки
        guard let data = try? Data(contentsOf: fileName) else {
            return false
        }
        
        // получение даты обновления по дате создания файла
        let attrsFile = try? fileName.resourceValues(forKeys: [.creationDateKey])
        if attrsFile != nil {
            let dateCreate = attrsFile!.creationDate
            if dateCreate != nil {
                update_time = dateCreate!
            } else {
                update_time = Date()
            }
        } else {
            update_time = Date()
        }
        
        // получаем словарь
        guard let rootDictionaryAny = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return false
        }
        // получаем основной словарь
        guard let rootDictionary = rootDictionaryAny as? Dictionary<String,Any> else {
            return false
        }
        
        // чтение таблицы платежных агентов
        guard let accepterDictionary = rootDictionary["t_accepter"] as? [Dictionary<String,Any>] else {
            return false
        }
        accepters.removeAll()
        for recItem in accepterDictionary {
            guard let newRecordAccepters = try? StructAccepter(dictionary: recItem) else {
                return false
            }
            accepters.append(newRecordAccepters)
        }
        
        // чтение таблицы услуг
        guard let serviceDictionary = rootDictionary["t_service"] as? [Dictionary<String,Any>] else {
            return false
        }
        services.removeAll()
        for recItem in serviceDictionary {
            guard let newRecordService = try? StructService(dictionary: recItem) else {
                return false
            }
            services.append(newRecordService)
        }
        services = services.sorted(by: {$0.service_id < $1.service_id})
        
        // чтение таблицы орагнизаций
        guard let orgDictionary = rootDictionary["t_org"] as? [Dictionary<String,Any>] else {
            return false
        }
        orgs.removeAll()
        for recItem in orgDictionary {
            guard let newRecordOrg = try? StructOrg.init(dictionary: recItem) else {
                return false
            }
            orgs.append(newRecordOrg)
        }
        
        // чтение таблицы контактной информации
        guard let contactDictionary = rootDictionary["t_contacts"] as? [Dictionary<String,Any>] else {
            return false
        }
        contacts.removeAll()
        for recItem in contactDictionary {
            guard let newRecordContact = try? StructContacts(dictionary: recItem) else {
                return false
            }
            contacts.append(newRecordContact)
        }
        
        // чтение таблицы оплат
        guard let paymentDictionary = rootDictionary["t_payment"] as? [Dictionary<String,Any>] else {
            return false
        }
        payments.removeAll()
        for recItem in paymentDictionary {
            guard let newRecordPayment = try? StructPayment(dictionary: recItem) else {
                return false
            }
            payments.append(newRecordPayment)
        }
        
        payments = payments.sorted(by: {$0.txn_date > $1.txn_date})
        
        // чтение таблицы баланса
        guard let balanceDictionary = rootDictionary["t_balance"] as? [Dictionary<String,Any>] else {
            return false
        }
        balances.removeAll()
        for recItem in balanceDictionary {
            guard let newRecordBalance = try? StructBalance(dictionary: recItem) else {
                return false
            }
            balances.append(newRecordBalance)
        }
        
        // чтение таблицы показаний
        guard let countvalDictionary = rootDictionary["t_countval"] as? [Dictionary<String,Any>] else {
            return false
        }
        countvals.removeAll()
        for recItem in countvalDictionary {
            guard let newRecordCountval = try? StructCountval(dictionary: recItem) else {
                return false
            }
            countvals.append(newRecordCountval)
        }
        
        // чтение таблицы карты
        guard let mapDictionary = rootDictionary["t_map"] as? [Dictionary<String,Any>] else {
            return false
        }
        maps.removeAll()
        for recItem in mapDictionary {
            guard let newRecordMap = try? StructMap(dictionary: recItem) else {
                return false
            }
            maps.append(newRecordMap)
        }
        
        // чтение таблицы типов показаний
        guard let cvaltypeDictionary = rootDictionary["t_cvaltype"] as? [Dictionary<String,Any>] else {
            return false
        }
        cvaltypes.removeAll()
        for recItem in cvaltypeDictionary {
            guard let newRecordCvaltypes = try? StructCvaltype(dictionary: recItem) else {
                return false
            }
            cvaltypes.append(newRecordCvaltypes)
        }
        
        // чтение таблицы расшифровки оплат
        guard let paymentdistDictionary = rootDictionary["t_paymentdist"] as? [Dictionary<String,Any>] else {
            return false
        }
        paymentsdist.removeAll()
        for recItem in paymentdistDictionary {
            guard let newRecordPaymentdist = try? StructPaymentdist(dictionary: recItem) else {
                return false
            }
            paymentsdist.append(newRecordPaymentdist)
        }
        
        // чтение таблицы приборов учета
        guard let cplugDictionary = rootDictionary["t_cplug"] as? [Dictionary<String,Any>] else {
            return false
        }
        cplugs.removeAll()
        for recItem in cplugDictionary {
            guard let newRecordCplug = try? StructCplug(dictionary: recItem) else {
                return false
            }
            cplugs.append(newRecordCplug)
        }
        
        // чтение таблицы лицевых счетов
        guard let accountDictionary = rootDictionary["t_account"] as? [Dictionary<String,Any>] else {
            return false
        }
        if accountDictionary.count == 0 {
            return false
        }
        for recItem in accountDictionary {
            guard let account_no_nil = recItem["account_no"] as? String else {
                return false
            }
            account_no = account_no_nil
            guard let account_org_id_nil = recItem["org_id"] as? Int else {
                return false
            }
            account_org_id = account_org_id_nil
            
            account_fio = recItem["fio"] as? String ?? ""
            account_addr = recItem["addr"] as? String ?? ""
            account_shortaddr = recItem["shortaddr"] as? String ?? ""
            account_categoty = recItem["category"] as? String
            account_area = recItem["s"] as? Double
            account_factcount = recItem["factcount"] as? Int
            account_perscount = recItem["perscount"] as? Int
            account_roomcount = recItem["roomcount"] as? Int
            account_phone = recItem["phone"] as? String
            account_email = recItem["email"] as? String
            break
        }

        // чтение таблицы тарифов
        guard let tarifDictionary = rootDictionary["t_tariff"] as? [Dictionary<String,Any>] else {
            return false
        }
        if tarifDictionary.count > 0 {
            guard let account_tarif_nil = try? StructTarif(dictionary: tarifDictionary[0]) else {
                return false
            }
            account_tarif = account_tarif_nil
        }
        return true
    }
    
    /// Функция проверки существования файла для загрузки
    ///
    /// - Parameter fileName: Имя файла загрузки
    /// - Returns: Истина, если файл существует и Ложь в противном случае
    func existsFileLoadDataAccount(file fileName: URL) -> Bool {
        return FileManager.default.fileExists(atPath: fileName.path)
    }
    
    /// Функция получения баланса по услугам
    ///
    /// - Returns: Отсортированный по коду услуги массив балансов услуг
    func getServiceBalance() -> [StructServiceBalance] {
        let maxPeriod = getMaxPeriodBalance()
        var returnArray: [StructServiceBalance] = []
        for cRecord in balances {
            if cRecord.period == maxPeriod {
                let serviceid = cRecord.service_id
                let servicename = getServiceById(id: serviceid)
                var balance: Double
                if cRecord.end_balance != nil {
                    balance = cRecord.end_balance!
                    let newRecord = StructServiceBalance(id: serviceid, name: servicename, balance: balance)
                    returnArray.append(newRecord)
                }
            }
        }
        returnArray = returnArray.sorted(by: {$0.service_id < $1.service_id})
        return returnArray
    }
    
    /// Функция получения оплаты по идентификатору
    ///
    /// - Parameter payId: Идентифкатор оплаты
    /// - Returns: Данные оплаты по идентификатору
    func getPaymentById(paymentId payId: Int) -> StructPayment? {
        for pay in payments {
            if pay.payment_id == payId {
                return pay
            }
        }
        return nil
    }
    
    /// Функция получения расшифровок платежа по идентификатору платежа
    ///
    /// - Parameter payId: Идентификатор оплаты
    /// - Returns: Массив расшифровок платежа по переданному идентификатору
    func getPaymentDistById(paymentId payId: Int) -> [PaymentServicesString] {
        var returnArray: [PaymentServicesString] = []
        var paydistID: [StructPaymentdist] = []
        for payd in paymentsdist {
            if payd.payment_id == payId {
                paydistID.append(payd)
            }
        }
        if paydistID.count != 0 {
            paydistID = paydistID.sorted(by: {$0.service_id < $1.service_id})
            for payd in paydistID {
                let servName = payd.getServiceString(services: services) ?? ""
                let newRecordResult = PaymentServicesString(name: servName, summary: payd.summ)
                returnArray.append(newRecordResult)
            }
        }
        return returnArray
    }
}

/// Структура для передачи оплаты по услугам
struct PaymentServices {
    /// Код услуги
    var ServiceCode: Int
    /// Сумма оплаты
    var Summary: Double
    
    /// Функция инициализации объекта
    ///
    /// - Parameters:
    ///   - uCode: Код услуги
    ///   - uSummary: Сумма оплаты
    init (code uCode: Int, summary uSummary: Double) {
        ServiceCode = uCode
        Summary = uSummary
    }
}

/// Структура хранения сумм по услугам
struct PaymentServicesString {
    /// Наименования услуг
    var ServiceName: String
    /// Сумма
    var Summary: Double
    
    /// Функция инициализации объекта
    ///
    /// - Parameters:
    ///   - uName: Наименование услуги
    ///   - uSummary: Сумма
    init (name uName: String, summary uSummary: Double) {
        ServiceName = uName
        Summary = uSummary
    }
}
