import 'package:divestore/divestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../bloc/ble_download_bloc.dart';
import '../bloc/ble_scan_bloc.dart';
import '../common/common.dart';

class BleScanScreen extends StatelessWidget {
  const BleScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BleScanBloc, BleScanState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<BleDownloadBloc, BleDownloadState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, scanState) {
          return BlocBuilder<BleDownloadBloc, BleDownloadState>(
            builder: (context, downloadState) {
              return ScreenScaffold(
                title: const Text('Connect dive computer'),
                actions: [
                  if (downloadState.connectedDevice != null)
                    IconButton(
                      icon: const Icon(FluentIcons.bluetooth_24_regular),
                      tooltip: 'Disconnect',
                      onPressed: () => context.read<BleDownloadBloc>().add(.disconnect()),
                    ),
                ],
                body: _buildBody(context, scanState, downloadState),
                floatingActionButton: scanState.adapterState == BluetoothAdapterState.on && downloadState.connectedDevice == null
                    ? FloatingActionButton.extended(
                        onPressed: () {
                          if (scanState.isScanning) {
                            context.read<BleScanBloc>().add(.stop());
                          } else {
                            context.read<BleScanBloc>().add(.start());
                          }
                        },
                        icon: Icon(scanState.isScanning ? FluentIcons.stop_24_regular : FluentIcons.search_24_regular),
                        label: Text(scanState.isScanning ? 'Stop' : 'Scan'),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BleScanState scanState, BleDownloadState downloadState) {
    if (scanState.adapterState != BluetoothAdapterState.on) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.bluetooth_24_regular, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Bluetooth is ${scanState.adapterState.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Please enable Bluetooth to scan for dive computers'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.read<BleScanBloc>().add(.turnOnBluetooth()), child: const Text('Turn on Bluetooth')),
          ],
        ),
      );
    }

    // Not scanning, nothing remembered
    if (!scanState.isScanning && scanState.rememberedComputers.isEmpty && scanState.scannedComputers.isEmpty && scanState.scannedOther.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.bluetooth_24_regular, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Scan to find your dive computer'),
          ],
        ),
      );
    }

    if (downloadState.connectedDevice != null) {
      return SingleChildScrollView(child: _buildConnectedDeviceCard(context, scanState, downloadState));
    }

    return Column(
      children: [
        if (scanState.isScanning) const LinearProgressIndicator() else const SizedBox(height: 4),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Remembered computers
              if (scanState.rememberedComputers.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Known dive computers', style: Theme.of(context).textTheme.titleMedium),
                ),
                ..._buildRememberedComputersList(context, scanState),
              ],
              // Scanned computers
              if (scanState.scannedComputers.isNotEmpty || scanState.scannedOther.isNotEmpty || scanState.isScanning) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text('${scanState.scannedComputers.length} dive computer(s) found', style: Theme.of(context).textTheme.titleMedium),
                ),
                ..._buildScannedDevicesList(context, scanState.scannedComputers.map((c) => c.$1)),
              ],
              if ((scanState.isScanning || scanState.scannedOther.isNotEmpty) & scanState.scannedComputers.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(opacity: 0.7, child: Text('Make sure your dive computer is in Bluetooth communication mode')),
                ),
              ],
              // Scanned other devices
              if (scanState.scannedOther.isNotEmpty || scanState.isScanning) ...[
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text('${scanState.scannedOther.length} non-dive-computer device(s) found', style: Theme.of(context).textTheme.titleSmall),
                      ),
                    ),
                    const Text('Show all'),
                    Switch(value: scanState.showAllDevices, onChanged: (_) => context.read<BleScanBloc>().add(.toggleShowAll())),
                  ],
                ),
                if (scanState.showAllDevices) ..._buildScannedDevicesList(context, scanState.scannedOther),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRememberedComputersList(BuildContext context, BleScanState scanState) {
    return scanState.rememberedComputers.map((computer) => _buildRememberedComputerCard(context, scanState, computer)).toList();
  }

  Widget _buildRememberedComputerCard(BuildContext context, BleScanState scanState, Computer computer) {
    return Card(
      child: ListTile(
        leading: const Icon(FluentIcons.bluetooth_24_regular),
        title: Text('${computer.vendor} ${computer.product}'),
        subtitle: Row(
          spacing: 4,
          children: [
            const Icon(FluentIcons.person_tag_24_regular, size: 16),
            Text(computer.hasSerial() ? computer.serial : computer.remoteId, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () {
                // Find the descriptor for this computer
                final descriptor = scanState.supportedComputers.where((d) => d.vendor == computer.vendor && d.model == computer.product).firstOrNull;
                if (descriptor != null) {
                  context.read<BleDownloadBloc>().add(.connectToRemembered(computer, descriptor));
                }
              },
              child: const Text('Download'),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'forget') {
                  context.read<BleScanBloc>().add(.forgetComputer(computer));
                }
              },
              itemBuilder: (context) => [const PopupMenuItem(value: 'forget', child: Text('Forget'))],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScannedDevicesList(BuildContext context, Iterable<ScanResult> results) {
    return results.map((result) {
      final device = result.device;
      return Card(
        child: ListTile(
          leading: const Icon(FluentIcons.bluetooth_24_regular),
          title: Text(device.platformName),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              spacing: 4,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    const Icon(FluentIcons.wifi_1_24_regular, size: 16),
                    Text('${_getSignalStrengthLabel(result.rssi)} (${result.rssi} dBm)', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    const Icon(FluentIcons.person_tag_24_regular, size: 16),
                    Text(result.device.remoteId.str, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          trailing: ElevatedButton(onPressed: () => context.read<BleDownloadBloc>().add(.connectToDevice(device)), child: const Text('Connect')),
        ),
      );
    }).toList();
  }

  Widget _buildConnectedDeviceCard(BuildContext context, BleScanState scanState, BleDownloadState downloadState) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(FluentIcons.bluetooth_24_regular),
            title: Text(downloadState.connectedDevice!.platformName),
            subtitle: Text('Status: ${downloadState.connectionState.name}'),
            trailing: TextButton(onPressed: () => context.read<BleDownloadBloc>().add(.disconnect()), child: const Text('Disconnect')),
          ),
          if (downloadState.isDiscoveringServices)
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
          else if (downloadState.isDownloading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 12),
                      Text(
                        downloadState.downloadProgress != null
                            ? 'Downloading... ${downloadState.downloadProgress!.current} / ${downloadState.downloadProgress!.maximum}'
                            : 'Downloading dives...',
                      ),
                    ],
                  ),
                  if (downloadState.downloadProgress != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: downloadState.downloadProgress!.fraction),
                    const SizedBox(height: 4),
                    Text('${(downloadState.downloadProgress!.fraction * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            )
          else if (downloadState.discoveredServices.isNotEmpty)
            _buildDownloadSection(context, scanState, downloadState),
        ],
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context, BleScanState scanState, BleDownloadState downloadState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: scanState.supportedComputers.isEmpty ? null : () => _showComputerSelectionDialog(context, scanState, downloadState),
            icon: const Icon(FluentIcons.arrow_download_24_regular),
            label: const Text('Download dives'),
          ),
          if (scanState.supportedComputers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Loading supported computers...', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  void _showComputerSelectionDialog(BuildContext context, BleScanState scanState, BleDownloadState downloadState) {
    final dev = downloadState.connectedDevice!;
    final deviceName = dev.platformName;
    final matchedComputers = scanState.descriptorsForDevice(dev).toList();
    matchedComputers.sort((a, b) => '${a.vendor} ${a.model}'.compareTo('${b.vendor} ${b.model}'));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select dive computer'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (matchedComputers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
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
                        context.read<BleDownloadBloc>().add(.start(computer));
                      },
                    );
                  },
                ),
              ),
              if (scanState.supportedComputers.isNotEmpty) ...[
                const Divider(),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _showAllComputersDialog(context, scanState);
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

  void _showAllComputersDialog(BuildContext context, BleScanState scanState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('All BLE dive computers'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: scanState.supportedComputers.length,
            itemBuilder: (context, index) {
              final computer = scanState.supportedComputers[index];
              return ListTile(
                title: Text('${computer.vendor} ${computer.model}'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  context.read<BleDownloadBloc>().add(.start(computer));
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel'))],
      ),
    );
  }

  String _getSignalStrengthLabel(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    return 'Weak';
  }
}
