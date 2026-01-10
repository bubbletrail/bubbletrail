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

  Future<Computer> insert(Computer computer) async {
    if (readonly) throw Exception('readonly');
    computer = _insert(computer);
    _scheduleSave();
    return computer;
  }

  Future<void> insertAll(Iterable<Computer> computers) async {
    if (readonly) throw Exception('readonly');
    for (final computer in computers) {
      _insert(computer);
    }
    _scheduleSave();
  }

  Computer _insert(Computer computer) {
    if (!computer.isFrozen) computer.freeze();
    computer = computer.rebuild((computer) {
      computer.updatedAt = Timestamp.fromDateTime(DateTime.now());
      if (!computer.hasCreatedAt()) {
        computer.createdAt = computer.updatedAt;
      }
    });
    _computers[computer.remoteId] = computer;
    return computer;
  }

  Future<void> update(Computer computer) async {
    if (readonly) throw Exception('readonly');
    if (!computer.isFrozen) computer.freeze();
    computer = computer.rebuild((computer) {
      computer.updatedAt = Timestamp.fromDateTime(DateTime.now());
      if (!computer.hasCreatedAt()) {
        computer.createdAt = computer.updatedAt;
      }
    });
    _computers[computer.remoteId] = computer;
    _scheduleSave();
  }

  Future<void> delete(String remoteId) async {
    if (readonly) throw Exception('readonly');
    if (_computers.containsKey(remoteId)) {
      _computers[remoteId] = _computers[remoteId]!.rebuild((computer) {
        computer.deletedAt = Timestamp.fromDateTime(DateTime.now());
      });
    }
    _scheduleSave();
  }

  Future<Computer?> getByRemoteId(String remoteId) async {
    return _computers[remoteId];
  }

  Future<List<Computer>> getAll({bool withDeleted = false}) async {
    final computers = _computers.values.where((c) => withDeleted || !c.hasDeletedAt()).toList();
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
        if (computer.hasDeletedAt()) {
          if (cur != null) {
            _log.fine('deleting computer ${computer.remoteId}');
            await delete(computer.remoteId);
          }
        } else if (cur == null || computer.updatedAt.toDateTime().isAfter(cur.updatedAt.toDateTime())) {
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
