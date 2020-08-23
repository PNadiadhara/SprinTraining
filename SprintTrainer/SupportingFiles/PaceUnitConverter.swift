//
//  PaceUnitConverter.swift
//  SprintTrainer
//
//  Created by Pritesh Nadiadhara on 8/23/20.
//  Copyright © 2020 PriteshN. All rights reserved.
//

import Foundation

// adds custom unit of Min/Mile used in pace tracking
// unit speed defaults to meters/second
class PaceUnitConverter : UnitConverter {
    private let coefficient : Double
    
    init(coefficient: Double){
        self.coefficient = coefficient
    }
    
    private func reciprocal(_ value: Double) -> Double {
      guard value != 0 else { return 0 }
      return 1.0 / value
    }
    
    override func baseUnitValue(fromValue value: Double) -> Double {
        return reciprocal(value * coefficient)
    }
    
    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return reciprocal(baseUnitValue * coefficient)
    }
    
    
}

extension UnitSpeed {
    class var secondsPerMeter: UnitSpeed {
        return UnitSpeed(symbol: "sec/m", converter: PaceUnitConverter(coefficient: 1))
    }
    class var minutesPerKilometer: UnitSpeed {
        return UnitSpeed(symbol: "min/km", converter: PaceUnitConverter(coefficient: 60/1000))
    }
    class var minutesPerMile: UnitSpeed {
        // note just over 1609 meter per mile
        return UnitSpeed(symbol: "min/mi", converter: PaceUnitConverter(coefficient: 60/1609))
    }
}
