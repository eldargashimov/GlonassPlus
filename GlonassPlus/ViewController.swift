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
        
        self.gf = koordinateCalc.calculateGFto(dLmbd: 3.0, dPhi: 3.0, dt: 300.0, gamma_mesta: 10.0)
        
        var i = 0
        var j = 0
        for element in gf {
            j = 0
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
        var views: [[UIView]] = []//Array.init(repeating: Array.init(repeating: UIView(), count: self.gf.count), count: self.gf[0].count)
        for array in gf {
            var views2: [UIView] = []
            for _ in array {
                let view = UIView()
                views2.append(view)
            }
            views.append(views2)
        }

        for element in self.gf {
            j = 0
                for el in element {
                    if el <= 1.9 {
                        views[i][j].backgroundColor = .green
                    } else if el <= 3 && el > 1.9 {
                        views[i][j].backgroundColor = .yellow
                    } else {
                        views[i][j].backgroundColor = .red
                    }
                    
//                    if j == 0 && i == 0 {
                        views[i][j].pin
                            .top(self.worldView.bounds.height - self.worldView.bounds.height * CGFloat(i + 1) / CGFloat(gf.count))
                            .left(self.worldView.bounds.width * CGFloat(j) / CGFloat(element.count))
                            .width(self.worldView.bounds.width / CGFloat(element.count))
                            .height(self.worldView.bounds.height / CGFloat(gf.count))
//                    } else if j == 0 && i != 0{
//                        views[i][j].pin
//                            .left()
//                            .bottom(to: views[i - 1][j].edge.top)
//                            .width(self.worldView.bounds.width / CGFloat(gf.count - 1))
//                            .height(self.worldView.bounds.height / CGFloat(element.count - 1))
//                    } else if j != 0 && i == 0 {
//                        views[i][j].pin
//                            .left(to: views[i][j - 1].edge.right)
//                            .bottom()
//                            .width(self.worldView.bounds.width / CGFloat(gf.count - 1))
//                            .height(self.worldView.bounds.height / CGFloat(element.count - 1))
//                    } else {
//                        views[i][j].pin
//                            .left(to: views[i][j - 1].edge.right)
//                            .bottom(to: views[i - 1][j].edge.top)
//                            .width(self.worldView.bounds.width / CGFloat(gf.count - 1))
//                            .height(self.worldView.bounds.height / CGFloat(element.count - 1))
//                    }
                    self.worldView.addSubview(views[i][j])
                    self.worldView.setNeedsLayout()
                    self.worldView.layoutIfNeeded()
                    j += 1
                }
                i += 1
            }
    }
}
