//
//  DetailPaymentViewController.swift
//  mobile
//
//  Created by Groylov on 26/04/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class DetailPaymentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var accepterImage: UIImageView!
    @IBOutlet weak var accepterCaption: UILabel!
    @IBOutlet weak var paymentSummLabel: UILabel!
    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet weak var constraintHeightPanel: NSLayoutConstraint!
    
    var paymentId: Int = 0
    private var paymentDetail: [PaymentServicesString] = []
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTable.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        cell.textLabel?.text = String(paymentDetail[indexPath.row].ServiceName)
        cell.detailTextLabel?.text = String(paymentDetail[indexPath.row].Summary)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTable.layer.cornerRadius = 12
        //messagePanel.layer.cornerRadius = 24
        setPortableView(vc: self, panel: messagePanel)
        // получение данных оплаты по идентификатору
        let dataPayment = dataAccount.getPaymentById(paymentId: paymentId)
        paymentDetail = dataAccount.getPaymentDistById(paymentId: paymentId)
        if dataPayment != nil {
            // наименование платежного агента
            let acceptName = dataPayment?.GetAccepterPayment(arrayAccepters: dataAccount.accepters) ?? ""
            accepterCaption.text = acceptName
            // дата оплаты
            let dateString = ConverDateToString(date: dataPayment!.period) ?? ""
            captionLabel.text = dateString
            // изображение поставщика
            let payAccepter = dataPayment!.accepter_id
            if payAccepter != nil {
                let aImage = UIImage(named: "PayAccepter_"+payAccepter!)
                if aImage != nil {
                    accepterImage.image = aImage!
                } else {
                    let aImageNo = UIImage(named: "PayAccepter_NoAccepter")
                    if aImageNo != nil {
                        accepterImage.image = aImageNo!
                    }
                }
            }
            let summ = dataPayment!.GetSummPayment(arrayPaymentDist: dataAccount.paymentsdist)
            if summ != nil {
                paymentSummLabel.text = String.localizedStringWithFormat("%.2f ₽",summ!)
            } else {
                paymentSummLabel.text = "- ₽"
            }
        }
        moveIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var f: CGRect = detailTable.frame
        f.size.height = detailTable.contentSize.height
        detailTable.frame = f
        constraintHeightPanel.constant = f.size.height+167.33
    }

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
