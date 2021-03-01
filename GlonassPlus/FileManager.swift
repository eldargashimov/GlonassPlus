//
//  FileManager.swift
//  GlonassPlus
//
//  Created by Mac on 2/22/21.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation

func readFrom (fileName: String) -> ([Double], [Double], [Double], [Double], [Double], [Double], [Double]) {
    
//    var numbers: [Int] = []
    var T: [Double] = []
    var eks: [Double] = []
    var a: [Double] = []
    var iOrb: [Double] = []
    var OMG: [Double] = []
    var omg_p: [Double] = []
    var t_p: [Double] = []
    
    if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
        if let text = try? String(contentsOfFile: path) {
            let arrayOfKA = text.components(separatedBy: "\n")
            
            for ka in arrayOfKA {
                if ka != "" {
                    let arrayOfNU = ka.components(separatedBy: "\t")
//                    numbers.append(Int(arrayOfNU[0])!)
                    T.append(Double(arrayOfNU[1])!)
                    eks.append(Double(arrayOfNU[2])!)
                    a.append(Double(arrayOfNU[3])!)
                    iOrb.append(Double(arrayOfNU[4])!)
                    OMG.append(Double(arrayOfNU[5])!)
                    omg_p.append(Double(arrayOfNU[6])!)
                    t_p.append(Double(arrayOfNU[7].trimmingCharacters(in: .whitespacesAndNewlines))!)
                }
            }
        }
    }
    return (T, eks, a, iOrb, OMG, omg_p, t_p)
}
