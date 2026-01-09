import 'dart:async';
import 'dart:collection';

import 'package:logging/logging.dart';

/// A singleton service that captures and buffers log records for viewing.
class LogBuffer {
  static final LogBuffer _instance = LogBuffer._internal();
  static LogBuffer get instance => _instance;

  LogBuffer._internal();

  static const int maxRecords = 1000;

  final _records = Queue<LogRecord>();
  final _controller = StreamController<List<LogRecord>>.broadcast();
  StreamSubscription<LogRecord>? _subscription;

  /// Stream of log records list, emits whenever a new record is added.
  Stream<List<LogRecord>> get stream => _controller.stream;

  /// Current list of log records.
  List<LogRecord> get records => _records.toList();

  /// Initialize the log buffer by subscribing to the root logger.
  void initialize() {
    _subscription?.cancel();
    _subscription = Logger.root.onRecord.listen(_onRecord);
  }

  void _onRecord(LogRecord record) {
    _records.addLast(record);
    while (_records.length > maxRecords) {
      _records.removeFirst();
    }
    _controller.add(_records.toList());
  }

  /// Clear all buffered log records.
  void clear() {
    _records.clear();
    _controller.add([]);
  }

  /// Dispose of the log buffer.
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
