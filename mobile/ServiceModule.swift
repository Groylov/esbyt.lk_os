//
//  ServiceModule.swift
//  mobile
//
//  Created by Groylov on 19/04/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import Foundation
import UIKit
import MapKit


/// Функция округления числа до суммы с копейками
///
/// - Parameter double: Число для округления копеек
/// - Returns: Число с двумя знаками после запятой
func roundDoubleRub(_ double: Double) -> Double {
    return (double * 100).rounded(.up) / 100
}

/// Функция конвертации даты в строковое написание
///
/// - Parameter uDate: Конвертируемая дата
/// - Returns: Строка с датой в формате 13 мая 2019
func ConverDateToString(date uDate: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy"
    dateFormatter.locale = Locale(identifier: "ru-RU")
    return dateFormatter.string(from: uDate)
}

/// Функция конвертации даты в строковое написание
///
/// - Parameter uDate: Конвертируемая дата
/// - Returns: Строка с датой в формате 13 мая 2019
func ConverDateToStringMonth(date uDate: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.monthSymbols = ["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"]
    dateFormatter.dateFormat = "MMMM yyyy"
    dateFormatter.locale = Locale(identifier: "ru-RU")
    
    return dateFormatter.string(from: uDate)
}

/// Функция конвертации даты для отправки на бэк офис
///
/// - Parameter uDate: Конвертируемая дата
/// - Returns: Строка с датой в формате 2019-05-13
func ConverDateToBackOffice(date uDate: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: uDate)    
}

/// Функция получения версии приложения формата x.x.x
///
/// - Returns: Версия приложения в формате x.x.x
func readVersionBundleString() -> String? {
    let returnVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    return returnVer
}

/// Функция получения версии сборки
///
/// - Returns: Версия сборки приложения
func readVersionBundle() -> String? {
    let returnVer = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    return returnVer
}

/// Функция включения режима отклика Taptic Engine
func tapticEngine() {
    let tapEng = UISelectionFeedbackGenerator()
    tapEng.selectionChanged()
    tapEng.prepare()
}

/// Функция отображения сообщения пользователю
///
/// - Parameters:
///   - selfView: Контроллер вызывающий отображение сообщения
///   - cName: Имя вызывающая отображения
///   - mText: Текст сообщения
func showMessageError(view selfView: UIViewController, name cName: String, message mText: String) {
    
    let messageTitle = NSLocalizedString(cName + "_messageTitle", comment: "Заголовок окна сообщения")
    let messageButtonOkTitle = NSLocalizedString(cName + "_messageButtonOkTitle", comment: "Заголовок кнопки")
    let alertControll = UIAlertController(title: messageTitle, message: mText,preferredStyle: .alert)
    let alertButtonOk = UIAlertAction(title: messageButtonOkTitle, style: .default) { (alert) in ()
        }
    alertControll.addAction(alertButtonOk)
    selfView.present(alertControll,animated: true,completion: nil)
}

/// Функция проверки строки лицевого счета на формат и его подгонка в случае несоответствия
///
/// - Parameter strAccount: Строка лицевого счета
/// - Returns: Строка подогнанная под формат лицевого счета
func setAccountOnFormat(account strAccount: String) -> String {
    // если пустая строка - возвращаем пустую строку
    if strAccount.isEmpty {
        return strAccount
    }
    
    var returnString = ""
    
    // проверяем строку на лишние символы и удаление их
    returnString = strAccount.filter("0123456789".contains)
    
    // проверяем длину и укорачиваем в случае
    if returnString.count > 12 {
        let countDrop: Int = returnString.count - 12
        returnString = String(returnString.dropLast(countDrop))
    }
    return returnString
    
}

/// Функция проверки строки телефона на формат и его подгонка в случае несоответствия
///
/// - Parameters:
///   - strPhone: Строка телефона для проверки и приобразования
/// - Returns: Строка подогнанная под формат телефона
func setPhoneOnFormat(phone strPhone: String) -> String {
    // строка телефона должна соответствовать формату +7ХХХХХХХХХХ
    
    // если пустая строка - возвращаем пустую строку
    if strPhone.isEmpty {
        return strPhone
    }
    
    var returnString = ""
    
    // проверяем строку на лишние символы и удаление их
    returnString = strPhone.filter("+0123456789".contains)
    
    // проверяем, что бы первым стоял +
    let firstString = returnString[returnString.index(returnString.startIndex,offsetBy: 0)]
    if firstString != "+" {
        returnString = "+" + returnString
    }
    
    // проверяем, что бы второй символ был 7
    if returnString.count > 1 {
        let secondString = returnString[returnString.index(returnString.startIndex,offsetBy: 1)]
        if secondString != "7" {
            returnString = returnString.replace(index: 1, new: "7")
        }
    }
    
    // проверяем длину и укорачиваем в случае
    if returnString.count > 12 {
        let countDrop: Int = returnString.count - 12
        returnString = String(returnString.dropLast(countDrop))
    }
    return returnString
}

/// Функция приобразования строки в десятичное число с корректировкой на локализационные символы разделения
///
/// - Parameter str: Строка для приобразования
/// - Returns: Получившееся число
func localStringToDouble(_ str: String) -> Double? {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .decimal
    let number = formatter.number(from: str)
    if number != nil {
        return Double(exactly: number!)
    } else {
        return nil
    }
}

// MARK: - Плагин для класса Date
extension Date {
    
    /// Функция определения первого дня месяца
    ///
    /// - Returns: Первый день месяца даты
    func startOfMonth() -> Date? {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month, .hour], from: Calendar.current.startOfDay(for: self))
        return Calendar.current.date(from: comp)!
    }
}

// MARK: - Плагин для типа String
extension String {
    
    /// Функция удаления пробела в начале строки
    ///
    /// - Returns: Строка без начального пробела
    func deleteFerstSpace() -> String {
        let ferstreadString = self[self.index(self.startIndex,offsetBy: 0)]
        if ferstreadString == " " {
            return String(self.dropFirst())
        } else {
            return self
        }
    }
    
    /// Функция замены символа в строке по индексу
    ///
    /// - Parameters:
    ///   - indexChar: Индекс заменяемого символа в строке (начинается с 0)
    ///   - newChar: Новый символ, вставляемый на место индекса
    /// - Returns: Строка с замененным символом
    func replace(index indexChar: Int, new newChar: Character) -> String {
        var returnString: String = ""
        for i in 0...self.count-1 {
            if i == indexChar {
                returnString += String(newChar)
            } else {
                returnString += String(self[self.index(self.startIndex,offsetBy: i)])
            }
        }
        return returnString
    }
    
    /// Функция замены символа в строке с одного на другой
    ///
    /// - Parameters:
    ///   - oldChar: Заменяемый символ
    ///   - newChar: Новый, подставляемый символ
    /// - Returns: Строка с замененнными символами
    func replace(old oldChar: Character, new newChar: Character) -> String {
        var returnString: String = ""
        if self.count == 0 {
            return returnString
        }
        for i in 0...self.count-1 {
            let currentChar = String(self[self.index(self.startIndex,offsetBy: i)])
            if currentChar == String(oldChar) {
                returnString += String(newChar)
            } else {
                returnString += currentChar
            }
        }
        return returnString
    }
    
    /// Функция подсчета количества вхождений символа в строку
    ///
    /// - Parameter findChar: Искомый символ
    /// - Returns: Количество вхождений символа в строку
    func countChar(char findChar: Character) -> Int {
        var searchStartIndex = self.startIndex
        var returnCount: Int = 0
        while searchStartIndex < self.endIndex,
            let range = self.range(of: String(findChar), range: searchStartIndex..<self.endIndex),
                !range.isEmpty {
                returnCount += 1
                searchStartIndex = range.upperBound
        }
        return returnCount
    }
    
    /// Функция обрезания последнийх символов строки до указанной длины
    ///
    /// - Parameter len: Длина получившейся итоговой строки
    /// - Returns: Возвращается строка обрезанная до длины переданной параметром. Если строка изначально была меньшей длины, то возвращается исходная строка
    func getSubstringLength(length len: Int) -> String {
        var readString = self
        while readString.count > len {
            readString = String(readString.dropLast())
        }
        return readString
    }
}

// MARK: - плагины для работы с объектами карты
extension MKAnnotationView {
    
    /// Функция определения объекта по точке на карте
    ///
    /// - Parameter aMap: Массив объектов из которых необходимо выбрать соответствующий
    /// - Returns: Найденный в массиве объект
    func getMapData(arrayMap aMap: [StructMap]) -> StructMap? {
        if self.annotation != nil {
            let stringlat = String(self.annotation!.coordinate.latitude).getSubstringLength(length: 8)
            let stringlng = String(self.annotation!.coordinate.longitude).getSubstringLength(length: 8)
            for recMap in aMap {
                let recMapLat = recMap.lat.getSubstringLength(length: 8)
                let recMapLng = recMap.lng.getSubstringLength(length: 8)
                if recMapLat == stringlat && recMapLng == stringlng {
                    return recMap
                }
            }
        }
        return nil
    }
}

// MARK: - плагины для работы с изображениями
extension UIImage {
    
    /// Функция изменения цвета изображения
    ///
    /// - Parameter color: Цвет для изображения
    /// - Returns: Изображение с измененным цветом
    public func maskWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(origin: CGPoint.zero, size: size)
        color.setFill()
        self.draw(in: rect)
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}

// MARK: - Плагин для класса элементов
extension UIView {
    
    /// Функция создания градиентной заливки объекта
    ///
    /// - Parameters:
    ///   - colours: Цвета градиентной заливки
    ///   - locations: Степень перетикания градиента
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        
    }
}

// MARK: - Плагин для элементов управления формы
extension UIViewController {
    
    /// Функция скрытия клавиатуры при дизактивации объекта
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}


