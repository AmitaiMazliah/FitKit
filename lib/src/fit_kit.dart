part of fit_kit;

class FitKit {
  static const MethodChannel _channel = const MethodChannel('fit_kit');
  static const _eventChannel = const EventChannel("fit_kit_events");
  static Stream<dynamic> _eventsFetch;

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

  static Future<int> subscribe(List<DataType> types, Function callback) {
    if (_eventsFetch == null) {
      _eventsFetch = _eventChannel.receiveBroadcastStream();

      _eventsFetch.listen((dynamic v) {
        callback();
      });
    }
    Completer completer = new Completer<int>();

    _channel
        .invokeMethod('subscribe', {
          "types": types.map((type) => _dataTypeToString(type)).toList(),
        })
        .then((dynamic status) {
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
