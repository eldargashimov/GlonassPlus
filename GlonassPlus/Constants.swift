//
//  Constants.swift
//  GlonassPlus
//
//  Created by Mac on 2/22/21.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation

struct Constants {
    
    static let muEarth = 3.986 * pow(10.0, 5.0)             // км^3/c^2
    static let tZvSut = 86164.0                             // c
    static let equatorEarthRadius = 6387.136                // км
    static let middleEarthRadius = 6371.0                   // км
    static let omegaEarth = 7.2921158 * pow(10.0, -5.0)     // рад/c
    static let numberOfGlonassKA = 24                       // -
    static let numberOfDopSegmentKA = 6                     // -
    static let s0 = 0.0                                     // c
    static let I2 = 1062.6 * pow(10.0, -6.0)
    static let alpha = 1 / 298.25
}
