//
//  Prism.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/28/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import Foundation

struct Prism<Whole, Part> {
    let tryGet: (Whole) -> Part?
    let inject: (Part) -> Whole
}
