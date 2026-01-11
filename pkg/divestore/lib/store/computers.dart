import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';
import '../sync/syncprovider.dart';
import 'fileio.dart';

final _log = Logger('store/computers.dart');

class Computers {
  final String path;
  final bool readonly;
  Map<String, Computer> _computers = {};
  Timer? _saveTimer;

  Computers(this.path, {this.readonly = false});

  Future<void> update({
    required String remoteId,
    String? advertisedName,
    String? vendor,
    String? product,
    List<int>? ldcFingerprint,
    String? serial,
    DateTime? lastLogDate,
  }) async {
    if (readonly) throw Exception('readonly');
    var computer = _computers[remoteId];
    if (computer == null) {
      computer = Computer(remoteId: remoteId, meta: newMetadata())..freeze();
    }
    computer = computer.rebuild((computer) {
      computer.meta = computer.meta.rebuildUpdated();
      if (advertisedName != null) {
        computer.advertisedName = advertisedName;
      }
      if (vendor != null) {
        computer.vendor = vendor;
      }
      if (product != null) {
        computer.product = product;
      }
      if (ldcFingerprint != null) {
        computer.ldcFingerprint = ldcFingerprint;
      }
      if (serial != null) {
        computer.serial = serial;
      }
      if (lastLogDate != null) {
        computer.lastLogDate = .fromDateTime(lastLogDate);
      }
    });
    _computers[computer.remoteId] = computer;
    _scheduleSave();
  }

  Future<void> delete(String remoteId) async {
    if (readonly) throw Exception('readonly');
    if (_computers.containsKey(remoteId)) {
      _computers[remoteId] = _computers[remoteId]!.rebuild((computer) {
        computer.meta = computer.meta.rebuildDeleted();
      });
    }
    _scheduleSave();
  }

  Future<Computer?> getByRemoteId(String remoteId) async {
    return _computers[remoteId];
  }

  Future<List<Computer>> getAll({bool withDeleted = false}) async {
    final computers = _computers.values.where((c) => withDeleted || !c.meta.isDeleted).toList();
    computers.sort((a, b) {
      final vendorCmp = a.vendor.compareTo(b.vendor);
      if (vendorCmp != 0) return vendorCmp;
      return a.product.compareTo(b.product);
    });
    return computers;
  }

  Future<void> init() async {
    try {
      final bs = await File(path).readAsBytes();
      final cl = InternalComputerList.fromBuffer(bs);
      cl.freeze();
      for (final computer in cl.computers) {
        _computers[computer.remoteId] = computer;
      }
    } catch (_) {}
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      final cl = InternalComputerList(computers: _computers.values);
      await atomicWriteProto(path, cl);
      _log.info('saved ${_computers.length} computers');
    } catch (e) {
      _log.warning('failed to save computers', e);
    }
  }

  Future<void> syncWith(SyncProvider provider) async {
    _log.fine('syncing computers');
    try {
      final obj = await provider.getObject('computers');
      final cl = InternalComputerList.fromBuffer(obj);
      cl.freeze();
      for (final computer in cl.computers) {
        final cur = _computers[computer.remoteId];
        if (computer.meta.isDeleted) {
          if (cur != null) {
            _log.fine('deleting computer ${computer.remoteId}');
            await delete(computer.remoteId);
          }
        } else if (cur == null || computer.meta.isAfter(cur.meta)) {
          _log.fine('importing computer ${computer.remoteId}');
          _computers[computer.remoteId] = computer;
        }
      }
    } catch (e) {
      _log.warning('failed to load computers', e);
    }

    final vals = _computers.values.toList();
    _log.fine('updating ${vals.length} computers in sync provider');
    final cl = InternalComputerList(computers: vals);
    final bs = cl.writeToBuffer();
    await provider.putObject('computers', bs);

    _scheduleSave();
  }
}
