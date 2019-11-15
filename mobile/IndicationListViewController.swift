//
//  IndicationListViewController.swift
//  mobile
//
//  Created by Groylov on 06/05/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

/// Класс описания колонки таблицы
class IndicationCell: UITableViewCell {
    
    @IBOutlet weak var indTypeImage: UIImageView!
    @IBOutlet weak var indDateLabel: UILabel!
    @IBOutlet weak var indTypeLabel: UILabel!
    @IBOutlet weak var indValueLabel: UILabel!
}

class IndicationListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var countCplugLabel: UILabel!
    @IBOutlet weak var currentCplugLabel: UILabel!
    @IBOutlet weak var changeCurrentCplug: UIButton!
    @IBOutlet weak var currentCplugTypeLabel: UILabel!
    @IBOutlet weak var currentCplugDisLabel: UILabel!
    @IBOutlet weak var currentCplugCtLabel: UILabel!
    @IBOutlet weak var indicationTable: UITableView!
    
    /// Список приборов учета
    private var listCplug: [StructCplug] = []
    /// Текущий прибор учета отображения показаний
    private var currentCplug: StructCplug?
    /// Список показаний текущего прибора учета
    private var listCountval: [StructCountval] = []
    
    /// Функция обновления отображения данных на форме
    private func refreshVisualShow() {
        // указываем количество приборов учета
        if listCplug.count > 1 {
            let countCplug = String(listCplug.count)
            countCplugLabel.text = "x" + countCplug
            countCplugLabel.isHidden = false
            changeCurrentCplug.isEnabled = true
        } else {
            countCplugLabel.isHidden = true
            changeCurrentCplug.isEnabled = false
        }
        // если текущий прибор учета выбран, отображаем данные о приборе и его наименование
        if currentCplug != nil {
            currentCplugLabel.text = currentCplug!.getCplugName()
            currentCplugTypeLabel.text = currentCplug!.countype_abbr
            currentCplugDisLabel.text = String(currentCplug!.digits)
            currentCplugCtLabel.text = String(currentCplug!.ct)
        } else {
            currentCplugLabel.text = "Нет прибора учета"
            currentCplugTypeLabel.text = "-"
            currentCplugDisLabel.text = "-"
            currentCplugCtLabel.text = "-"
        }
    }
    
    /// Функция обновления данных и таблицы с показаниями
    ///
    /// - Parameter cCplug: текущий прибор учета для отбора показаний
    private func loadDataArray(currentCplug cCplug: StructCplug?) {
        listCplug = dataAccount.cplugs
        if cCplug == nil {
            if listCplug.count > 0 {
                currentCplug = listCplug[0]
            } else {
                currentCplug = nil
            }
        } else {
            currentCplug = cCplug
        }
        if currentCplug != nil {
            listCountval = currentCplug!.getCountvalCplug(arrayCountval: dataAccount.countvals)
        } else {
            listCountval = []
        }
        indicationTable.reloadData()
    }
    
    /// Функция получение последнего показания в прошлом месяце
    ///
    /// - Parameter arrayValue: Отсортированный по убыванию даты массив всех показаний
    /// - Returns: Возвращается последнее ближайшее показание в прошлом месяце
    private func getEndCountval(array arrayValue: [StructCountval]) -> StructCountval? {
        let currentDateBegin = Date().startOfMonth()
        if currentDateBegin != nil {
            for recValue in arrayValue {
                if recValue.countval_date < currentDateBegin! {
                    return recValue
                }
            }
        }
        return nil
    }
    
    /// Функция выполняемая после выбора нового прибора учета
    ///
    /// - Parameter cCplug: Выбанный прибор учета
    func postFunc_ChangeCplug(currentCplug cCplug: StructCplug?) {
        loadDataArray(currentCplug: cCplug)
        refreshVisualShow()
    }
    
    /// Функция открытия окна выбора прибора учета
    @objc func openChangeCplug() {
        if listCplug.count > 1 {
            if let changeCplagVC = storyboard!.instantiateViewController(withIdentifier: "changeCplagViewController") as? ChangeCplagViewController {
                changeCplagVC.arrayCplug = listCplug
                changeCplagVC.postFunction = postFunc_ChangeCplug(currentCplug:)
                self.addChild(changeCplagVC)
                changeCplagVC.view.frame = self.view.frame
                self.view.addSubview(changeCplagVC.view)
                changeCplagVC.didMove(toParent: self)
            }
        }
    }
    
    /// Функция обработки события открытия формы
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настройка дизайна ViewController
        setNavigationColor(self)
        
        loadDataArray(currentCplug: nil)
        refreshVisualShow()
    }
    
    /// функция обработки события открытия окна
    override func viewDidAppear(_ animated: Bool) {
        let touchCplug: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.changeCplugTouch(_:)))
        currentCplugLabel.isUserInteractionEnabled = true
        currentCplugLabel.addGestureRecognizer(touchCplug)
        loadDataArray(currentCplug: nil)
        refreshVisualShow()
    }
    
    /// Функция обработки события нажатия кнопки добавления показания
    @IBAction func addNewIndication(_ sender: UIButton) {
        if let addIndicationVC = storyboard!.instantiateViewController(withIdentifier: "addIndicationViewController") as? AddIndicationViewController {
            if currentCplug != nil {
                let endCountval = getEndCountval(array: listCountval)
                addIndicationVC.lastIndication = endCountval
                addIndicationVC.lengthStringValue = currentCplug!.digits
                self.addChild(addIndicationVC)
                addIndicationVC.view.frame = self.view.frame
                self.view.addSubview(addIndicationVC.view)
                addIndicationVC.didMove(toParent: self)
            }
        }
    }
    
    /// Функция обработки события нажатия на кнопку закрытия окна
    @IBAction func exitButtonTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Функция обработки события нажатия на кнопку выбора прибора учета
    @IBAction func changeCplugTouch(_ sender: Any) {
        openChangeCplug()
    }    
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCountval.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = indicationTable.dequeueReusableCell(withIdentifier: "IndicationCell",for: indexPath) as! IndicationCell
        if listCountval.endIndex >= indexPath.row {
            let currentCplugValue = listCountval[indexPath.row]
            // получение даты показания
            let dateCaptionInd = ConverDateToString(date: currentCplugValue.countval_date)
            if dateCaptionInd != nil {
                cell.indDateLabel.text = dateCaptionInd!
            } else {
                cell.indDateLabel.text = "-"
            }
            // получение типа показания
            let typeCaptionInd = currentCplugValue.getCvaltypeString(cvaltype: dataAccount.cvaltypes)
            if typeCaptionInd != nil {
                cell.indTypeLabel.text = typeCaptionInd!
            } else {
                cell.indTypeLabel.text = "-"
            }
            // получение изображения типа показания
            let typeCategoryInd = currentCplugValue.getCvaltypeCategoty(cvaltype: dataAccount.cvaltypes) ?? 0
            let categoryImg = UIImage(named: "IndicationCategory_"+String(typeCategoryInd))
            if categoryImg != nil {
                cell.indTypeImage.image = categoryImg
                cell.indTypeImage.highlightedImage = categoryImg?.maskWithColor(color: .gray)
            }
            // получение значение показания
            cell.indValueLabel.text = String(currentCplugValue.countval_nval)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indicationTable.deselectRow(at: indexPath, animated: true)
    }
}



