//
//  AddIndicationViewController.swift
//  mobile
//
//  Created by Groylov on 14/05/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class AddIndicationViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var mainVC: UIView!
    @IBOutlet weak var mainMessagePanel: UIView!
    @IBOutlet weak var lastIndicationLabel: UILabel!
    @IBOutlet weak var dateIndicationLabel: UILabel!
    @IBOutlet weak var valueIndicationEdit: UITextField!
    @IBOutlet weak var infoErrorLabel: UILabel!
    @IBOutlet weak var addButtonTouch: UIButton!
    @IBOutlet weak var cancelButtonTouch: UIButton!
    @IBOutlet weak var constaintCenterForm: NSLayoutConstraint!
    
    /// Дата нового показания
    private var newValueDate: Date = Date()
    /// Последнее показание
    var lastIndication: StructCountval?
    /// Длина вводимого показания
    var lengthStringValue: Int = 0
    /// Прибор учета для показания
    var cplug_id: String = ""
    
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
    
    /// Функция получения сообщения об ошибке ввода нового показания
    ///
    /// - Parameters:
    ///   - lastInd: Прошлое показание
    ///   - newInd: Значение нового показания
    ///   - newDate: Дата нового показания
    /// - Returns: Строка с сообщение об ошибке ввода нового показания. Если строка nil, значит ошибок нет
    private func createTextErrorNewValue(last lastInd: StructCountval?, new newInd: String, date newDate: Date) -> String? {
        // проверка нового показания на пустую строку
        if newInd.isEmpty {
            return nil
        }
        // приобразование строки с показанием к числу
        let newIndValue = Int(newInd)
        if newIndValue == nil {
            let textError = NSLocalizedString("AddIndication_ErrorDataValue", comment: "Не верный формат показания")
            return textError
        }
        // проверка на наличие прошлого показания
        if lastInd == nil {
            return nil
        }
        
        let lastValue = lastInd!.countval_nval
        
        // проверка на отрицательный расход
        if lastValue > newIndValue! {
            let textError = NSLocalizedString("AddIndication_NegativeConsumption", comment: "Отрицательный расход")
            return textError
        }
        
        // проверка на нуливой расход
        if lastValue == newIndValue! {
            let textError = NSLocalizedString("AddIndication_ZeroConsumption", comment: "Нуливой расход")
            return textError
        }
        
        let lastDateDay = Calendar.current.startOfDay(for: lastInd!.countval_date)
        let newDateDay = Calendar.current.startOfDay(for: newDate)
        // проверка на среднесутку
        let diffDate = Double(newDateDay.timeIntervalSince(lastDateDay)) / 60 / 60 / 24
        let avgConsump = Double(newIndValue! - lastValue) / diffDate
        if avgConsump >= 20 {
            let textError = NSLocalizedString("AddIndication_TallConsumption", comment: "Среднесуточный расход выше 20")
            return textError
        }
        return nil
    }
    
    /// Функция обработки после занесения показания на бэк офис
    ///
    /// - Parameters:
    ///   - cplugid: Идентификатор прибора учета
    ///   - vDate: Дата нового показания
    ///   - cValue: Значение нового показания
    ///   - rBack: Результат работы бэк офиса
    func newCountval_postFunc(cplug cplugid: String, date vDate: Date, value cValue: Int,return rBack: BackOfficeMobileReturn) {
        var messageText: String
        if rBack.isError() {
            messageText = rBack.getErrorText()
        } else {
            messageText = NSLocalizedString("AddIndicationVC_SendNewIndication", comment: "Показание успешно переданно")
        }
        DispatchQueue.main.sync {
            showMessageError(view: self, name: "AddIndicationVC", message: messageText)
        }
    }
    
    
    /// Функция обработки события тапа на объекты
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchView = touch.view
        if touchView != nil {
            if touchView!.isEqual(mainVC) {
                moveOut()
            }
        }
        return true
    }
    
    /// Функция обработки события изменение значения в поле показания
    ///
    /// - Parameter sender: Объект вызова
    @objc func textFieldDidChange(_ sender: UITextField) {
        // проверка длины вводимого показания
        if lengthStringValue != 0 {
            let countStr = valueIndicationEdit.text
            if countStr != nil {
                if countStr!.count > lengthStringValue {
                    let countStrNew = countStr!.getSubstringLength(length: lengthStringValue)
                    valueIndicationEdit.text = countStrNew
                }
            }
        }
        // проверка показание на наличие ошибок
        if let editText = valueIndicationEdit.text {
            let errorText = createTextErrorNewValue(last: lastIndication, new: editText, date: newValueDate)
            if errorText != nil {
                infoErrorLabel.text = errorText
                infoErrorLabel.isHidden = false
            } else {
                infoErrorLabel.isHidden = true
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
//        print("2")
//        let keyBoard = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)
//        if keyBoard != nil {
//            let keyBoardSize = keyBoard!.cgRectValue
//            constaintCenterForm.constant = (keyBoardSize.height / 2) * -1
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        print("1")
//        constaintCenterForm.constant = 0
    }
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector((keyboardWillShow(notification:))), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector((keyboardWillHide(notification:))), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setPortableView(vc: self, panel: mainMessagePanel)
        
        valueIndicationEdit.delegate = self
        valueIndicationEdit.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // выводим прошлое показание
        if lastIndication != nil {
            let lastDate = ConverDateToString(date: lastIndication!.countval_date)
            let lastCountval = String(lastIndication!.countval_nval)
            if lastDate != nil {
                lastIndicationLabel.text = lastDate! + " - " + lastCountval
            } else {
                lastIndicationLabel.text = lastCountval
            }
        }
        // выводим дату нового показания
        let newValueDateString = ConverDateToString(date: newValueDate)
        if newValueDateString != nil {
            dateIndicationLabel.text = ConverDateToString(date: newValueDate)
        } else {
            dateIndicationLabel.text = "-"
        }
        moveIn()
    }
    
    /// Функция обработки события нажатия на кнопку отмены
    @IBAction func cancelTouch(_ sender: Any) {
        moveOut()
    }
    
    /// Функция обработки события нажатия на кнопку подтверждения
    @IBAction func sendCountvalTouch(_ sender: Any) {
        let userToken = dataUsers?.getCurrentUser()?.userToken
        if userToken != nil {
            let newValue = Int(valueIndicationEdit.text ?? "")
            if newValue != nil {
                let returnBack = backOffice.newIndication(cplug: cplug_id, date: newValueDate, value: newValue!, token: userToken!, function: newCountval_postFunc)
                if returnBack.isError() {
                    let errorText = returnBack.getErrorText()
                    showMessageError(view: self, name: "AddIndicationVC", message: errorText)
                } else {
                    moveOut()
                }
            } else {
                let AddIndicationVC_ErrorConvertCountval = NSLocalizedString("AddIndicationVC_ErrorConvertCountval", comment: "Ошибка чтения показания")
                showMessageError(view: self, name: "AddIndicationVC", message: AddIndicationVC_ErrorConvertCountval)
            }
        } else {
            let AddIndicationVC_ErrorReadUserToken = NSLocalizedString("AddIndicationVC_ErrorReadUserToken", comment: "Ошибка чтения токена пользователя")
            showMessageError(view: self, name: "AddIndicationVC", message: AddIndicationVC_ErrorReadUserToken)
        }
    }
}
