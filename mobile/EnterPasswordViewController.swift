//
//  EnterPasswordViewController.swift
//  mobile
//
//  Форма авторизации пользователя и ввода пароля
//
//  Created by Groylov on 01/11/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import UIKit

class EnterPasswordViewController: UIViewController {

    @IBOutlet weak var enterPasswordMessage: UILabel!
    @IBOutlet weak var enterPasswordLabel: UILabel!
    @IBOutlet weak var enterButton1: UIButton!
    @IBOutlet weak var enterButton2: UIButton!
    @IBOutlet weak var enterButton3: UIButton!
    @IBOutlet weak var enterButton4: UIButton!
    @IBOutlet weak var enterButton5: UIButton!
    @IBOutlet weak var enterButton6: UIButton!
    @IBOutlet weak var enterButton7: UIButton!
    @IBOutlet weak var enterButton8: UIButton!
    @IBOutlet weak var enterButton9: UIButton!
    @IBOutlet weak var enterButton0: UIButton!
    @IBOutlet weak var enterButtonBackspase: UIButton!
    @IBOutlet weak var enterButtonCancel: UIButton!

    /// Переменная для сохранения пароля
    private var enterPassword: String = ""
    /// Переменная символизирующая, что пройдена биометрическая авторизация
    private var authTouchID: Bool = false
    /// Переменная разрешающая использования авторизации по биометрии
    var accessUseTouchID: Bool = false
    /// Переменная функции, вызываемой после авторизации пользователя или ввода пароля
    var enterPasswordFunction: ((Bool,String,Bool)->Void)? = nil
    /// Строка с информацией при вводе сообщения пользователя
    var messageEnterPassword: String?
    /// Цвет строки с информацией при вводе сообщения пользователя
    var messageEnterPasswordColor: UIColor?
    
    /// Функция визульного тображения ввода пароля
    private func visualEnterPassword() {
        switch enterPassword.count {
        case 4:
            enterPasswordLabel.text = "●    ●    ●    ●"
        case 3:
            enterPasswordLabel.text = "●    ●    ●    ○"
        case 2:
            enterPasswordLabel.text = "●    ●    ○    ○"
        case 1:
            enterPasswordLabel.text = "●    ○    ○    ○"
        case 0:
            enterPasswordLabel.text = "○    ○    ○    ○"
        default:
            break
        }
    }
    
    /// Функция после прохождения биометрической авторизации
    ///
    /// - Parameter returnTouchID: Флаг прохождения биометрической авторизации
    private func returnTouchID_postFunction(_ returnTouchID: Bool) {
        if returnTouchID {
            //DispatchQueue.main.sync {
            //    enterPassword = "0000"
            //    visualEnterPassword()
            //    sleep(1)
            //}
            authTouchID = true
            dismiss(animated: true, completion: nil)
            if enterPasswordFunction != nil {
                enterPasswordFunction!(accessUseTouchID,enterPassword,authTouchID)
            }
        }
    }
    
    /// Функция установки округлости для кнопок
    ///
    /// - Parameter uButton: Кнопка для изменения настроек
    private func setButtonWidthHeight(button uButton: UIButton) {
        uButton.layer.cornerRadius = 0.5 * uButton.bounds.size.width
        uButton.clipsToBounds = true
        uButton.layer.borderWidth = 1
        uButton.layer.borderColor = uButton.tintColor.cgColor
    }
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationColor(self)
        // выводится сообщения для пользователя, если оно есть
        if messageEnterPassword != nil {
            enterPasswordMessage.text = messageEnterPassword!
        } else {
            enterPasswordMessage.text = "Введите код"
        }
        // устанавливается цвет сообщения пользователя
        if messageEnterPasswordColor != nil {
            enterPasswordMessage.textColor = messageEnterPasswordColor!
        } else {
            enterPasswordMessage.textColor = .black
        }
        // Если разрешина авторизация пользователя по биометрии то делаем попытку авторизации. Если авторизация не прошла или биометрия не доступна, то дожидаемся действия пользователя по вводу пароля
        if accessUseTouchID {
            authUser.authUser(returnFunc: returnTouchID_postFunction(_:))
        }
    }
    
    /// Функция обработки события перед рисованием объектов на форме
    override func viewWillLayoutSubviews() {
        setButtonWidthHeight(button: enterButton2)
        setButtonWidthHeight(button: enterButton5)
        setButtonWidthHeight(button: enterButton8)
        setButtonWidthHeight(button: enterButton0)
        setButtonWidthHeight(button: enterButton1)
        setButtonWidthHeight(button: enterButton4)
        setButtonWidthHeight(button: enterButton7)
        setButtonWidthHeight(button: enterButtonCancel)
        setButtonWidthHeight(button: enterButton3)
        setButtonWidthHeight(button: enterButton6)
        setButtonWidthHeight(button: enterButton9)
        setButtonWidthHeight(button: enterButtonBackspase)
    }
    
    /// Функция обработки события нажатия на кнопку с вводом числа
    @IBAction func enterButtonTouch(_ sender: UIButton) {
        tapticEngine()
        if sender.titleLabel != nil {
            enterPassword += sender.titleLabel!.text ?? ""
            visualEnterPassword()
            // Если введено 4 символа пароля, то закрываем форму
            if enterPassword.count == 4 {
                dismiss(animated: true, completion: nil)
                if enterPasswordFunction != nil {
                    enterPasswordFunction!(accessUseTouchID,enterPassword,authTouchID)
                }
            }
        }
    }
    
    /// Функция обработки события нажатия кнопки Назад
    @IBAction func enterBackForm(_ sender: UIButton) {
        tapticEngine()
        enterPassword = ""
        dismiss(animated: true, completion: nil)
        if enterPasswordFunction != nil {
            enterPasswordFunction!(accessUseTouchID,enterPassword,authTouchID)
        }
    }
    
    /// Функция обработки события нажатия кнопки backspace
    @IBAction func enterBackspaseTouch(_ sender: UIButton) {
        tapticEngine()
        if enterPassword.count > 0 {
            enterPassword.remove(at: enterPassword.index(before: enterPassword.endIndex))
            visualEnterPassword()
        }
    }
    
    /// Функция обработки события нажатия кнопки Отмена
    @IBAction func cancelTouch(_ sender: UIButton) {
        tapticEngine()
        enterPassword = ""
        dismiss(animated: true, completion: nil)
        if enterPasswordFunction != nil {
            enterPasswordFunction!(accessUseTouchID,enterPassword,authTouchID)
        }
    }
}
