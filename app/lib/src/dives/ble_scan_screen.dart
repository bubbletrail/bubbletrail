import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          title: const Text('Connect dive computer'),
          actions: [
            if (state.connectedDevice != null)
              IconButton(
                icon: const Icon(Icons.bluetooth_disabled),
                tooltip: 'Disconnect',
                onPressed: () => context.read<BleBloc>().add(const BleDisconnect()),
              ),
          ],
          body: _buildBody(context, state),
          floatingActionButton: state.adapterState == .on && state.connectedDevice == null
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
    if (state.adapterState != .on) {
      return Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Bluetooth is ${state.adapterState.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Please enable Bluetooth to scan for dive computers'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.read<BleBloc>().add(const BleTurnOn()), child: const Text('Turn on Bluetooth')),
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
          padding: const .symmetric(horizontal: 16, vertical: 8),
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
      margin: const .all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          ListTile(
            leading: const Icon(Icons.bluetooth_connected),
            title: Text(state.connectedDevice!.platformName),
            subtitle: Text('Status: ${state.connectionState.name}'),
            trailing: TextButton(onPressed: () => context.read<BleBloc>().add(const BleDisconnect()), child: const Text('Disconnect')),
          ),
          if (state.isDiscoveringServices)
            const Padding(
              padding: .all(16.0),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Discovering services...'),
                ],
              ),
            )
          else if (state.isDownloading)
            Padding(
              padding: const .all(16.0),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 12),
                      Text(
                        state.downloadProgress != null
                            ? 'Downloading... ${state.downloadProgress!.current} / ${state.downloadProgress!.maximum}'
                            : 'Downloading dives...',
                      ),
                    ],
                  ),
                  if (state.downloadProgress != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: state.downloadProgress!.fraction),
                    const SizedBox(height: 4),
                    Text('${(state.downloadProgress!.fraction * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            )
          else if (state.discoveredServices.isNotEmpty)
            _buildDownloadSection(context, state),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context, BleState state) {
    return Padding(
      padding: const .all(16.0),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          FilledButton.icon(
            onPressed: state.supportedComputers.isEmpty ? null : () => _showComputerSelectionDialog(context, state),
            icon: const Icon(Icons.download),
            label: const Text('Download dives'),
          ),
          if (state.supportedComputers.isEmpty)
            Padding(
              padding: const .only(top: 8.0),
              child: Text('Loading supported computers...', style: Theme.of(context).textTheme.bodySmall, textAlign: .center),
            ),
        ],
      ),
    );
  }

  void _showComputerSelectionDialog(BuildContext context, BleState state) {
    final dev = state.connectedDevice!;
    final deviceName = dev.platformName;
    final matchedComputers = state.scanResults.firstWhere((r) => r.$1.device.remoteId == dev.remoteId).$2;
    matchedComputers.sort((a, b) => '${a.vendor} ${a.model}'.compareTo('${b.vendor} ${b.model}'));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select dive computer'),
        content: SizedBox(
          width: .maxFinite,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              if (matchedComputers.isNotEmpty)
                Padding(
                  padding: const .only(bottom: 8.0),
                  child: Text('Suggested for "$deviceName":', style: Theme.of(dialogContext).textTheme.bodySmall),
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matchedComputers.length,
                  itemBuilder: (context, index) {
                    final computer = matchedComputers[index];
                    return ListTile(
                      title: Text('${computer.vendor} ${computer.model}'),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        context.read<BleBloc>().add(BleStartDownload(computer));
                      },
                    );
                  },
                ),
              ),
              if (state.supportedComputers.isNotEmpty) ...[
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
        title: const Text('All BLE dive computers'),
        content: SizedBox(
          width: .maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: state.supportedComputers.length,
            itemBuilder: (context, index) {
              final computer = state.supportedComputers[index];
              return ListTile(
                title: Text('${computer.vendor} ${computer.model}'),
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

  Widget _buildEmptyState(BuildContext context, BleState state) {
    final hasUnfilteredResults = state.scanResults.isNotEmpty && state.filteredScanResults.isEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: .center,
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
            textAlign: .center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, BleState state) {
    final results = state.filteredScanResults;
    return ListView.builder(
      padding: const .all(8),
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
