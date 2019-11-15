//
//  DetailMapViewController.swift
//  mobile
//
//  Created by Groylov on 08/05/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class DetailMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var mainVC: UIView!
    @IBOutlet weak var mainViewPanel: UIView!
    @IBOutlet weak var mainNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var worktimeLabel: UILabel!
    @IBOutlet weak var phone1Label: UILabel!
    @IBOutlet weak var phone2Label: UILabel!
    @IBOutlet weak var phone3Label: UILabel!
    
    @IBOutlet weak var informationImage: UIImageView!
    @IBOutlet weak var worktimeImage: UIImageView!
    @IBOutlet weak var phone1Image: UIImageView!
    @IBOutlet weak var phone2Image: UIImageView!
    @IBOutlet weak var phone3Image: UIImageView!
    
    @IBOutlet weak var constraintPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintMainNameBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintAddresBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintDistanceBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInformationBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInformationImageBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintWorktimeBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintWorktimeImageBottom: NSLayoutConstraint!
    @IBOutlet weak var costaintPhone1Bottom: NSLayoutConstraint!
    @IBOutlet weak var constaintPhone1ImageBottom: NSLayoutConstraint!
    @IBOutlet weak var constaintPhone2Bottom: NSLayoutConstraint!
    @IBOutlet weak var constaintPhone2ImageBottom: NSLayoutConstraint!
    @IBOutlet weak var constaintPhone3Bottom: NSLayoutConstraint!
    @IBOutlet weak var constaintPhone3ImageBottom: NSLayoutConstraint!
    
    /// Объект о котором выводится информация
    var mapData: StructMap?
    /// Растояние от текущего местоположения пользователя до выводимого объекта
    var distancionMap: Int?
    
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
    
    /// Функция вывода информации о телефоне на панель
    ///
    /// - Parameters:
    ///   - uPhone: Значение телефона для вывода
    ///   - pLabel: Объект для вывода телефона
    ///   - pImage: Объект вывода изображения телефона
    ///   - constLabel: Ограничение расположения надписи телефона
    ///   - constImage: Ограничение расположения изображения телефона
    ///   - delta: Сдвиг надписей и изображений относительно начальной позиции
    /// - Returns: Изменение сдвига относительно начального положения объектов формы
    private func printArrayPhone(phone uPhone: String?, label pLabel: UILabel, image pImage: UIImageView, constraintLabel constLabel: NSLayoutConstraint, constraintImage constImage: NSLayoutConstraint, constDelta delta: CGFloat) -> CGFloat {
        var returnDelta: CGFloat = 0
        // если телефон для вывода есть - то он выводится в объект. Если телефона нет, то объекты скрываются, а сдвиг увеличивается на размер надписи + 8 (размер растояния между надписями)
        if uPhone != nil {
            let readPhone1String = uPhone!.deleteFerstSpace()
            pLabel.text = readPhone1String
            pLabel.isHidden = false
            pImage.isHidden = false
            constLabel.constant -= delta
            constImage.constant -= delta
        } else {
            pLabel.isHidden = true
            pImage.isHidden = true
            returnDelta = pLabel.frame.height + 8
        }
        return returnDelta
    }
    
    /// Функция вывода информации об объекте в форму и корректировка расположения (размеров) объектов в зависимовти от наличия полей с информацией
    private func loadVisualDataVC() {
        // заполнение растояния до точки
        if distancionMap != nil {
            var distanceString: String = ""
            if distancionMap! > 1000 {
                let distanceDouble = Double(distancionMap!) / 1000
                distanceString = String.localizedStringWithFormat("%.2f",distanceDouble) + "км."
            } else {
                distanceString = String(distancionMap!) + " м."
            }
            distanceLabel.text = distanceString
        } else {
            distanceLabel.text = ""
        }
        // заполнение информации о точке
        if mapData != nil {
            var constaintDelta: CGFloat = 0
            
            let mainNameString = mapData?.title ?? ""
            let addresString = mapData?.addr ?? ""
            let informatString = mapData?.description ?? ""
            let allPhoneString = mapData?.phone ?? ""
            let worktimeString = mapData?.worktime ?? ""
            // вывод наименования
            if !mainNameString.isEmpty {
                mainNameLabel.text = mainNameString
            } else {
                mainNameLabel.text = ""
            }
            // вывод адреса
            if !addresString.isEmpty {
                addresLabel.text = addresString
            } else {
                addresLabel.text = ""
            }
            // вывод информации о телефонах
            var readPhone1String: String?
            var readPhone2String: String?
            var readPhone3String: String?
            if !allPhoneString.isEmpty {
                let phoneArray = allPhoneString.components(separatedBy: ";")
                if phoneArray.count > 3 {
                    readPhone1String = phoneArray[0]
                    readPhone2String = phoneArray[1]
                    readPhone3String = phoneArray[2]
                } else if phoneArray.count == 2 {
                    readPhone1String = phoneArray[0]
                    readPhone2String = phoneArray[1]
                } else if phoneArray.count == 1 {
                    readPhone1String = phoneArray[0]
                }
            }
            constaintDelta += printArrayPhone(phone: readPhone3String, label: phone3Label, image: phone3Image,constraintLabel: constaintPhone3Bottom, constraintImage: constaintPhone3ImageBottom, constDelta: constaintDelta)
            constaintDelta += printArrayPhone(phone: readPhone2String, label: phone2Label, image: phone2Image, constraintLabel: constaintPhone2Bottom, constraintImage: constaintPhone2ImageBottom, constDelta: constaintDelta)
            constaintDelta += printArrayPhone(phone: readPhone1String, label: phone1Label, image: phone1Image, constraintLabel: costaintPhone1Bottom, constraintImage: constaintPhone1ImageBottom, constDelta: constaintDelta)
            // вывод информации о рабочем времени
            if !worktimeString.isEmpty {
                //worktimeLabel.text = "Привет \n меня \n"
                let newWorktimeString = worktimeString.replacingOccurrences(of: "\\n", with: "\n")
                worktimeLabel.text = newWorktimeString
                worktimeLabel.isHidden = false
                worktimeImage.isHidden = false
            } else {
                worktimeLabel.isHidden = true
                worktimeImage.isHidden = true
                constaintDelta += informationLabel.frame.height
            }
            // изменение полложения информации о рабочем времени
            constraintWorktimeBottom.constant = constraintWorktimeBottom.constant - constaintDelta
            constraintWorktimeImageBottom.constant = constraintWorktimeImageBottom.constant - constaintDelta
            // вывод информации
            if !informatString.isEmpty {
                informationLabel.text = informatString
                informationLabel.isHidden = false
                informationImage.isHidden = false
            } else {
                informationLabel.isHidden = true
                informationImage.isHidden = true
                constaintDelta += informationLabel.frame.height
            }
            // изменение положения информации
            constraintInformationBottom.constant = constraintInformationBottom.constant - constaintDelta
            constraintInformationImageBottom.constant = constraintInformationImageBottom.constant - constaintDelta
            
            // изменение настроек constaint с учетом отображаемых полей
            constraintPanelHeight.constant = constraintPanelHeight.constant - constaintDelta
            constraintMainNameBottom.constant = constraintMainNameBottom.constant - constaintDelta
            constraintAddresBottom.constant = constraintAddresBottom.constant - constaintDelta
            constraintDistanceBottom.constant = constraintDistanceBottom.constant - constaintDelta
        }
    }
    
    /// Функция набора номера телефона
    ///
    /// - Parameter textPhone: Строка, содержащая номер телефона
    private func callPhone(phone textPhone: String?) {
        if textPhone != nil {
            let phoneNumber = "tel://" + textPhone!.filter("01234567890".contains)
            let nsurlPhone = NSURL(string: phoneNumber)
            if nsurlPhone != nil {
                let urlPhone = nsurlPhone!.absoluteURL
                if urlPhone != nil {
                    if UIApplication.shared.canOpenURL(urlPhone!) {
                        UIApplication.shared.open(urlPhone!, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    /// Функция обработки события открытия окна
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // устанавливаем обработку нажатия на надпись с телефоном 1
        let tachPhoneNumber1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(callPhone1))
        phone1Label.isUserInteractionEnabled = true
        phone1Label.addGestureRecognizer(tachPhoneNumber1)
        // устанавливаем обработку нажатия на надпись с телефоном 2
        let tachPhoneNumber2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(callPhone2))
        phone2Label.isUserInteractionEnabled = true
        phone2Label.addGestureRecognizer(tachPhoneNumber2)
        // устанавливаем обработку нажатия на надпись с телефоном 3
        let tachPhoneNumber3: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(callPhone3))
        phone3Label.isUserInteractionEnabled = true
        phone3Label.addGestureRecognizer(tachPhoneNumber3)
        
        setPortableView(vc: self, panel: mainViewPanel)
        self.loadVisualDataVC()
        moveIn()
        
    }

    /// Функция обработки события нажатия на надпись телефона 1
    @objc func callPhone1() {
        callPhone(phone: phone1Label?.text)
    }
    
    /// Функция обработки события нажатия на надпись телефона 2
    @objc func callPhone2() {
        callPhone(phone: phone2Label?.text)
    }
    
    /// Функция обработки события нажатия на надпись телефона 3
    @objc func callPhone3() {
        callPhone(phone: phone3Label?.text)
    }
    
    // MARK: - Gesture Recognizer Delegate
    
    /// Функция обработки события тапа
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchView = touch.view
        if touchView != nil {
            if touchView!.isEqual(self.view) {
                moveOut()
            }
        }
        return true
    }
}
