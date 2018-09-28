//
//  Lens.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/28/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import Foundation

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Whole, Part) -> Whole
}
