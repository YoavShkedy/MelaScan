//
//  EnvironmentExtensions.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 23/10/2023.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    var dismiss: (() -> Void)? {
        get { self[DismissEnvironmentKey.self] }
        set { self[DismissEnvironmentKey.self] = newValue }
    }
}

private struct DismissEnvironmentKey: EnvironmentKey {
    static var defaultValue: (() -> Void)? = nil
}
