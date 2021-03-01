//
//  ViewController.swift
//  GlonassPlus
//
//  Created by Mac on 2/6/21.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit
import Foundation
import PinLayout

class ViewController: UIViewController {
    
    var worldView = UIView()
    var goButton = UIButton()
    var goButtonLabel = UILabel()
    var gf: [[Double]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters = readFrom(fileName: "Ephemeris")
        let koordinateCalc = CalculateKoordinates(ephemeris: parameters)
        
        self.gf = koordinateCalc.calculateGFto(dLmbd: 60.0, dPhi: 60.0, dt: 300.0, gamma_mesta: 20.0)
        
        var i = 0
        var j = 0
        for element in gf {
            for el in element {
                print("GF[\(i)][\(j)] = \(el)")
                j += 1
            }
            i += 1
        }
        
        goButton.addTarget(self, action: #selector(raschetGFButton), for: .touchUpInside)
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        goButton.pin
            .height(100)
            .width(200)
            .hCenter()
            .bottom(20)
        
        worldView.pin
            .top()
            .left(50)
            .right(50)
            .bottom(to: goButton.edge.top)
            .marginVertical(50)
        
        goButtonLabel.pin
            .top()
            .left()
            .right()
            .bottom()
            .margin(10)
    }
    
    private func setupViews() {
        
        worldView.backgroundColor = .lightGray
        goButton.backgroundColor = .lightGray
        goButton.layer.cornerRadius = 10
        goButtonLabel.text = "Расчёт"
        goButtonLabel.textColor = .white
        goButtonLabel.textAlignment = .center
        goButtonLabel.font = UIFont(name: "Verdana", size: 18.0)
        goButton.addSubview(goButtonLabel)
        
        [worldView, goButton].forEach { self.view.addSubview($0) }
    }
    
    @objc func raschetGFButton() {
        
        var i = 0
        var j = 0
        let views: [[UIView]] = Array.init(repeating: Array.init(repeating: UIView(), count: self.gf.count), count: self.gf[0].count)
//        UIView.animate(withDuration: 5.0, animations: {
        for element in self.gf {
                j = 0
                for el in element {
                    if el <= 1 {
                        views[j][i].backgroundColor = .green
                    } else if el <= 3 && el > 1 {
                        views[j][i].backgroundColor = .yellow
                    } else {
                        views[j][i].backgroundColor = .red
                    }
                    
                    if j == 0 && i == 0 {
                        views[j][i].pin
                            .left()
                            .bottom()
//                            .width(50)
//                            .height(50)
                            .width(self.worldView.bounds.width / CGFloat(element.count))
                            .height(self.worldView.bounds.height / CGFloat(gf.count))
                    } else if j == 0 && i != 0{
                        views[j][i].pin
                            .left()
                            .bottom(to: views[j][i - 1].edge.top)
//                            .width(50)
//                            .height(50)
                            .width(self.worldView.bounds.width / CGFloat(element.count))
                            .height(self.worldView.bounds.height / CGFloat(gf.count))
                    } else if j != 0 && i == 0 {
                        
                        views[j][i].pin
                            .left(to: views[j - 1][i].edge.right)
                            .bottom()
//                            .width(50)
//                            .height(50)
                            .width(self.worldView.bounds.width / CGFloat(element.count))
                            .height(self.worldView.bounds.height / CGFloat(gf.count))
                    } else {
                        views[j][i].pin
                            .left(to: views[j - 1][i].edge.right)
                            .bottom(to: views[j][i - 1].edge.top)
//                            .width(50)
//                            .height(50)
                            .width(self.worldView.bounds.width / CGFloat(element.count))
                            .height(self.worldView.bounds.height / CGFloat(gf.count))
                    }
                    self.worldView.addSubview(views[j][i])
                    self.worldView.setNeedsLayout()
                    self.worldView.layoutIfNeeded()
                    j += 1
                }
                i += 1
            }
//        })
    }
}
