//
// Created by Martin Anderson on 2019-03-10.
//

import HealthKit

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

extension HKSampleType {
    public static func fromDartType(type: String) throws -> HKSampleType {
        guard let sampleType: HKSampleType = {
            switch type {
            case "heart_rate":
                return HKSampleType.quantityType(forIdentifier: .heartRate)
            case "step_count":
                return HKSampleType.quantityType(forIdentifier: .stepCount)
            case "height":
                return HKSampleType.quantityType(forIdentifier: .height)
            case "weight":
                return HKSampleType.quantityType(forIdentifier: .bodyMass)
            case "distance":
                return HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
            case "energy":
                return HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
            case "water":
                if #available(iOS 9, *) {
                    return HKSampleType.quantityType(forIdentifier: .dietaryWater)
                } else {
                    return nil
                }
            case "sleep":
                return HKSampleType.categoryType(forIdentifier: .sleepAnalysis)
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported";
        }
        return sampleType
    }
    
    public static func toDartType(sampleType: HKSampleType) -> String {
        switch sampleType {
        case HKSampleType.quantityType(forIdentifier: .heartRate):
            return "heart_rate"
        case HKSampleType.quantityType(forIdentifier: .stepCount):
            return "step_count"
        case HKSampleType.quantityType(forIdentifier: .height):
            return "height"
        case HKSampleType.quantityType(forIdentifier: .bodyMass):
            return "weight"
        case HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning):
            return "distance"
        case HKSampleType.quantityType(forIdentifier: .activeEnergyBurned):
            return "energy"
        case HKSampleType.categoryType(forIdentifier: .sleepAnalysis):
            return "sleep"
        default:
            if #available(iOS 9.0, *) {
                if sampleType == HKSampleType.quantityType(forIdentifier: .dietaryWater) {
                    return "water"
                }
            }
            return ""
        }
    }
}

extension HKUnit {
    public static func fromDartType(type: String) throws -> HKUnit {
        guard let unit: HKUnit = {
            switch (type) {
            case "heart_rate":
                return HKUnit.init(from: "count/min")
            case "step_count":
                return HKUnit.count()
            case "height":
                return HKUnit.meter()
            case "weight":
                return HKUnit.gramUnit(with: .kilo)
            case "distance":
                return HKUnit.meter()
            case "energy":
                return HKUnit.kilocalorie()
            case "water":
                return HKUnit.liter()
            case "sleep":
                return HKUnit.minute() // this is ignored
            default:
                return nil
            }
        }() else {
            throw "type \"\(type)\" is not supported";
        }
        return unit
    }
}
