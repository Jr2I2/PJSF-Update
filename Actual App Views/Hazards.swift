//
//  Hazards.swift
//  PJSF
//
//  Created by Lim Jun Rui on 6/6/23.
//

import Foundation
import UIKit

struct Hazards: Identifiable {
    let id = UUID()
    let title: String
    let desc: String
    let type: String
    let image: String
    let needCheck: String
}
