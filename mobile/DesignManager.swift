//
//  DesignConst.swift
//  mobile
//
//  Created by Groylov on 17/05/2019.
//  Copyright © 2019 esbyt. All rights reserved.
//

import Foundation
import UIKit

/// Оснвной цвет заголовков приложения
let color_primary = UIColor.init(red: 104/255.0, green: 118/255.0, blue: 197/255.0, alpha: 1)
/// Светлый цвет заголовка
let color_light = UIColor.init(red: 148/255.0, green: 156/255.0, blue: 231/255.0, alpha: 1)
/// Темный цвет заголовка
let color_dark = UIColor.init(red: 86/255.0, green: 101/255.0, blue: 190/255.0, alpha: 1)
/// Светлый цвет кнопки
let color_button_ligth = UIColor(red: 236/255.0, green: 176/255.0, blue: 87/255.0, alpha: 1)
/// Темный цвет кнопки
let color_button_dark = UIColor(red: 266/255.0, green: 129/255.0, blue: 79/255.0, alpha: 1)
/// Светлый цвет градиента панели (68, 80, 152)
let color_grad_headline = UIColor(red: 68/255.0, green: 80/255.0, blue: 152/255.0, alpha: 1)
/// Темно зеленный цвет для переплаты
let color_dark_green = UIColor(red: 0.09, green: 0.73, blue: 0.23, alpha: 1.0)

/// Функция подготовки панеля навигации под один цвет
///
/// - Parameter vc: Контроллер для настройки навигации
func setNavigationColor(_ vc: UIViewController) {
    let nController = vc.navigationController
    if nController != nil {
        nController!.navigationBar.barTintColor = color_dark
    }
}

/// Функция подготовик портативной формы
///
/// - Parameters:
///   - vControl: Контроллер для настройки формы
///   - vPanel: Выводимая панель формы
func setPortableView(vc vControl: UIViewController, panel vPanel: UIView) {
    vControl.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    vPanel.layer.cornerRadius = 12
}
