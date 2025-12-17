import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bloc/ble_bloc.dart';
import '../common/common.dart';

class BleScanScreen extends StatelessWidget {
  const BleScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        return ScreenScaffold(
          title: const Text('Connect Dive Computer'),
          actions: [
            if (state.connectedDevice != null)
              IconButton(
                icon: const Icon(Icons.bluetooth_disabled),
                tooltip: 'Disconnect',
                onPressed: () => context.read<BleBloc>().add(const BleDisconnect()),
              ),
          ],
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
            ElevatedButton(onPressed: () => context.read<BleBloc>().add(const BleTurnOn()), child: const Text('Turn On Bluetooth')),
          ],
        ),
      );
    }

    if (state.connectedDevice != null) {
      return SingleChildScrollView(child: _buildConnectedDeviceCard(context, state));
    }

    final filteredResults = state.filteredScanResults;
    final hasHiddenDevices = state.scanResults.length > filteredResults.length;

    return Column(
      children: [
        if (state.isScanning) const LinearProgressIndicator() else const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasHiddenDevices && !state.showAllDevices
                      ? '${filteredResults.length} dive computer(s) found'
                      : '${state.scanResults.length} device(s) found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Text('Show all'),
              Switch(value: state.showAllDevices, onChanged: (_) => context.read<BleBloc>().add(const BleToggleShowAllDevices())),
            ],
          ),
        ),
        Expanded(child: filteredResults.isEmpty ? _buildEmptyState(context, state) : _buildDeviceList(context, state)),
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
            trailing: TextButton(onPressed: () => context.read<BleBloc>().add(const BleDisconnect()), child: const Text('Disconnect')),
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
          else if (state.isDownloading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Downloading dives...'),
                ],
              ),
            )
          else if (state.downloadedDives.isNotEmpty)
            _buildDownloadedDives(context, state)
          else if (state.discoveredServices.isNotEmpty)
            _buildDownloadSection(context, state),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context, BleState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: state.supportedBleComputers.isEmpty ? null : () => _showComputerSelectionDialog(context, state),
            icon: const Icon(Icons.download),
            label: const Text('Download Dives'),
          ),
          if (state.supportedBleComputers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Loading supported computers...', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  void _showComputerSelectionDialog(BuildContext context, BleState state) {
    final deviceName = state.connectedDevice?.platformName ?? '';
    final filteredComputers = filterComputersByDeviceName(state.supportedBleComputers, deviceName);
    final hasMatches = filteredComputers.length < state.supportedBleComputers.length;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Dive Computer'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasMatches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Suggested for "$deviceName":', style: Theme.of(dialogContext).textTheme.bodySmall),
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredComputers.length,
                  itemBuilder: (context, index) {
                    final computer = filteredComputers[index];
                    return ListTile(
                      title: Text('${computer.vendor} ${computer.product}'),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        context.read<BleBloc>().add(BleStartDownload(computer));
                      },
                    );
                  },
                ),
              ),
              if (hasMatches) ...[
                const Divider(),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _showAllComputersDialog(context, state);
                  },
                  child: const Text('Show all computers...'),
                ),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel'))],
      ),
    );
  }

  void _showAllComputersDialog(BuildContext context, BleState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('All BLE Dive Computers'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: state.supportedBleComputers.length,
            itemBuilder: (context, index) {
              final computer = state.supportedBleComputers[index];
              return ListTile(
                title: Text('${computer.vendor} ${computer.product}'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  context.read<BleBloc>().add(BleStartDownload(computer));
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel'))],
      ),
    );
  }

  Widget _buildDownloadedDives(BuildContext context, BleState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Downloaded ${state.downloadedDives.length} dive(s)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...state.downloadedDives.map(
            (dive) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.scuba_diving),
              title: Text(dive.dateTime?.toString() ?? 'Unknown date'),
              subtitle: Text('Max depth: ${dive.maxDepth?.toStringAsFixed(1) ?? '?'}m'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BleState state) {
    final hasUnfilteredResults = state.scanResults.isNotEmpty && state.filteredScanResults.isEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching, size: 64, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 16),
          Text(
            state.isScanning
                ? 'Scanning...'
                : hasUnfilteredResults
                ? 'No dive computers found'
                : 'No devices found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            hasUnfilteredResults
                ? 'Found ${state.scanResults.length} other device(s).\nEnable "Show all" to see them.'
                : 'Make sure your dive computer is in\nBluetooth pairing mode',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, BleState state) {
    final results = state.filteredScanResults;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
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
            trailing: ElevatedButton(onPressed: () => context.read<BleBloc>().add(BleConnectToDevice(device)), child: const Text('Connect')),
          ),
        );
      },
    );
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
