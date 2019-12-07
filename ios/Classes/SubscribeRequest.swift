import HealthKit

class SubscribeRequest {
    let types: Array<String>
    let sampleTypes: Array<(type: HKSampleType, unit: HKUnit)>

    private init(types: Array<String>, sampleTypes: Array<(type: HKSampleType, unit: HKUnit)>) {
        self.types = types
        self.sampleTypes = sampleTypes
    }

    static func fromCall(call: FlutterMethodCall) throws -> SubscribeRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let types = arguments["types"] as? Array<String> else {
            throw "invalid call arguments \(call.arguments)";
        }

        let sampleTypes = try types.map { type -> (type: HKSampleType, unit: HKUnit) in
            try (
                type: HKSampleType.fromDartType(type: type),
                unit: HKUnit.fromDartType(type: type)
            )
        }

        return SubscribeRequest(types: types, sampleTypes: sampleTypes)
    }
}
