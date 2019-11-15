//
//  FeedbackViewController.swift
//  mobile
//
//  Created by Groylov on 20/02/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private var keySizeHeight: CGFloat? = nil
    private var imageFile: [UIImage] = []
    @IBOutlet weak var constaintsButtonBottom: NSLayoutConstraint!
    
    @IBOutlet weak var phoneCaption: UITextField!
    @IBOutlet weak var emailCaption: UITextField!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var sendImage1: UIImageView!
    @IBOutlet weak var sendImage2: UIImageView!
    @IBOutlet weak var sendImage3: UIImageView!
    @IBOutlet weak var sendImage4: UIImageView!
    @IBOutlet weak var deleteImageButton1: UIButton!
    @IBOutlet weak var deleteImageButton2: UIButton!
    @IBOutlet weak var deleteImageButton3: UIButton!
    @IBOutlet weak var deleteImageButton4: UIButton!
    
    // функция показа пользователю сообщения об ошибки авторизации
    private func showMessageError(messageText mText: String) {
        let FeedbackVC_messageTile = NSLocalizedString("FeedbackVC_messageTitle", comment: "Заголовок окна заявки")
        let FeedbackVC_messageButtonOkTitle = NSLocalizedString("FeedbackVC_messageButtonOkTitle", comment: "Заголовок кнопки")
        let alertControll = UIAlertController(title: FeedbackVC_messageTile, message: mText,preferredStyle: .alert)
        let alertButtonOk = UIAlertAction(title: FeedbackVC_messageButtonOkTitle, style: .default) { (alert) in
            self.navigationController?.popViewController(animated: true)
        }
        alertControll.addAction(alertButtonOk)
        present(alertControll,animated: true,completion: nil)
    }
    
    private func showQuestionSource() {
        let alertControl = UIAlertController(title: nil, message: "Выберите источник изображения", preferredStyle: .actionSheet)
        let alertButtonCamera = UIAlertAction(title: "Камера", style: .default) { (alert) in
            self.openCamera()
        }
        let alertButtonPhoto = UIAlertAction(title: "Галерея", style: .default) { (alert) in
            self.openGallery()
        }
        let alertButtonCancel = UIAlertAction(title: "Отмена", style: .cancel) { (alert) in
        }
        alertControl.addAction(alertButtonCamera)
        alertControl.addAction(alertButtonPhoto)
        alertControl.addAction(alertButtonCancel)
        present(alertControl, animated: true, completion: nil)
    }
    
    private func refreshImageArray() {
        sendImage1.image = nil
        sendImage2.image = nil
        sendImage3.image = nil
        sendImage4.image = nil
        deleteImageButton1.isHidden = true
        deleteImageButton2.isHidden = true
        deleteImageButton3.isHidden = true
        deleteImageButton4.isHidden = true
        for (index,img) in imageFile.enumerated() {
            if index == 0 {
                sendImage1.image = img
                deleteImageButton1.isHidden = false
            } else if index == 1 {
                sendImage2.image = img
                deleteImageButton2.isHidden = false
            } else if index == 2 {
                sendImage3.image = img
                deleteImageButton3.isHidden = false
            } else if index == 3 {
                sendImage4.image = img
                deleteImageButton4.isHidden = false
            }
        }
    }
    
    private func addImage(image uImage: UIImage) {
        imageFile.append(uImage)
        refreshImageArray()
    }
    
    private func removeImage(index uIndex: Int) {
        imageFile.remove(at: uIndex - 1)
        refreshImageArray()
    }
    
    // функция проверки электронной почты на формат
    private func checkEmailEdit(email uEmail: String?) -> Bool {
        if uEmail != nil {
            let emailText = uEmail!
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
    
    // функция проверки телефона на формат
    private func checkPhoneEdit(phone uPhone: String?) -> Bool {
        if uPhone != nil {
            let phoneText = uPhone!
            if phoneText.isEmpty {
                return false
            }
            // Проверка на длину (допустимо 10,11,12,13)
            if phoneText.count > 13 || phoneText.count < 10 {
                return false
            }
            // Проверка на вхождение символов
            let checkCharacterSet = CharacterSet.init(charactersIn: "0123456789+").inverted
            let returnCheckCharacterSet = phoneText.rangeOfCharacter(from: checkCharacterSet)
            if returnCheckCharacterSet != nil {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    // функция проверки текста сообщения
    private func chechMessageText(text uText: String?) -> Bool {
        if uText == nil {
            return false
        } else {
            if uText!.isEmpty || uText!.count < 6 {
                return false
            } else {
                return true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // настройка дизайна ViewController
        setNavigationColor(self)
        self.hideKeyboard()
        
        let phoneNumber = dataAccount.account_phone
        let emailAddres = dataAccount.account_email
        if phoneNumber != nil {
            phoneCaption.text = phoneNumber
        }
        if emailAddres != nil {
            emailCaption.text = emailAddres
        }
    }
    
    // функция вызова после отправки сообщения на сервер
    func sendMessage_postFunc(_ uMail: String,_ uPhone: String,_ uMessage: String, result uResult: BackOfficeMobileReturn) {
        if !uResult.isError() {
            DispatchQueue.main.sync {
                self.activityIndicator.stopAnimating()
                let FeedbackVC_SendMessage = NSLocalizedString("FeedbackVC_SendMessage", comment: "Сообщение успешно отправлено")
                showMessageError(messageText: FeedbackVC_SendMessage)
            }
        } else {
            DispatchQueue.main.sync {
                self.activityIndicator.stopAnimating()
                let FeedbackVC_ErrorSendMessage = NSLocalizedString("FeedbackVC_ErrorSendMessage", comment: "Ошибка отправки сообщения на сервер")
                showMessageError(messageText: FeedbackVC_ErrorSendMessage)
            }
        }
    }
    
    // функция обработки нажатия на кнопку отправки сообщения
    @IBAction func sendButtonTouch(_ sender: Any) {
        let emailStr = emailCaption.text
        let phoneStr = phoneCaption.text
        let textStr = messageText.text
        
        // проверка электронного адреса
        if !checkEmailEdit(email: emailStr) {
            let FeedbackVC_ErrorEnterEmail = NSLocalizedString("FeedbackVC_ErrorEnterEmail", comment: "Сообщение об ошибке не введенного email")
            showMessageError(messageText: FeedbackVC_ErrorEnterEmail)
            return
        }
        // проверка телефона
        if !checkPhoneEdit(phone: phoneStr) {
            let FeedbackVC_ErrorEnterPhone = NSLocalizedString("FeedbackVC_ErrorEnterPhone", comment: "Сообщение об ошибке не введенного телефона")
            showMessageError(messageText: FeedbackVC_ErrorEnterPhone)
            return
        }
        // проверка информации сообщения
        if !chechMessageText(text: textStr) {
            let FeedbackVC_ErrorMessageText = NSLocalizedString("FeedbackVC_ErrorMessageText", comment: "Сообщение об ошибке не введенного текста сообщения")
            showMessageError(messageText: FeedbackVC_ErrorMessageText)
            return
        }
        // получение токена пользователя
        var userToken: String?
        if dataUsers != nil {
            let currentUser = dataUsers!.getCurrentUser()
            if currentUser != nil {
                userToken = dataUsers!.getCurrentUser()!.userToken
            }
        }
        
        // подготавливаем анимацию процесса загрузки данных
        //view.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        // показываем анимацию загрузки
        activityIndicator.startAnimating()
    
        // отправка запроса на back
        if userToken != nil {
            let returnBack = backOffice.sendFeedbackMessage(phone: phoneStr!, email: emailStr!, message: textStr!, token: userToken!, function: self.sendMessage_postFunc)
            if returnBack.isError() {
                self.activityIndicator.stopAnimating()
                let backErrorCaption = returnBack.getErrorText()
                showMessageError(messageText: backErrorCaption)
            }
        }
    }
    
    @IBAction func touchBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnFromKeyboardClicked() {
        print("Done Button Clicked.")
        //Hide Keyboard by endEditing or Anything you want.
        self.view.endEditing(true)
    }
    
    @IBAction func addImageTouch(_ sender: Any) {
        if imageFile.count < 4 {
            showQuestionSource()
        }
    }
    
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.showsCameraControls = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if image != nil {
            addImage(image: image!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteImage1Touch(_ sender: Any) {
        removeImage(index: 1)
    }
  
    @IBAction func deleteImage2Touch(_ sender: Any) {
        removeImage(index: 2)
    }
    
    @IBAction func deleteImage3Touch(_ sender: Any) {
        removeImage(index: 3)
    }
    
    @IBAction func deleteImage4Touch(_ sender: Any) {
        removeImage(index: 4)
    }
    
}
