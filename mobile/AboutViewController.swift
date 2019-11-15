//
//  AboutViewController.swift
//  mobile
//
//  Created by Groylov on 27/12/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var aboutDataArray: [StructContacts] = []
    private var orgData: StructOrg? = nil
    
    @IBOutlet weak var tableAbout: UITableView!
    @IBOutlet weak var aboutNavigatorBar: UINavigationBar!
    @IBOutlet weak var orgNameLabel: UILabel!
    @IBOutlet weak var innOrgLabel: UILabel!
    @IBOutlet weak var kppOrgLabel: UILabel!
    
    // функция открытия страницы социальных сетей
    private func openSocialNetworkUrl(page sPage: String) {
        let schemeUrl = NSURL(string: sPage) as URL?
        if schemeUrl != nil {
            if UIApplication.shared.canOpenURL(schemeUrl!) {
                UIApplication.shared.open(schemeUrl!, options: [:], completionHandler: nil)
            }
        }
    }
    
    // функция открытия интернет сайта
    private func openInternetNetworkUrl(page sPage: String) {
        let pageUrl = NSURL(string: sPage) as URL?
        if pageUrl != nil {
            if UIApplication.shared.canOpenURL(pageUrl!) {
                let safariVC = SFSafariViewController(url: pageUrl!)
                present(safariVC,animated: true,completion: nil)
            }
        }        
    }
    
    // функция открытия почтового клиента для отправки письма
    private func openMailNetworkUrl(mail eMail: String) {
        let schemeUrl = NSURL(string: eMail) as URL?
        if schemeUrl != nil {
            if UIApplication.shared.canOpenURL(schemeUrl!) {
                UIApplication.shared.open(schemeUrl!, options: [:], completionHandler: nil)
            }
        }
    }
    
    // функция звонка по телефону
    private func openPhoneNetworkUrl(phone ePhone: String) {
        let phoneUrl = NSURL(string: ePhone)
        if phoneUrl != nil {
            let absPhoneUrl = phoneUrl!.absoluteURL
            if absPhoneUrl != nil {
                if UIApplication.shared.canOpenURL(absPhoneUrl!) {
                    UIApplication.shared.open(absPhoneUrl!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutDataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableAbout.dequeueReusableCell(withIdentifier: "tableAboutCell", for: indexPath)
        cell.textLabel?.text = aboutDataArray[indexPath.row].name
        cell.detailTextLabel?.text = aboutDataArray[indexPath.row].descr
        let cellImage = UIImage(named: "AboutVC_"+aboutDataArray[indexPath.row].type)
        if cellImage != nil {
            cell.imageView?.image = cellImage!.maskWithColor(color: UIColor.orange)
            cell.imageView?.highlightedImage = cellImage!.maskWithColor(color: UIColor.orange)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let typeRow = aboutDataArray[indexPath.row].type
        let dataRow = aboutDataArray[indexPath.row].param
        if dataRow != nil {
            switch typeRow {
            case "phone":
                let phoneString = "tel://" + dataRow!
                openPhoneNetworkUrl(phone: phoneString)
            case "mail":
                let mailString = "mailto:\(dataRow!)"
                openMailNetworkUrl(mail: mailString)
            case "url":
                openInternetNetworkUrl(page: dataRow!)
            case "fb":
                let fbPageString = "https://fb.com/\(dataRow!)"
                openSocialNetworkUrl(page: fbPageString)
            case "inst":
                let instPageString = "https://www.instagram.com/\(dataRow!)"
                openSocialNetworkUrl(page: instPageString)
            case "vk":
                let vkPageString = "http://vk.com/\(dataRow!)"
                openSocialNetworkUrl(page: vkPageString)
            case "youtube":
                let youtubePageString = "https://www.youtube.com/channel/\(dataRow!)"
                openSocialNetworkUrl(page: youtubePageString)
            case "odnoklas":
                let odnoklasPageString = ""
                openSocialNetworkUrl(page: odnoklasPageString)
            case "gplus":
                let gplusPageString = ""
                openSocialNetworkUrl(page: gplusPageString)
            case "twitter":
                let twitterPageString = "https://twitter.com/\(dataRow!)"
                openSocialNetworkUrl(page: twitterPageString)
            case "telegram":
                let telegramPageString = ""
                openSocialNetworkUrl(page: telegramPageString)
            case "viber":
                let viberPageString = ""
                openSocialNetworkUrl(page: viberPageString)
            case "watsapp":
                let watsappPageString = ""
                openSocialNetworkUrl(page: watsappPageString)
            default:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /// настройка дизайна ViewController
        setNavigationColor(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var noOrgData: Bool = false
        aboutDataArray = dataAccount.contacts
        aboutDataArray = aboutDataArray.sorted(by: {$0.order_id < $1.order_id})
        let orgDataArray = dataAccount.orgs
        if orgDataArray.count > 0 {
            orgData = orgDataArray[0]
            if orgData != nil {
                orgNameLabel.text = orgData!.org_name
                if orgData!.org_inn != nil {
                    innOrgLabel.text = "ИНН " + orgData!.org_inn!
                } else {
                    innOrgLabel.text = ""
                }
                if orgData!.org_kpp != nil {
                    kppOrgLabel.text = "КПП " + orgData!.org_kpp!
                } else {
                    kppOrgLabel.text = ""
                }
            } else {
                noOrgData = true
            }
        } else {
            noOrgData = true
        }
        if noOrgData {
            orgNameLabel.text = "АО \"Читаэнергосбыт\""
            innOrgLabel.text = ""
            kppOrgLabel.text = ""
        }
    }

}



