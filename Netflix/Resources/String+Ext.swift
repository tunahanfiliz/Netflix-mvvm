//
//  String+Ext.swift
//  Netflix
//
//  Created by Ios Developer on 8.11.2022.
//

import Foundation

extension String {

    func capitalizeFirstLetter() -> String{
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
