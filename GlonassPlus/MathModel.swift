//
//  MathModel.swift
//  GlonassPlus
//
//  Created by Mac on 2/8/21.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation


final class CalculateKoordinates {
    
    let ephemeris: ([Double], [Double], [Double], [Double], [Double], [Double], [Double])
    
    init(ephemeris: ([Double], [Double], [Double], [Double], [Double], [Double], [Double])) {
        self.ephemeris = ephemeris
    }
    
    func koordinatyKAInGSK (/*parameters: ([Double], [Double], [Double], [Double], [Double], [Double], [Double])*/kaNumber: Int, dt: Double) -> KAparameters /*[KAparameters]*/ {
        
        let (/*T, */eks, a, iOrb, OMG, omg_p, t_p) = (/*ephemeris.0[kaNumber - 1], */ephemeris.1[kaNumber - 1], ephemeris.2[kaNumber - 1], ephemeris.3[kaNumber - 1], ephemeris.4[kaNumber - 1], ephemeris.5[kaNumber - 1], ephemeris.6[kaNumber - 1])
        
        var OMEGA_: Double
        var omegap_: Double
        var E_x: Double
        var delta: Double

        let numShag = Int(floor(Constants.tZvSut/dt) + 1)
//        for j in 0...(T.count - 1) {
            var ka = KAparameters()
            var time = 0.0
            for i in 0...numShag {
                let proizvOmegaDict = proizvOfOmegas(bigPoluos: a/*[j]*/, ekscentrisitet: eks/*[j]*/, naklonenie: iOrb/*[j]*/)
                OMEGA_ = proizvOmegaDict["OMEGA_"]!
                omegap_ = proizvOmegaDict["omegap_"]!
                let OMEGA = OMG/*[j]*/ + OMEGA_ * (time - 0.0)
                let omega_p = omg_p/*[j]*/ + omegap_ * (time - 0.0)
                let eandDeltaDict = calculateEandDelta(bigPoluos: a/*[j]*/, ekscentrisitet: eks/*[j]*/, time: time, t_p: t_p/*[j]*/)
                E_x = eandDeltaDict["Ex"]!
                delta = eandDeltaDict["delta"]!
                let tetta = delta + 2 * atan(tan(E_x / 2) * sqrt((1 + eks/*[j]*/) / (1 - eks/*[j]*/)))
                let r = a/*[j]*/ * pow((1 - eks/*[j]*/), 2.0) / (1 + eks/*[j]*/ * cos(tetta))
                ka.xA.append(r * (cos(tetta + omega_p) * cos(OMEGA) - sin(tetta + omega_p) * sin(OMEGA) * cos(iOrb/*[j]*/)))
                ka.yA.append(r * (cos(tetta + omega_p) * sin(OMEGA) + sin(tetta + omega_p) * cos(OMEGA) * cos(iOrb/*[j]*/)))
                ka.zA.append(r * sin(tetta + omega_p) * sin(iOrb/*[j]*/))
                ka.xG.append(ka.xA[i] * cos(Constants.s0 + time * Constants.omegaEarth) + ka.yA[i] * sin(Constants.s0 + time * Constants.omegaEarth))
                ka.yG.append((0 - ka.xA[i]) * sin(Constants.s0 + Constants.omegaEarth * time) + ka.yA[i] * cos(Constants.s0 + Constants.omegaEarth * time))
                ka.zG.append(ka.zA[i])
                time += dt
            }
//            parametersOfOG.append(ka)
//        }
//        return parametersOfOG
        return ka
    }
    
    func koordinatyKAInTSK (dLmbd: Double, dPhi: Double, dt: Double, kaNumber: Int) -> KAparameters {
        var ka = koordinatyKAInGSK(kaNumber: kaNumber, dt: dt)
        let H_N: Double = 0.0
        var B_N: Double
        var lmd_N: Double = -180.0 * Double.pi / 180
        var phi_N: Double
        var delta_mat2: [[Double]] = []
        var xN: [[Double]] = []
        var yN: [[Double]] = []
        var zN: [[Double]] = []
        var xN1: [Double] = []
        var yN1: [Double] = []
        var zN1: [Double] = []
        var xDif: Double
        var yDif: Double
        var zDif: Double
        let nL = Int(floor(Double(360/dLmbd)) + 1)
        let nP = Int(floor(Double(180/dPhi)) + 1)
        let numShag = Int(floor(Constants.tZvSut/dt) + 1)
        var xT2: [[[Double]]] = Array.init(repeating: Array.init(repeating: Array.init(repeating: 0, count: nP), count: nL), count: numShag)
        var yT2: [[[Double]]] = Array.init(repeating: Array.init(repeating: Array.init(repeating: 0, count: nP), count: nL), count: numShag)
        var zT2: [[[Double]]] = Array.init(repeating: Array.init(repeating: Array.init(repeating: 0, count: nP), count: nL), count: numShag)
        for j in 0...nL - 1 {
            phi_N = 90.0 * Double.pi / 180
            for i in 0...nP - 1 {
                B_N = sqrt(1 - Constants.alpha * (2 - Constants.alpha) * pow(sin(phi_N),2))
                delta_mat2 = [[-sin(phi_N) * cos(lmd_N),-sin(phi_N) * sin(lmd_N),cos(phi_N)],
                              [cos(phi_N) * cos(lmd_N),cos(phi_N) * sin(lmd_N),sin(phi_N)],
                              [-sin(lmd_N), cos(lmd_N), 0]]
                xN1.append((H_N + Constants.middleEarthRadius/B_N) * cos(phi_N) * cos(lmd_N))
                yN1.append((H_N + Constants.middleEarthRadius/B_N) * cos(phi_N) * sin(lmd_N))
                zN1.append((H_N + Constants.middleEarthRadius * pow((1 - Constants.alpha),2) / B_N) * sin(phi_N))
                xN.append(xN1)
                yN.append(yN1)
                zN.append(zN1)
                for ti in 0...numShag - 1 {
                    xDif = ka.xG[ti] - xN[j][i]
                    yDif = ka.yG[ti] - yN[j][i]
                    zDif = ka.zG[ti] - zN[j][i]
                    xT2[ti][j][i] = delta_mat2[2][0] * xDif + delta_mat2[2][1] * yDif + delta_mat2[2][2] * zDif
                    yT2[ti][j][i] = delta_mat2[0][0] * xDif + delta_mat2[0][1] * yDif + delta_mat2[0][2] * zDif
                    zT2[ti][j][i] = delta_mat2[1][0] * xDif + delta_mat2[1][1] * yDif + delta_mat2[1][2] * zDif
                }
                if i < nP - 1 {
                    xN.remove(at: j)
                    yN.remove(at: j)
                    zN.remove(at: j)
                }
                phi_N = phi_N - dPhi * Double.pi / 180
            }
            xN.append(xN1)
            yN.append(yN1)
            zN.append(zN1)
            lmd_N = lmd_N + dLmbd * Double.pi / 180
        }
        ka.xT = xT2
        ka.yT = yT2
        ka.zT = zT2
        return ka
    }
    
    func calculateGFto (dLmbd: Double, dPhi: Double, dt: Double, gamma_mesta: Double) -> [[Double]] {
        
        let num_KA = ephemeris.0.count
        
        var kaInstances: [KAparameters] = []
        for ka in 1...num_KA {
            kaInstances.append(koordinatyKAInTSK(dLmbd: dLmbd, dPhi: dPhi, dt: dt, kaNumber: ka))
        }
        let numShag = Int(floor(Constants.tZvSut/dt) + 1)
        let nL = Int(floor(Double(360/dLmbd)) + 1)
        let nP = Int(floor(Double(180/dPhi)) + 1)
        var KA_point: [[[Double]]] = Array.init(repeating: Array.init(repeating: Array.init(repeating: 0, count: nP), count: nL), count: numShag)
        var DD_1: [[[[[Double]]]]] = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0, count: 4), count: 4), count: nP), count: nL), count: numShag)
        var DD: [[[[[Double]]]]] = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0, count: 4), count: 4), count: nP), count: nL), count: numShag)
        
        var H_mat_1 = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag), count: num_KA)
        var H_mat_2 = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag), count: num_KA)
        var H_mat_3 = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag), count: num_KA)
        var H_mat_4 = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag), count: num_KA)
        var R_ip = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag), count: num_KA)
        
        var gamma = Array.init(repeating: Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag), count: num_KA)
        
        var HT = Array.init(repeating: Array.init(repeating: 0.0, count: num_KA), count: 4)
        var HH = Array.init(repeating: Array.init(repeating: 0.0, count: 4), count: num_KA)
        
        var kol_k = 0.0
        var kol_6 = 0.0
        var kol_2 = 0.0
        
        var KK_gp = Array.init(repeating: Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL), count: numShag)
        var K_gp = Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL)
        
        var kol_KA_point = Array.init(repeating: Array.init(repeating: 0, count: nP), count: nL)
        var p_ver = Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL)
        var p_ver_6 = Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL)
        var p_ver_2 = Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL)
        
        for k in 0...num_KA - 1 {
            for ti in 0...numShag - 1 {
                for j in 0...nL - 1 {
                    for i in 0...nP - 1 {
                        if (kaInstances[k].zT[ti][j][i] <= 0.1) {
                            H_mat_1[k][ti][j][i] = 0.0
                            H_mat_2[k][ti][j][i] = 0.0
                            H_mat_3[k][ti][j][i] = 0.0
                            H_mat_4[k][ti][j][i] = 0.0
                            R_ip[k][ti][j][i] = 0.0
                        } else {
                            gamma[k][ti][j][i] = atan(kaInstances[k].zT[ti][j][i] / sqrt(pow(kaInstances[k].xT[ti][j][i],2) + pow(kaInstances[k].yT[ti][j][i],2)))
                            gamma[k][ti][j][i] = gamma[k][ti][j][i] * 180 / Double.pi
                            if (gamma[k][ti][j][i] < gamma_mesta) {
                                H_mat_1[k][ti][j][i] = 0.0
                                H_mat_2[k][ti][j][i] = 0.0
                                H_mat_3[k][ti][j][i] = 0.0
                                H_mat_4[k][ti][j][i] = 0.0
                                R_ip[k][ti][j][i] = 0.0
                            } else {
                                R_ip[k][ti][j][i] = sqrt(pow((kaInstances[k].xT[ti][j][i] - 0),2) + pow((kaInstances[k].yT[ti][j][i] - 0),2) + pow((kaInstances[k].zT[ti][j][i] - 0),2))
                                H_mat_1[k][ti][j][i] = (kaInstances[k].xT[ti][j][i] - 0) / R_ip[k][ti][j][i]
                                H_mat_2[k][ti][j][i] = (kaInstances[k].yT[ti][j][i] - 0) / R_ip[k][ti][j][i]
                                H_mat_3[k][ti][j][i] = (kaInstances[k].zT[ti][j][i] - 0) / R_ip[k][ti][j][i]
                                H_mat_4[k][ti][j][i] = 1
                                KA_point[ti][j][i] = KA_point[ti][j][i] + 1
                            }
                        }
                    }
                }
            }
        }
        for ti in 0...numShag - 1 {
            for j in 0...nL - 1 {
                for i in 0...nP - 1 {
                    if KA_point[ti][j][i] >= 4 {
                        for k in 0...num_KA - 1 {
                            HH[k][0] = H_mat_1[k][ti][j][i]
                            HH[k][1] = H_mat_2[k][ti][j][i]
                            HH[k][2] = H_mat_3[k][ti][j][i]
                            HH[k][3] = H_mat_4[k][ti][j][i]
                            HT[0][k] = H_mat_1[k][ti][j][i]
                            HT[1][k] = H_mat_2[k][ti][j][i]
                            HT[2][k] = H_mat_3[k][ti][j][i]
                            HT[3][k] = H_mat_4[k][ti][j][i]
                        }
                        for j_j in 0...3 {
                            for i_i in 0...3 {
                                for k_k in 0...num_KA - 1 {
                                    DD_1[ti][j][i][j_j][i_i] = DD_1[ti][j][i][j_j][i_i] + HT[i_i][k_k] * HH[k_k][j_j]
                                }
                            }
                        }
                    DD[ti][j][i] = obratnayaMatrix(matrix: DD_1[ti][j][i])
                    KK_gp[ti][j][i] = sqrt(floor(DD[ti][j][i][0][0] + DD[ti][j][i][1][1] + DD[ti][j][i][2][2]))
                    } else {
                        KK_gp[ti][j][i] = 100.0
                    }
                }
            }
        }
        K_gp = Array.init(repeating: Array.init(repeating: 0.0, count: nP), count: nL)
        for j in 0...nL - 1 {
            for i in 0...nP - 1 {
                kol_k = 0
                kol_6 = 0
                kol_2 = 0
                for ti in 0...numShag - 1 {
                    if KK_gp[ti][j][i] <= 20 {
                        K_gp[j][i] = K_gp[j][i] + KK_gp[ti][j][i]
                        kol_k = kol_k + 1
                        if KK_gp[ti][j][i] <= 6 {
                            kol_6 = kol_6 + 1
                        }
                        if KK_gp[ti][j][i] <= 2 {
                            kol_2 = kol_2 + 1
                        }
                }
                    kol_KA_point[j][i] = kol_KA_point[j][i] + Int(KA_point[ti][j][i])
                }
                K_gp[j][i] = K_gp[j][i] / kol_k
                p_ver[j][i] = (kol_k) / Double(numShag)
                p_ver_6[j][i] = (kol_6) / Double(numShag)
                p_ver_2[j][i] = (kol_2) / Double(numShag)
                kol_KA_point[j][i] = Int(floor(Double(kol_KA_point[j][i] / numShag)))
            }
        }
        return K_gp
    }
}


extension CalculateKoordinates {
    
    private func proizvOfOmegas(bigPoluos a: Double, ekscentrisitet eks: Double, naklonenie iOrb: Double) -> [String : Double] {
        
        let eps = 1.5 * Constants.muEarth
        let p = a * (1 - pow(eks, 2))
        let n_ = sqrt(Constants.muEarth/a) * (1 + (eps / (Constants.muEarth * pow(p,2))) * (1 - 1.5 * pow(sin(iOrb), 2)) * sqrt(1 - pow(eks, 2)))
        let omegaT = -(eps / (Constants.muEarth * pow(p, 2))) * cos(iOrb) * n_
        let omegaPT = 0.5 * (eps / (Constants.muEarth * pow(p, 2))) * (5 * pow(cos(iOrb), 2) - 1) * n_
        return ["OMEGA_" : omegaT, "omegap_" : omegaPT]
    }
    
    private func calculateEandDelta (bigPoluos a: Double, ekscentrisitet eks: Double, time: Double, t_p: Double) -> [String : Double] {
        
        var E: Double
        let E0 = sqrt(Constants.muEarth/pow(a,3.0)) * (time - t_p)
        var E1 = E0
        var E2 = 0.0
        while E2 != E1 {
            E2 = E0 + eks * sin(E1)
            E1 = E2
        }
        let i4 = floor(E2 / (2 * Double.pi))
        if i4 >= 1 {
            E = E2 - i4 * 2 * Double.pi
        } else {
            E = E2
        }
        if E <= Double.pi {
            return ["Ex" : E, "delta": 2 * Double.pi * i4]
        } else {
            return ["Ex" : E - 2 * Double.pi, "delta": 2 * Double.pi * (i4 + 1)]
        }
    }
}
