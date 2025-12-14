import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bloc/ble_bloc.dart';

class BleScanScreen extends StatelessWidget {
  const BleScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Connect Dive Computer'),
            actions: [
              if (state.connectedDevice != null)
                IconButton(
                  icon: const Icon(Icons.bluetooth_disabled),
                  tooltip: 'Disconnect',
                  onPressed: () => context.read<BleBloc>().add(const BleDisconnect()),
                ),
            ],
          ),
          body: _buildBody(context, state),
          floatingActionButton: state.adapterState == BluetoothAdapterState.on && state.connectedDevice == null
              ? FloatingActionButton.extended(
                  onPressed: () {
                    if (state.isScanning) {
                      context.read<BleBloc>().add(const BleStopScan());
                    } else {
                      context.read<BleBloc>().add(const BleStartScan());
                    }
                  },
                  icon: Icon(state.isScanning ? Icons.stop : Icons.search),
                  label: Text(state.isScanning ? 'Stop' : 'Scan'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BleState state) {
    if (state.adapterState != BluetoothAdapterState.on) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Bluetooth is ${state.adapterState.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Please enable Bluetooth to scan for dive computers'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<BleBloc>().add(const BleTurnOn()),
              child: const Text('Turn On Bluetooth'),
            ),
          ],
        ),
      );
    }

    if (state.connectedDevice != null) {
      return SingleChildScrollView(child: _buildConnectedDeviceCard(context, state));
    }

    return Column(
      children: [
        if (state.isScanning) const LinearProgressIndicator() else const SizedBox(height: 4),
        Expanded(child: state.scanResults.isEmpty ? _buildEmptyState(context, state) : _buildDeviceList(context, state)),
      ],
    );
  }

  Widget _buildConnectedDeviceCard(BuildContext context, BleState state) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.bluetooth_connected),
            title: Text(state.connectedDevice!.platformName),
            subtitle: Text('Status: ${state.connectionState.name}'),
            trailing: TextButton(
              onPressed: () => context.read<BleBloc>().add(const BleDisconnect()),
              child: const Text('Disconnect'),
            ),
          ),
          if (state.isDiscoveringServices)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Discovering services...'),
                ],
              ),
            )
          else if (state.discoveredServices.isNotEmpty)
            _buildServicesList(context, state),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, BleState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services (${state.discoveredServices.length})', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...state.discoveredServices.map((service) => _buildServiceTile(context, service)),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, BluetoothService service) {
    final serviceName = _getServiceName(service.uuid);
    final isKnown = serviceName != 'Unknown Service';

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Icon(
        isKnown ? Icons.check_circle_outline : Icons.help_outline,
        size: 20,
        color: isKnown ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
      ),
      title: Text(serviceName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: isKnown ? FontWeight.w500 : null)),
      subtitle: Text(service.uuid.toString().toUpperCase(), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 10)),
      children: service.characteristics.map((c) => _buildCharacteristicTile(context, c)).toList(),
    );
  }

  Widget _buildCharacteristicTile(BuildContext context, BluetoothCharacteristic characteristic) {
    final charName = _getCharacteristicName(characteristic.uuid);
    final properties = _getCharacteristicProperties(characteristic);

    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.subdirectory_arrow_right, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(charName, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  characteristic.uuid.toString().toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', fontSize: 9, color: Theme.of(context).colorScheme.secondary),
                ),
                if (properties.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: properties
                        .split(', ')
                        .map(
                          (p) => Chip(
                            label: Text(p),
                            labelStyle: const TextStyle(fontSize: 9),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BleState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching, size: 64, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 16),
          Text(state.isScanning ? 'Scanning...' : 'No devices found', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Make sure your dive computer is in\nBluetooth pairing mode', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, BleState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.scanResults.length,
      itemBuilder: (context, index) {
        final result = state.scanResults[index];
        final device = result.device;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(device.platformName),
            subtitle: Row(
              children: [
                Icon(_getSignalIcon(result.rssi), size: 16, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 4),
                Text('${_getSignalStrengthLabel(result.rssi)} (${result.rssi} dBm)', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => context.read<BleBloc>().add(BleConnectToDevice(device)),
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  String _getServiceName(Guid uuid) {
    const knownServices = {
      '1800': 'Generic Access',
      '1801': 'Generic Attribute',
      '180a': 'Device Information',
      '180f': 'Battery Service',
      '181c': 'User Data',
      '181d': 'Weight Scale',
      '1810': 'Blood Pressure',
      '1816': 'Cycling Speed and Cadence',
      '1818': 'Cycling Power',
      '1819': 'Location and Navigation',
      '6e400001-b5a3-f393-e0a9-e50e24dcca9e': 'Nordic UART Service',
      'fe59': 'Nordic Secure DFU',
    };
    final uuidStr = uuid.toString().toLowerCase();
    final shortUuid = uuidStr.length >= 8 ? uuidStr.substring(4, 8) : uuidStr;
    return knownServices[shortUuid] ?? knownServices[uuidStr] ?? 'Unknown Service';
  }

  String _getCharacteristicName(Guid uuid) {
    const knownCharacteristics = {
      '2a00': 'Device Name',
      '2a01': 'Appearance',
      '2a04': 'Peripheral Preferred Connection Parameters',
      '2a19': 'Battery Level',
      '2a24': 'Model Number',
      '2a25': 'Serial Number',
      '2a26': 'Firmware Revision',
      '2a27': 'Hardware Revision',
      '2a28': 'Software Revision',
      '2a29': 'Manufacturer Name',
      '6e400002-b5a3-f393-e0a9-e50e24dcca9e': 'UART RX',
      '6e400003-b5a3-f393-e0a9-e50e24dcca9e': 'UART TX',
    };
    final uuidStr = uuid.toString().toLowerCase();
    final shortUuid = uuidStr.length >= 8 ? uuidStr.substring(4, 8) : uuidStr;
    return knownCharacteristics[shortUuid] ?? knownCharacteristics[uuidStr] ?? 'Unknown';
  }

  String _getCharacteristicProperties(BluetoothCharacteristic characteristic) {
    final props = <String>[];
    if (characteristic.properties.read) props.add('Read');
    if (characteristic.properties.write) props.add('Write');
    if (characteristic.properties.writeWithoutResponse) props.add('WriteNoResp');
    if (characteristic.properties.notify) props.add('Notify');
    if (characteristic.properties.indicate) props.add('Indicate');
    return props.join(', ');
  }

  String _getSignalStrengthLabel(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    return 'Weak';
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -50) return Icons.signal_cellular_4_bar;
    if (rssi >= -60) return Icons.signal_cellular_alt;
    if (rssi >= -70) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }
}
