//
//  CreatePaymentViewController.swift
//  mobile
//
//  Created by Groylov on 22/04/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit
import SafariServices

/// Класс описание колонок таблицы оплат
class ServiceCustomCell: UITableViewCell,UITextFieldDelegate {
    
    var service_id: Int?
    var lastEdit: String = ""
    var mainViewController: CreatePaymentViewController?
    @IBOutlet weak var summEdit: UITextField!
    @IBOutlet weak var serviceLabel: UILabel!
    
    private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Оплатить", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        summEdit.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        if mainViewController != nil {
            mainViewController!.nextButtonTouch()
        }
    }
    
    func initializacion() {
        summEdit.delegate = self
        summEdit.addTarget(self,action: #selector(textFieldDidChange), for: .editingChanged)
        addDoneButtonOnKeyboard()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {   
        var textEdit: String? = summEdit.text
        if textEdit != nil {
            // обрезка до двух символов после запятой
            let textEditDouble: Double = localStringToDouble(textEdit!) ?? 0
            if textEditDouble != 0 {
                let textDouble2 = String.localizedStringWithFormat("%.2f", textEditDouble)
                let textEditDouble2 = localStringToDouble(textDouble2)
                if (textEditDouble != textEditDouble2) || (textDouble2.count < textEdit!.count) {
                    textEdit = lastEdit
                }
            }
            
            textEdit = textEdit!.replace(old: ".", new: ",")
            
            // не более восьми символов в строке
            if textEdit!.count > 8 {
                textEdit = textEdit!.getSubstringLength(length: 8)
            }
            // если значение 0 то делаем поле пустым
            if textEdit! == "0" {
                textEdit = ""
            }
            
            // проверка на начало строки с ,
            if textEdit! == "," {
                textEdit = "0,"
            }

            // проверяем что бы небыло повторений точек
            let countPoint = textEdit!.countChar(char: ".")
            if countPoint > 1 {
                textEdit = lastEdit
            }
            let countPoint2 = textEdit!.countChar(char: ",")
            if countPoint2 > 1 {
                textEdit = lastEdit
            }
            summEdit.text = textEdit!
            lastEdit = textEdit!
            // расчет общей суммы по всем услугам
            if mainViewController != nil {
                if service_id != nil {
                    let sumDouble: Double = localStringToDouble(textEdit!) ?? 0
                        mainViewController!.enterCellSumm(service: service_id!,summ: sumDouble)
                        mainViewController!.enterItogSumm()
                }
            }
        }
    }
}

class CreatePaymentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var serviceCode: [StructService]?
    var serviceBalance: [StructServiceBalance]?
    private var closeFormSelf: Bool = false
    
    @IBOutlet weak var tableServices: UITableView!
    @IBOutlet weak var itogLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    
    private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    private func showMessageError(messageText mText: String) {
        let LoginVC_messageTitle = NSLocalizedString("CreatePaymentVC_messageTitle", comment: "Авторизация")
        let LoginVC_messageButtonOkTitle = NSLocalizedString("CreatePaymentVC_messageButtonOkTitle", comment: "Ок")
        let alertControll = UIAlertController(title: LoginVC_messageTitle, message: mText,preferredStyle: .alert)
        let alertButtonOk = UIAlertAction(title: LoginVC_messageButtonOkTitle, style: .default) { (alert) in
        }
        alertControll.addAction(alertButtonOk)
        present(alertControll,animated: true,completion: nil)
    }
    
    private func getBalanceOfService(service serviceId: Int) -> Double {
        if serviceBalance != nil {
            for balance in serviceBalance! {
                if balance.service_id == serviceId {
                    if balance.balance < 0 {
                        return balance.balance * -1
                    } else {
                        return 0
                    }
                }
            }
        }
        return 0
    }
    
    private func getServiceNameByCode(service serviceId: Int) -> String? {
        if serviceCode != nil {
            for serv in serviceCode! {
                if serv.service_id == serviceId {
                    return serv.service_name
                }
            }
        }
        return nil
    }
    
    private func calcItogSumm() -> Double {
        var returnSumm: Double = 0
        if serviceBalance != nil {
            for balance in serviceBalance! {
                if balance.balance < 0 {
                    returnSumm += balance.balance * -1
                }
            }
        }
        return returnSumm
    }
    
    func nextButtonTouch() {
        let itogSumm = calcItogSumm()
        if itogSumm < 1 {
            let CreatePaymentVC_ErrorItogSummMin = NSLocalizedString("CreatePaymentVC_ErrorItogSummMin",comment: "Сумма оплаты меньше минимальной")
            showMessageError(messageText: CreatePaymentVC_ErrorItogSummMin)
            return
        }
        if itogSumm > 29999 {
            let CreatePaymentVC_ErrorItogSummMax = NSLocalizedString("CreatePaymentVC_ErrorItogSummMax",comment: "Сумма оплаты больше максимальной")
            showMessageError(messageText: CreatePaymentVC_ErrorItogSummMax)
            return
        }
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        // показываем анимацию загрузки
        activityIndicator.startAnimating()
        // подготовка данных для бэка
        let accountPhone = dataAccount.account_phone ?? ""
        let accountEmail = dataAccount.account_email ?? ""
        var serviceSumm: [PaymentServices] = []
        if serviceBalance != nil {
            for servBalance in serviceBalance! {
                if servBalance.balance != 0 && servBalance.balance < 0 {
                    let newRecordPayment = PaymentServices(code: servBalance.getServiceCode(arrayServices: dataAccount.services), summary: servBalance.balance * -1)
                    serviceSumm.append(newRecordPayment)
                }
            }
            if serviceSumm.count != 0 {
                let returnBack = backOffice.addNewPayment(accountOrg: dataAccount.account_org_id, phone: accountPhone, email: accountEmail, account: dataAccount.account_no, services: serviceSumm, function: self.enterPayment_PostFunc(account:service:return:))
                if returnBack.isError() {
                    let textError = returnBack.getErrorText()
                    showMessageError(messageText: textError)
                    activityIndicator.stopAnimating()
                }
            } else {
                let CreatePaymentVC_ErrorReadItogSumm = NSLocalizedString("CreatePaymentVC_ErrorReadItogSumm", comment: "Ошибка получения баланса по услугам")
                showMessageError(messageText: CreatePaymentVC_ErrorReadItogSumm)
                activityIndicator.stopAnimating()
            }
        }
        else {
            let CreatePaymentVC_ErrorReadItogSumm = NSLocalizedString("CreatePaymentVC_ErrorReadItogSumm", comment: "Ошибка получения баланса по услугам")
            showMessageError(messageText: CreatePaymentVC_ErrorReadItogSumm)
            activityIndicator.stopAnimating()
        }
    }
    
    func enterItogSumm() {
        let uSumm = calcItogSumm()
        let summ = String.localizedStringWithFormat("%.2f", uSumm)
        itogLabel.text = "Итого к оплате: " + summ + " ₽"
    }
    
    func enterCellSumm(service serviceId: Int,summ uSumm: Double) {
        if serviceBalance != nil {
            var servIndex: Int = 0
            for serv in serviceBalance! {
                if serv.service_id == serviceId {
                    var newRecordService = serv
                    newRecordService.balance = uSumm * -1
                    serviceBalance![servIndex] = newRecordService
                    return
                }
                servIndex += 1
            }
            var serviceName = getServiceNameByCode(service: serviceId)
            if serviceName == nil {
                serviceName = ""
            }
            let newRecordBalance = StructServiceBalance(id: serviceId, name: serviceName!, balance: uSumm * -1)
            serviceBalance!.append(newRecordBalance)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        
        // настройка дизайна ViewController
        setNavigationColor(self)
        
        serviceCode = dataAccount.services
        
        accountLabel.text = dataAccount.account_no
        adressLabel.text = dataAccount.account_addr
        serviceBalance = dataAccount.getServiceBalance()
        tableServices.reloadData()
        enterItogSumm()
    }
    
    func enterPayment_PostFunc(account uAccount: String, service uService: [PaymentServices], return uReturn: BackOfficeMobileReturn) {
        DispatchQueue.main.sync {
            self.activityIndicator.stopAnimating()
        }
        if uReturn.isError() {
            let errorText = uReturn.getErrorText()
            showMessageError(messageText: errorText)
        } else {
            let urlPayment = uReturn.getReturnData() as? String
            if urlPayment != nil {
                let urlAdress = URL(string: urlPayment!)
                if urlAdress != nil {
                    print(urlPayment!)
                    DispatchQueue.main.sync {
                        if UIApplication.shared.canOpenURL(urlAdress!) {
                            let safariVC = SFSafariViewController(url: urlAdress!)
                            present(safariVC,animated: true,completion: nil)
                            closeFormSelf = true
                        }
                    }
                }
            } else {
                let CreatePaymentVC_ErrorReadUrlResult = NSLocalizedString("CreatePaymentVC_ErrorReadUrlResult",comment: "Ошибка получения ссылки на оплату")
                showMessageError(messageText: CreatePaymentVC_ErrorReadUrlResult)
            }
        }
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if serviceCode != nil {
            return serviceCode!.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableServices.dequeueReusableCell(withIdentifier: "tableServicesCell", for: indexPath) as! ServiceCustomCell
        cell.initializacion()
        
        if serviceCode != nil {
            let servName = serviceCode![indexPath.row].service_name
            let servId = serviceCode![indexPath.row].service_id
            cell.service_id = servId
            cell.mainViewController = self
            if servName != nil {
                cell.serviceLabel?.text = servName!
            } else {
                cell.serviceLabel?.text = "-"
            }
            let servBalance = getBalanceOfService(service: servId)
            if servBalance != 0 {
                cell.summEdit.text = String.localizedStringWithFormat("%.2f", servBalance)
            }
        }
        return cell
    }
    
    // функция обработки события открытия окна
    override func viewDidAppear(_ animated: Bool) {
        if closeFormSelf {
            dismiss(animated: true, completion: nil)
            closeFormSelf = false
        } else {
            accountLabel.text = dataAccount.account_no
            adressLabel.text = dataAccount.account_addr
            serviceBalance = dataAccount.getServiceBalance()
            tableServices.reloadData()
            enterItogSumm()
        }
    }
    
    @IBAction func cancelButtonTouch(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextSteepTouch(_ sender: UIButton) {
        nextButtonTouch()
    }
    
}
