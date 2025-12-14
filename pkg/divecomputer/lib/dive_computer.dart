export 'package:dive_computer/framework/dive_computer_isolate.dart'
    if (dart.library.html) 'package:dive_computer/framework/dive_computer_unsupported.dart';

export 'types/computer.dart';
export 'types/dive.dart';

// Custom iostream support for BLE and other custom transports
export 'framework/custom_iostream.dart';
export 'framework/dive_computer_ffi_bindings_generated.dart'
    show dc_status_t, dc_transport_t, dc_direction_t, dc_iostream_t;

export 'package:logging/logging.dart';
