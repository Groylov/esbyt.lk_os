//
//  DetailNachViewController.swift
//  mobile
//
//  Created by Groylov on 09/06/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import UIKit

class DetailNachServiceCall: UITableViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var saldoVhLabel: UILabel!
    @IBOutlet weak var nachLabel: UILabel!
    @IBOutlet weak var perLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var stornoLabel: UILabel!
    @IBOutlet weak var saldoIshLabel: UILabel!
    
}

class DetailNachMainCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var dateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateSummLabel: UILabel!
    @IBOutlet weak var serviceTable: UITableView!
    
    var arrayDataService: [StructBalance] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serviceTable.dequeueReusableCell(withIdentifier: "detailServiceCell", for: indexPath) as! DetailNachServiceCall
        let currentArray = arrayDataService[indexPath.row]
        cell.serviceNameLabel.text = dataAccount.getServiceById(id: currentArray.service_id)
        cell.saldoVhLabel.text = String.localizedStringWithFormat("%0.2f", roundDoubleRub(currentArray.begin_balance ?? 0))
        cell.saldoIshLabel.text = String.localizedStringWithFormat("%0.2f", roundDoubleRub(currentArray.end_balance ?? 0))
        cell.stornoLabel.text = String.localizedStringWithFormat("%0.2f", roundDoubleRub(currentArray.storno_receipts ?? 0))
        cell.perLabel.text = String.localizedStringWithFormat("%0.2f", roundDoubleRub(currentArray.recalculations ?? 0))
        cell.postLabel.text = String.localizedStringWithFormat("%0.2f", roundDoubleRub(currentArray.receipts ?? 0))
        cell.nachLabel.text = String.localizedStringWithFormat("%0.2f", roundDoubleRub(currentArray.accruals ?? 0))
        return cell
    }
    
    func inicializate(serviceArray servArray: [StructBalance]) {
        arrayDataService = servArray
        serviceTable.delegate = self
        serviceTable.dataSource = self
        serviceTable.reloadData()
    }
}

class DetailNachViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrayPeriod: [StructPeriodBalance] = []
    @IBOutlet weak var tableMonth: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPeriod.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableMonth.dequeueReusableCell(withIdentifier: "detailNachCell", for: indexPath) as! DetailNachMainCell
        let currentArray = arrayPeriod[indexPath.row]
        cell.dateLabel.text = ConverDateToStringMonth(date: currentArray.period)
        cell.dateSummLabel.text = String(format: "%.2f", roundDoubleRub(currentArray.balance))
        if currentArray.balance < 0 {
            cell.dateSummLabel.textColor = .red
        } else {
            cell.dateSummLabel.textColor = color_dark_green
        }
        let cellImage = UIImage(named: "MainVC_calendar")
        if cellImage != nil {
            cell.dateImage.image = cellImage
            cell.dateImage.highlightedImage = cellImage
        }
        let serviceArray = dataAccount.getArrayServicePeriodBalance(period: currentArray.period)
        cell.inicializate(serviceArray: serviceArray)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentArray = arrayPeriod[indexPath.row]
        let serviceArray = dataAccount.getArrayServicePeriodBalance(period: currentArray.period)
        let nigHeight = (serviceArray.count - 1) * 30
        return CGFloat((142 * serviceArray.count) - nigHeight)
    }
    
    @IBAction func closeTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationColor(self)
        arrayPeriod = dataAccount.getArrayPeriodSummBalance()        
    }

}
