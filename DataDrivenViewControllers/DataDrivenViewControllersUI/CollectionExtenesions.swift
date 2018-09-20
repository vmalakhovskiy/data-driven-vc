//
//  CollectionExtenesions.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/18/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import Foundation

public extension Collection {
    public subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
