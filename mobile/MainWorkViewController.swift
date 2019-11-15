//
//  MainWorkViewController.swift
//  mobile
//
//  Created by Groylov on 05/02/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class MainWorkViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var payCaptionText: UILabel!
    @IBOutlet weak var mainPayCaptionText: UILabel!
    @IBOutlet weak var headlineView: UIView!
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var forPaymentRubLabel: UILabel!
    @IBOutlet weak var forPaymentKopLabel: UILabel!
    @IBOutlet weak var refreshDateLabel: UILabel!
    @IBOutlet weak var buttonsPanelView: UIView!
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var indicationButton: UIButton!
    @IBOutlet weak var indicationLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var accountCaption: UILabel!
    @IBOutlet weak var accountAddresCaption: UILabel!
    @IBOutlet weak var accountFioCaption: UILabel!
    @IBOutlet weak var debtTable: UITableView!
    @IBOutlet weak var perscountCaption: UILabel!
    @IBOutlet weak var factcountCaption: UILabel!
    @IBOutlet weak var roomcountCaption: UILabel!
    @IBOutlet weak var areaCaption: UILabel!
    @IBOutlet weak var accountCategoryCaption: UILabel!
    @IBOutlet weak var tarifNameLabel: UILabel!
    @IBOutlet weak var tarifNormLabel: UILabel!
    @IBOutlet weak var tarifUpNormLabel: UILabel!
    @IBOutlet weak var refreshAnimation: UIActivityIndicatorView!
    
    @IBOutlet weak var constPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var constDebtTable: NSLayoutConstraint!
    @IBOutlet weak var constUsersButton: NSLayoutConstraint!
    @IBOutlet weak var constForPaymentRub: NSLayoutConstraint!
    @IBOutlet weak var constForPaymentCop: NSLayoutConstraint!
    @IBOutlet weak var constPayCatpionText: NSLayoutConstraint!
    
    @IBOutlet weak var advertisingPanel: UIView!
    @IBOutlet weak var debtCaptionView: UIView!
    
    /// Список долгов с разбивкой по услугам
    private var serviceBalanceTable: [StructServiceBalance] = []
    
    /// Функция настроек кнопок центральной панели
    ///
    /// - Parameters:
    ///   - uButton: Кнопка для настройки
    ///   - imageName: Изображение для нанесения на кнопку
    ///   - uLabel: Надпись, используемая для создания тени кнопки
    private func settingButtonsView(button uButton: UIButton, image imageName: String?, label uLabel: UILabel?) {
        // добавляем объект для создания тени
        if uLabel != nil {
            uLabel!.backgroundColor = UIColor.black
            uLabel!.layer.cornerRadius = 5
            uLabel!.layer.shadowRadius = 6
            uLabel!.layer.shadowOpacity = 0.5
            uLabel!.layer.shadowOffset = CGSize(width: 0, height: 15)
            uLabel!.layer.shadowColor = color_button_dark.cgColor
        }
        // градиент
        uButton.applyGradient(colours: [color_button_ligth,color_button_dark], locations: [0.1,1.5])
        // округляем углы
        uButton.layer.cornerRadius = uButton.frame.size.height * 0.1
        uButton.clipsToBounds = true
        uButton.layer.borderWidth = 0
        // добавляем изображение на кнопку
        if imageName != nil {
            let buttonImage = UIImageView()
            let loadImage = UIImage(named: imageName!)
            if loadImage != nil {
                buttonImage.image = loadImage!.maskWithColor(color: UIColor.white)
                let sizeImageButton = uButton.bounds.width/4
                let imageBounds = CGRect(x: sizeImageButton/3, y: sizeImageButton/3, width: 25, height: 25)
                buttonImage.frame = imageBounds
                uButton.addSubview(buttonImage)
            }
        }
    }
    
    private func animationStartStop(start animat: Bool) {
        refreshDateLabel.isHidden = animat
        refreshAnimation.isHidden = !animat
        if animat {
            refreshAnimation.startAnimating()
        } else {
            refreshAnimation.stopAnimating()
        }
    }
    
    func refreshData(_ checkDate: Bool = true) {
        let updateDate = dataAccount.update_time
        let currentDate = Date()
        let deltaDate = Double(currentDate.timeIntervalSince(updateDate))
        if deltaDate > 120 || !checkDate {
            let currentUser = dataUsers?.getCurrentUser()
            if currentUser != nil {
                animationStartStop(start: true)
                let accountData = currentUser!.userName
                let tokenData = currentUser!.userToken
                let returnBack = backOffice.getFullDataAccount(account: accountData, token: tokenData, function: refreshData_postFunc)
                if returnBack.isError() {
                    animationStartStop(start: false)
                    let errorText = returnBack.getErrorText()
                    showMessageError(view: self, name: "MainWorkVC", message: errorText)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.refreshUpdateDateLabel()
            }
        }
    }
    
    func refreshData_postFunc(account uAccount: String, token uToken: String, return returnData: BackOfficeMobileReturn) {
        DispatchQueue.main.sync {
            animationStartStop(start: false)
        }
        if returnData.isError() {
            let errorText = returnData.getErrorText()
            DispatchQueue.main.sync {
                showMessageError(view: self, name: "MainWorkVC", message: errorText)
            }
        } else {
            refreshVisualDataVC()
        }
    }
    
    private func refreshUpdateDateLabel() {
        // надпись последнего обновления данных
        let dateRefresh = dataAccount.update_time
        let currentDate = Date()
        let yesterday = Calendar.current.startOfDay(for: Date())
        let beforeYesterday = Calendar.current.startOfDay(for: yesterday-1)
        let dateFormatePrint = DateFormatter()
        if dateRefresh < yesterday {
            // не сегодня
            if dateRefresh < beforeYesterday {
                // позже чем вчера выводим дату
                dateFormatePrint.dateFormat = "Обновлено dd.MM.yyyy"
            } else {
                // вчера выводим слово вчера и время
                dateFormatePrint.dateFormat = "Обновлено вчера в HH:mm:ss"
            }
        } else {
            // сегодня если меньше 10 сек - выводим сейчас
            let diffDate = Double(currentDate.timeIntervalSince(dateRefresh))
            if diffDate < 10 {
                dateFormatePrint.dateFormat = "Обновлено только что"
            } else if diffDate > 10 && diffDate <= 60 {
                dateFormatePrint.dateFormat = "Обновлено " + String(format: "%.0f", diffDate.rounded(.down))+" сек. назад"
            } else if diffDate > 60 && diffDate <= 60 * 60 {
                let diffMinute: Double = diffDate/60
                dateFormatePrint.dateFormat = "Обновлено " +
                    String.localizedStringWithFormat("%.0f",diffMinute.rounded(.down))+" мин. назад"
            } else {
                let diffHour: Double = diffDate / (60*60)
                dateFormatePrint.dateFormat = "Обновлено " + String.localizedStringWithFormat("%.0f",diffHour.rounded(.down))+" ч. назад"
            }
            
        }
        refreshDateLabel.text = dateFormatePrint.string(from: dateRefresh)

    }
    
    // функция обновления отображения данных в форме
    func refreshVisualData() {
        // обновляем данные в таблице баланса по услугам
        serviceBalanceTable = dataAccount.getServiceBalance()
        // если баланса по услугам нет - скрываем таблицу и надпись
        if serviceBalanceTable.count == 0 {
            debtCaptionView.isHidden = true
            debtTable.isHidden = true
        } else {
            debtCaptionView.isHidden = false
            debtTable.isHidden = false
        }
        // изменяем размер таблицы под содержимое
        var f: CGRect = debtTable.frame
        f.size.height = debtTable.contentSize.height
        debtTable.frame = f
        constDebtTable.constant = f.size.height
        
        // формируем итоговую сумму к оплате
        var paySumm: Double = 0.0
        for cRecord in serviceBalanceTable {
            if cRecord.balance < 0 {
                paySumm += cRecord.balance
            }
        }
        paySumm *= -1
        paySumm = roundDoubleRub(paySumm)
        // если есть сумма к оплате - делим ее на рубли и копейки
        if paySumm > 0 {
            paySumm = roundDoubleRub(paySumm)
            mainPayCaptionText.text = "К оплате: "+String(format: "%.2f", paySumm)+" ₽"
            let summRub = paySumm.rounded(.down)
            let summKop = (paySumm - summRub) * 100
            let summRubString = String(format: "%.0f", summRub)
            let summKopString = String(format: "%.0f", summKop)
            forPaymentRubLabel.text = summRubString
            if summKopString.count == 2 {
                forPaymentKopLabel.text = "," + summKopString + " ₽"
            } else if summKopString.count == 1 {
                forPaymentKopLabel.text = ",0" + summKopString + " ₽"
            } else {
                forPaymentKopLabel.text = ",00 ₽"
            }
        } else {
            mainPayCaptionText.text = "К оплате: 0,00 ₽"
            forPaymentRubLabel.text = "0"
            forPaymentKopLabel.text = ",00 ₽"
        }
        
        refreshUpdateDateLabel()
        
        // выводим данные по лицевому
        accountCaption.text = dataAccount.account_no
        accountAddresCaption.text = dataAccount.account_addr
        accountFioCaption.text = dataAccount.account_fio
        
        // выводим тариф лицевого счета
        if dataAccount.account_tarif != nil {
            let tarifName = dataAccount.account_tarif!.tarifName
            if tarifName != nil {
                tarifNameLabel.text = dataAccount.account_tarif!.tarifName!
            }
            tarifNormLabel.text = String.localizedStringWithFormat("%0.2f", dataAccount.account_tarif!.tarif1)
            tarifUpNormLabel.text = String.localizedStringWithFormat("%0.2f", dataAccount.account_tarif!.tarif2)
        }
        
        // выводим параметры расчета лицевого счета
        if dataAccount.account_perscount != nil {
            perscountCaption.text = String(dataAccount.account_perscount!)
        } else {
            perscountCaption.text = "-"
        }
        if dataAccount.account_factcount != nil {
            factcountCaption.text = String(dataAccount.account_factcount!)
        } else {
            factcountCaption.text = "-"
        }
        if dataAccount.account_roomcount != nil {
            roomcountCaption.text = String(dataAccount.account_roomcount!)
        } else {
            roomcountCaption.text = "-"
        }
        if dataAccount.account_area != nil {
            areaCaption.text = String.localizedStringWithFormat("%.2f м²", dataAccount.account_area!)
        } else {
            areaCaption.text = "-"
        }
        if dataAccount.account_categoty != nil {
            let dataCategory = dataAccount.account_categoty!
            let stringArray = dataCategory.components(separatedBy: ";")
            var newTextCaption = ""
            if stringArray.count > 0 {
                for strArray in stringArray {
                    var readStrArray = strArray
                    let ferstSubstring = readStrArray[strArray.index(readStrArray.startIndex, offsetBy: 0)]
                    if ferstSubstring == " " {
                        readStrArray = String(readStrArray.dropFirst())
                    }
                    newTextCaption = newTextCaption + readStrArray + "\n"
                }
            }
            accountCategoryCaption.text = newTextCaption
        } else {
            accountCategoryCaption.text = ""
        }
    }
    
    // функция обновления данных отображения
    @objc func refreshVisualDataVC() {
        DispatchQueue.main.async {
            self.self.refreshVisualData()
            self.debtTable.reloadData()
            self.view.setNeedsLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().async {
            while true {
                DispatchQueue.main.async {
                    self.refreshUpdateDateLabel()
                }
                sleep(15)
            }
        }
        /// настройка дизайна ViewController
        setNavigationColor(self)
        refreshAnimation.isHidden = true
        self.view.backgroundColor = color_dark
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshVisualDataVC), name: MainWorkVC_refreshVisualData, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        // устанавливаем настройки кнопки
        settingButtonsView(button: paymentButton,image: "MainVC_wallet", label: paymentLabel)
        settingButtonsView(button: indicationButton, image: "MainVC_counter", label: indicationLabel)
        settingButtonsView(button: messageButton, image: "MainVC_document", label: messageLabel)
        if view != nil {
            let viewRect = view!.safeAreaLayoutGuide.layoutFrame
            let minHeightHeadlineView = 44.0 + viewRect.minY
            constPanelHeight.constant = (viewRect.maxY - advertisingPanel.frame.origin.y) + (250-minHeightHeadlineView)
        }
        refreshVisualData()
    }
   
    // =======================================================
    // Обработка таблицы задолжности
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceBalanceTable.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = debtTable.dequeueReusableCell(withIdentifier: "debtTableCell", for: indexPath)
        cell.textLabel?.text = serviceBalanceTable[indexPath.row].service_name
        let negativBalance = serviceBalanceTable[indexPath.row].balance < 0 ? -1.0 : 1.0
        
        let balanceRound = roundDoubleRub(abs(serviceBalanceTable[indexPath.row].balance))
        let downBalanceRound = balanceRound.rounded(.down)
        let balanceRub = downBalanceRound
        let balanceKop = (balanceRound - downBalanceRound) * 100
        let balanceColor: UIColor = serviceBalanceTable[indexPath.row].balance < 0 ? UIColor.red : color_dark_green
        let balanceRunString: String = String(format: "%.0f", balanceRub * negativBalance)
        var balanceKopString: String = String(format: "%.0f", balanceKop)
        if balanceKopString.count == 1 {
           balanceKopString = ",0" + balanceKopString + " ₽"
        } else if balanceKopString.count == 2 {
            balanceKopString = "," + balanceKopString + " ₽"
        } else {
            balanceKopString = ",00 ₽"
        }
        let attStringRub = NSMutableAttributedString(string: balanceRunString)
        attStringRub.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 12), range: NSRange(location: 0, length: attStringRub.length))
        attStringRub.addAttribute(NSAttributedString.Key.foregroundColor, value: balanceColor, range: NSRange(location: 0, length: attStringRub.length))
        let attStringKop = NSMutableAttributedString(string: balanceKopString)
        attStringKop.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 11), range: NSRange(location: 0, length: attStringKop.length))
        attStringKop.addAttribute(NSAttributedString.Key.foregroundColor, value: balanceColor, range: NSRange(location: 0, length: attStringKop.length))
        attStringRub.append(attStringKop)
        cell.detailTextLabel?.attributedText = attStringRub
        return cell
    }
    
    // MARK: - Обработка событий связанных с скролингом в окне
    
    /// Функция скрытия надписи с задолженностью и отображение в заголовке
    ///
    /// - Parameter uHidden: Значение срываемости. Истина - будет скрыта сумма из панели и отобразится в заголовке.
    private func hiddenforPayment(hidden uHidden: Bool) {
        mainPayCaptionText.isHidden = !uHidden
        payCaptionText.isHidden = uHidden
        forPaymentRubLabel.isHidden = uHidden
        forPaymentKopLabel.isHidden = uHidden
        if uHidden {
            headlineView.backgroundColor = color_dark
        }
    }
    
    /// Функция создания градиентной записи для панели и надписей заголовка окна
    private func setGtandartVisualForPay() {
        constPayCatpionText.constant = 115
        constForPaymentRub.constant = 134
        constForPaymentCop.constant = 142
        payCaptionText.font = payCaptionText.font.withSize(17.0)
        forPaymentRubLabel.font = forPaymentRubLabel.font.withSize(32.0)
        forPaymentKopLabel.font = forPaymentKopLabel.font.withSize(25.0)
        payCaptionText.isHidden = false
        payCaptionText.alpha = 1
        forPaymentRubLabel.alpha = 1
        forPaymentKopLabel.alpha = 1
        headlineView.applyGradient(colours: [color_dark,color_light], locations: [0.1,1.5])
        
    }
    
    /// Функция обработки события скролинга в окне
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewRect = view!.safeAreaLayoutGuide.layoutFrame
        let scrollBias = scrollView.contentOffset.y + viewRect.minY
        if scrollBias <= -100 {
            // полностью развернуто + нужно обновить данные
            refreshDateLabel.isHidden = !refreshAnimation.isHidden
            constUsersButton.constant = 10
            hiddenforPayment(hidden: false)
            setGtandartVisualForPay()
            refreshData()
        } else if scrollBias <= 0 && scrollBias > -100 {
            // полностью развернуто
            refreshDateLabel.isHidden = !refreshAnimation.isHidden
            constUsersButton.constant = 10
            hiddenforPayment(hidden: false)
            setGtandartVisualForPay()
        } else if scrollBias >= 206 {
            // полностью сжато
            refreshDateLabel.isHidden = true
            constUsersButton.constant = 206 + 10
            hiddenforPayment(hidden: true)
            setGtandartVisualForPay()
        } else if scrollBias > 0 && scrollBias <= 51.5 {
            refreshDateLabel.isHidden = true
            constUsersButton.constant = scrollBias + 10
            hiddenforPayment(hidden: false)
            setGtandartVisualForPay()
        } else if scrollBias > 51.5 && scrollBias <= 103 {
            refreshDateLabel.isHidden = true
            constUsersButton.constant = scrollBias + 10
            hiddenforPayment(hidden: false)
            setGtandartVisualForPay()
        } else if scrollBias > 103 && scrollBias <= 154.5 {
            refreshDateLabel.isHidden = true
            constUsersButton.constant = scrollBias + 10
            hiddenforPayment(hidden: false)
            payCaptionText.isHidden = false
            constPayCatpionText.constant = scrollBias + 12
            constForPaymentRub.constant = scrollBias + 31
            constForPaymentCop.constant = scrollBias + 39
            payCaptionText.alpha = 1
            forPaymentRubLabel.alpha = 1
            forPaymentKopLabel.alpha = 1
        } else if scrollBias > 154.5 && scrollBias <= 206 {
            refreshDateLabel.isHidden = true
            constUsersButton.constant = scrollBias + 10
            hiddenforPayment(hidden: false)
            constPayCatpionText.constant = scrollBias + 12
            constForPaymentRub.constant = scrollBias + 31
            constForPaymentCop.constant = scrollBias + 39
            payCaptionText.alpha = 0.8
            forPaymentRubLabel.alpha = 0.8
            forPaymentKopLabel.alpha = 0.8
            if scrollBias >= 175 && scrollBias < 182 {
                payCaptionText.isHidden = true
                constForPaymentRub.constant = scrollBias + 31 - (scrollBias-175)
                constForPaymentCop.constant = scrollBias + 39 - (scrollBias-175)
                payCaptionText.alpha = 0.7
                forPaymentRubLabel.alpha = 0.7
                forPaymentKopLabel.alpha = 0.7
            } else if scrollBias >= 182 && scrollBias < 189 {
                payCaptionText.isHidden = true
                constForPaymentRub.constant = scrollBias + 31 - (scrollBias-175)
                constForPaymentCop.constant = scrollBias + 39 - (scrollBias-175)
                payCaptionText.alpha = 0.6
                forPaymentRubLabel.alpha = 0.6
                forPaymentKopLabel.alpha = 0.6
            } else if scrollBias >= 189 && scrollBias <= 196 {
                payCaptionText.isHidden = true
                constForPaymentRub.constant = scrollBias + 31 - (scrollBias-175)
                constForPaymentCop.constant = scrollBias + 39 - (scrollBias-175)
                payCaptionText.alpha = 0.5
                forPaymentRubLabel.alpha = 0.5
                forPaymentKopLabel.alpha = 0.5
            } else if scrollBias >= 196 && scrollBias <= 206 {
                payCaptionText.isHidden = true
                constForPaymentRub.constant = scrollBias + 31 - (scrollBias-175)
                constForPaymentCop.constant = scrollBias + 39 - (scrollBias-175)
                payCaptionText.alpha = 0.3
                forPaymentRubLabel.alpha = 0.3
                forPaymentKopLabel.alpha = 0.3
            }
        }
        
    }
    
    /// функция обработки события открытия окна
    override func viewDidAppear(_ animated: Bool) {
        // устанавливаем настройки кнопки
        settingButtonsView(button: paymentButton,image: "MainVC_wallet", label: paymentLabel)
        settingButtonsView(button: indicationButton, image: "MainVC_counter", label: indicationLabel)
        settingButtonsView(button: messageButton, image: "MainVC_document", label: messageLabel)
        refreshVisualData()
    }
    
    // MARK: - Обработка событий нажатия на основные кнопки панели
    
    /// Функция для визуализации нажатия на кнопку
    ///
    /// - Parameters:
    ///   - uButton: Нажемаемая кнопка
    ///   - uLabel: Надпись, используемая для тени
    private func buttonTouch(button uButton: UIButton, label uLabel: UILabel) {
        let buttonRect = CGRect(x: uButton.frame.origin.x-5, y: uButton.frame.origin.y-5, width: uButton.frame.width+10, height: uButton.frame.height+10)
        uButton.frame = buttonRect
        uLabel.backgroundColor = UIColor.black
        uLabel.layer.cornerRadius = 10
        uLabel.layer.shadowRadius = 15.0
        uLabel.layer.shadowOpacity = 0.5
        uLabel.layer.shadowOffset = CGSize(width: 0, height: 15)
        uLabel.layer.shadowColor = color_button_ligth.cgColor
    }
    
    /// Функция для визуализация отпускания кнопки
    ///
    /// - Parameters:
    ///   - uButton: Отпускаемая кнопка
    ///   - uLabel: Надпись, используемая для тени
    private func buttonDown(button uButton: UIButton, label uLabel: UILabel) {
        let buttonRect = CGRect(x: uButton.frame.origin.x+5, y: uButton.frame.origin.y+5, width: uButton.frame.width-10, height: uButton.frame.height-10)
        uButton.frame = buttonRect
        uLabel.backgroundColor = UIColor.black
        uLabel.layer.cornerRadius = 10
        uLabel.layer.shadowRadius = 15.0
        uLabel.layer.shadowOpacity = 0.5
        uLabel.layer.shadowOffset = CGSize(width: 0, height: 15)
        uLabel.layer.shadowColor = color_button_dark.cgColor
    }
    
    /// Функция обработки события отпускания кнопки Оплаты
    @IBAction func paymentButtonTouch(_ sender: UIButton) {
        //buttonTouch(button: sender, label: paymentLabel)
        if let paymentNavigationVC = storyboard!.instantiateViewController(withIdentifier: "navigationPaymentViewController") as? UINavigationController {
            present(paymentNavigationVC,animated: true,completion: nil)
        }
    }
    
    /// Функция обработки события нажатия кнопки Оплаты
    @IBAction func paymentButtonDown(_ sender: UIButton) {
        //buttonDown(button: sender, label: paymentLabel)
    }
    
    /// Функция обработки события отпуская кнопки Оплаты вне области кнопки
    @IBAction func paymentButtonDragExit(_ sender: UIButton) {
        //buttonTouch(button: sender, label: paymentLabel)
    }
    
    /// Функция обработки события отпускания кнопки Покзаний
    @IBAction func indicationButtonTouch(_ sender: UIButton) {
        //buttonTouch(button: sender, label: indicationLabel)
        if let indicationNavigationVC = storyboard!.instantiateViewController(withIdentifier: "navigationIndicationViewController") as? UINavigationController {
            present(indicationNavigationVC,animated: true,completion: nil)
        }
    }
    
    /// Функция обработки события нажатия на кнопку выбора пользователя
    @IBAction func changeUsersTouch(_ sender: Any) {
        if let changeUsersVC = storyboard!.instantiateViewController(withIdentifier: "changeUserViewController") as? ChangeUserViewController {
            changeUsersVC.changeCurrentUser_postFunc = refreshData
            self.addChild(changeUsersVC)
            changeUsersVC.view.frame = self.view.frame
            self.view.addSubview(changeUsersVC.view)
            changeUsersVC.didMove(toParent: self)
        }
    }
    
    /// Функция обработки события нажатия кнопки Показаний
    @IBAction func indicationButtonDown(_ sender: UIButton) {
        //buttonDown(button: sender, label: indicationLabel)
    }
    
    /// Функция обработки события отпуская кнопки Показаний вне области кнопки
    @IBAction func indicationButtonDragExit(_ sender: UIButton) {
        //buttonTouch(button: sender, label: indicationLabel)
    }
    
    /// Функция обработки события отпускания кнопки Заявки
    @IBAction func messageButtonTouch(_ sender: UIButton) {
        //buttonTouch(button: sender, label: messageLabel)
        if let feedbackNavigationVC = storyboard!.instantiateViewController(withIdentifier: "navigationFeedbackViewController") as? UINavigationController {
                present(feedbackNavigationVC,animated: true,completion: nil)
        }
    }
    
    /// Функция обработки события нажатия на кнопку Заявки
    @IBAction func messageButtonDown(_ sender: UIButton) {
        //buttonDown(button: sender, label: messageLabel)
    }
    
    /// Функция обработки события отпуская кнопки Показаний вне области кнопки
    @IBAction func messageButtonDragExit(_ sender: UIButton) {
        //buttonTouch(button: sender, label: messageLabel)
    }

    @IBAction func detailNachTouch(_ sender: UIButton) {
        if let detailVC = storyboard!.instantiateViewController(withIdentifier: "detailNachNavigationController") as? UINavigationController {
            present(detailVC, animated: true, completion: nil)
        }
    }
    
}
