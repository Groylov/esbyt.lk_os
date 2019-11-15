//
//  AuthManager.swift
//  mobile
//
// Модуль для работы с авторизацией пользователей
//
//  Created by Groylov on 10/12/2018.
//  Copyright © 2018 esbyt. All rights reserved.
//

import Foundation
import LocalAuthentication


/// Глобальная переменная для авторизации пользователя
var authUser = AuthUsers()


/// Класс авторизации пользователя в приложение
class AuthUsers {
    
    /// использование биометрической авторизации
    private var useTouchID: Bool
    /// тип биометрической авторизации
    private var typeBiometry: LABiometryType?
    
    /// Инициализация класса
    init() {
        let aContext = LAContext()
        let accessUseTouch = aContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        useTouchID = accessUseTouch
        if accessUseTouch {
            typeBiometry = aContext.biometryType
        } else {
            typeBiometry = nil
        }
    }

    /// Функция получения данных о возможности авторизации по биометрии
    ///
    /// - Returns: Истина, если есть возможность авторизации биометрическим методом
    func getUseTouchID() -> Bool {
        return useTouchID
    }
    
    /// Функция получения возможности авторизации по FaceID
    ///
    /// - Returns: Истина, если возможно авторизоватся по FaceID
    func biometryTypeFaceID() -> Bool {
        if typeBiometry != nil {
            return typeBiometry == LABiometryType.faceID
        } else {
            return false
        }
    }
    
    /// Функция получения возможности авторизации по TouchID
    ///
    /// - Returns: Истина, если возможно авторизоватся по TouchID
    func biometryTypeTouchID() -> Bool {
        if typeBiometry != nil {
            return typeBiometry == LABiometryType.touchID
        } else {
            return false
        }
    }
    
    /// Функция биометрической авторизации пользователя
    ///
    /// - Parameter returnFunction: Функция, вызываемая после завершения авторизации
    func authUser(returnFunc returnFunction: @escaping (Bool) -> Void) {
        let aContext = LAContext()
        aContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Авторизация") { (issec, error) in
            if issec {
                returnFunction(true)
            }
            else
            {
                returnFunction(false)
            }
        }
    }
}
