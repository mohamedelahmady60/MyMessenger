//
//  ProfileModels.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 02/01/2021.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
