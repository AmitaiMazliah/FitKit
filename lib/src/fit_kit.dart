part of fit_kit;

class FitKit {
  static const MethodChannel _channel = const MethodChannel('fit_kit');
  static const _eventChannel = const EventChannel("fit_kit_events");
  static Stream<List<FitData>> _eventsFetch;

  /// iOS isn't completely supported by HealthKit, false means no, true means user has approved or declined permissions.
  /// In case user has declined permissions read will just return empty list for declined data types.
  static Future<bool> hasPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('hasPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  /// If you're using more than one DataType it's advised to call requestPermissions with all the data types once,
  /// otherwise iOS HealthKit will ask to approve every permission one by one in separate screens.
  ///
  /// `await FitKit.requestPermissions(DataType.values)`
  static Future<bool> requestPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('requestPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  /// iOS isn't supported by HealthKit, method does nothing.
  static Future<void> revokePermissions() async {
    return await _channel.invokeMethod('revokePermissions');
  }

  /// #### It's not advised to call `await FitKit.read(dataType)` without any extra parameters. This can lead to FAILED BINDER TRANSACTION on Android devices because of the data batch size being too large.
  static Future<List<FitData>> read({
    @required DataType type,
    DateTime dateFrom,
    DateTime dateTo,
    int limit,
    bool ignoreManualData
  }) async {
    return await _channel.invokeListMethod('read', {
      "type": _dataTypeToString(type),
      "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
      "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
      "limit": limit,
      "ignoreManualData": ignoreManualData ?? false
    }).then(
      (response) => response.map((item) => FitData.fromJson(item)).toList(),
    );
  }

  static Future<FitData> readLast(DataType type) async {
    return await read(type: type, limit: 1)
        .then((results) => results.isEmpty ? null : results[0]);
  }

  static Future<bool> subscribe({
    @required List<DataType> types,
    @required Function callback,
    bool ignoreManualData
  }) {
    if (_eventsFetch == null) {
      _eventsFetch = _eventChannel.receiveBroadcastStream()
          .map((response) => (response as List<dynamic>)
          .map((item) => FitData.fromJson(item)).toList());

      _eventsFetch
          .listen((List<FitData> v) {
            callback(v);
          });
    }
    Completer completer = new Completer<bool>();

    _channel .invokeMethod('subscribe', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
      "ignoreManualData": ignoreManualData ?? false
    }).then((dynamic status) {
      completer.complete(status);
    }).catchError((dynamic e) {
      completer.completeError(e.details);
    });

    return completer.future;
  }

  static String _dataTypeToString(DataType type) {
    switch (type) {
      case DataType.HEART_RATE:
        return "heart_rate";
      case DataType.STEP_COUNT:
        return "step_count";
      case DataType.HEIGHT:
        return "height";
      case DataType.WEIGHT:
        return "weight";
      case DataType.DISTANCE:
        return "distance";
      case DataType.ENERGY:
        return "energy";
      case DataType.WATER:
        return "water";
      case DataType.SLEEP:
        return "sleep";
    }
    throw Exception('dataType $type not supported');
  }

  static DataType stringToDataType(String json) {
    switch (json) {
      case "heart_rate":
        return DataType.HEART_RATE;
      case "step_count":
        return DataType.STEP_COUNT;
      case "height":
        return DataType.HEIGHT;
      case "weight":
        return DataType.WEIGHT;
      case "distance":
        return DataType.DISTANCE;
      case "energy":
        return DataType.ENERGY;
      case "water":
        return DataType.WATER;
      case "sleep":
        return DataType.SLEEP;
    }
    throw Exception('dataType $json not supported');
  }
}

enum DataType {
  HEART_RATE,
  STEP_COUNT,
  HEIGHT,
  WEIGHT,
  DISTANCE,
  ENERGY,
  WATER,
  SLEEP
}
