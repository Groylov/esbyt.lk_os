//
//  ChangeCplagViewController.swift
//  mobile
//
//  Created by Groylov on 07/05/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class ChangeCplagViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    /// Список приборов учета для выбора
    var arrayCplug: [StructCplug] = []
    /// Функция, вызываемая после выбора прибора учета
    var postFunction: ((StructCplug?) -> Void)? = nil
    /// Текущий прибор учета в списке выбора
    var currentCplug: StructCplug? = nil
    
    @IBOutlet var outletVC: UIView!
    @IBOutlet weak var mainMessagePanel: UIView!
    
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
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        setPortableView(vc: self, panel: mainMessagePanel)
        moveIn()
    }
    
    /// Функция обработки события нажатия кнопки выбора прибора учета
    @IBAction func changeButtonTouch(_ sender: UIButton) {
        moveOut()
        if postFunction != nil {
            postFunction!(currentCplug)
        }
    }
    
    // MARK: - Picker Delegate
    
    /// Функция определения количества выбираемых элементов
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Функция определения количества элементов в списке выбора
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayCplug.count
    }
    
    /// Функция вывода элемента в список выбора
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayCplug[row].getCplugName()
    }
    
    /// Функция выбора элемента из списка
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCplug = arrayCplug[row]
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
