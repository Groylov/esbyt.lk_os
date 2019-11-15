//
//  PaymentListViewController.swift
//  mobile
//
//  Created by Groylov on 19/04/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var dateCaption: UILabel!
    @IBOutlet weak var accepterCaption: UILabel!
    @IBOutlet weak var summCaption: UILabel!
    @IBOutlet weak var accepterImage: UIImageView!
    
}

class PaymentListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tablePayments: UITableView!

    var arrayPayments: [StructPayment]?
    var arrayPaymentsDist: [StructPaymentdist]?
    var arrayPaymentAccepter: [StructAccepter]?
    private var countSubview: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countSubview = view.subviews.count
        
        // настройка дизайна ViewController
        setNavigationColor(self)
        
        arrayPayments = dataAccount.payments
        arrayPaymentsDist = dataAccount.paymentsdist
        arrayPaymentAccepter = dataAccount.accepters
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPayments!.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablePayments.dequeueReusableCell(withIdentifier: "tablePaymentCell", for: indexPath) as! CustomCell
        if arrayPayments != nil {
            // установка даты оплаты
            let dateCaptionString = ConverDateToString(date: arrayPayments![indexPath.row].txn_date)
            if dateCaptionString != nil {
                cell.dateCaption?.text = dateCaptionString
            } else {
                cell.dateCaption?.text = "-"
            }
            // установка суммы оплаты
            let summCaptionString = arrayPayments![indexPath.row].GetSummPayment(arrayPaymentDist: arrayPaymentsDist)
            if summCaptionString != nil {
                cell.summCaption?.text = String.localizedStringWithFormat("%.2f ₽", summCaptionString!)
            } else {
                cell.summCaption?.text = "- ₽"
            }
            // установка платежного агента
            let accepterCaptionString = arrayPayments![indexPath.row].GetAccepterPayment(arrayAccepters: arrayPaymentAccepter)
            if accepterCaptionString != nil {
                cell.accepterCaption?.text = accepterCaptionString
            } else {
                cell.accepterCaption?.text = "-"
            }
            // установка картинки платежной системы
            let payAccepter = arrayPayments![indexPath.row].accepter_id
            if payAccepter != nil {
                let accepterImage = UIImage(named: "PayAccepter_"+payAccepter!)
                if accepterImage != nil {
                    cell.accepterImage?.image = accepterImage!
                    cell.accepterImage?.highlightedImage = accepterImage!.maskWithColor(color: UIColor.gray)
                } else {
                    let accepterImageNo = UIImage(named: "PayAccepter_NoAccepter")
                    if accepterImageNo != nil {
                        cell.accepterImage?.image = accepterImageNo!
                        cell.accepterImage?.highlightedImage = accepterImageNo!.maskWithColor(color: UIColor.gray)
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if view.subviews.count == countSubview {
            if let detailPaymentVC = storyboard!.instantiateViewController(withIdentifier: "detailPaymentViewController") as? DetailPaymentViewController {
                detailPaymentVC.paymentId = arrayPayments![indexPath.row].payment_id
                self.addChild(detailPaymentVC)
                detailPaymentVC.view.frame = self.view.frame
                self.view.addSubview(detailPaymentVC.view)
                detailPaymentVC.didMove(toParent: self)
            }
        }
    }
    
    // функция обработки события открытия окна
    override func viewDidAppear(_ animated: Bool) {
        arrayPayments = dataAccount.payments
        arrayPaymentsDist = dataAccount.paymentsdist
        arrayPaymentAccepter = dataAccount.accepters
    }
    
    // Функция обработки нажатия кнопки закрытия окна оплат
    @IBAction func exitButtonTouch(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Функция обработки события нажатия кнопки ввода нового платежа
    @IBAction func newPaymentTouch(_ sender: UIButton) {
        if let feedbackNavigationVC = storyboard!.instantiateViewController(withIdentifier: "navigationCreatePaymentViewController") as? UINavigationController {
            present(feedbackNavigationVC,animated: true,completion: nil)
        }
        
    }
    
    
}
