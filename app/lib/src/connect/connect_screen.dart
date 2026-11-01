import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../common/common.dart';
import 'ble_download_bloc.dart';
import 'ble_scan_bloc.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BleScanBloc, BleScanState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizeError(context.l10n, state.error!)), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<BleDownloadBloc, BleDownloadState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizeError(context.l10n, state.error!)), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, scanState) {
          return BlocBuilder<BleDownloadBloc, BleDownloadState>(
            builder: (context, downloadState) {
              return ScreenScaffold(
                title: Text(context.l10n.connectDiveComputer),
                actions: [
                  if (downloadState.connectedDevice != null)
                    IconButton(
                      icon: const Icon(Icons.bluetooth),
                      tooltip: context.l10n.disconnect,
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
                        icon: Icon(scanState.isScanning ? Icons.stop : Icons.search),
                        label: Text(scanState.isScanning ? context.l10n.stop : context.l10n.scan),
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
            Icon(Icons.bluetooth, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(context.l10n.bluetoothIs(scanState.adapterState.name), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(context.l10n.pleaseEnableBluetoothToScanForDiveComputers),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.read<BleScanBloc>().add(.turnOnBluetooth()), child: Text(context.l10n.turnOnBluetooth)),
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
            Icon(Icons.bluetooth, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(context.l10n.scanToFindYourDiveComputer),
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
                  child: Text(context.l10n.knownDiveComputers, style: Theme.of(context).textTheme.titleMedium),
                ),
                ..._buildRememberedComputersList(context, scanState),
              ],
              // Scanned computers
              if (scanState.scannedComputers.isNotEmpty || scanState.scannedOther.isNotEmpty || scanState.isScanning) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(context.l10n.computersFound(scanState.scannedComputers.length), style: Theme.of(context).textTheme.titleMedium),
                ),
                ..._buildScannedDevicesList(context, scanState.scannedComputers.map((c) => c.$1)),
              ],
              if ((scanState.isScanning || scanState.scannedOther.isNotEmpty) && scanState.scannedComputers.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(opacity: 0.7, child: Text(context.l10n.makeSureYourDiveComputerIsInBluetoothCommunicationMode)),
                ),
              ],
              // Scanned other devices
              if (scanState.scannedOther.isNotEmpty || scanState.isScanning) ...[
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(context.l10n.otherDevicesFound(scanState.scannedOther.length), style: Theme.of(context).textTheme.titleSmall),
                      ),
                    ),
                    Text(context.l10n.showAll),
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
        leading: const Icon(Icons.bluetooth),
        title: Text('${computer.vendor} ${computer.product}'),
        subtitle: Row(
          spacing: 4,
          children: [
            const Icon(Icons.badge_outlined, size: 16),
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
              child: Text(context.l10n.download),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'forget') {
                  context.read<BleScanBloc>().add(.forgetComputer(computer));
                }
              },
              itemBuilder: (context) => [PopupMenuItem(value: 'forget', child: Text(context.l10n.forget))],
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
          leading: const Icon(Icons.bluetooth),
          title: Text(device.platformName),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              spacing: 4,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    const Icon(Icons.signal_wifi_4_bar, size: 16),
                    Text(context.l10n.signalStrength(_getSignalStrengthLabel(context, result.rssi), result.rssi), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    const Icon(Icons.badge_outlined, size: 16),
                    Text(result.device.remoteId.str, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          trailing: ElevatedButton(onPressed: () => context.read<BleDownloadBloc>().add(.connectToDevice(device)), child: Text(context.l10n.connect)),
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
            leading: const Icon(Icons.bluetooth),
            title: Text(downloadState.connectedDevice!.platformName),
            subtitle: Text(context.l10n.status(downloadState.connectionState.name)),
            trailing: TextButton(onPressed: () => context.read<BleDownloadBloc>().add(.disconnect()), child: Text(context.l10n.disconnect)),
          ),
          if (downloadState.isDiscoveringServices)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text(context.l10n.discoveringServices),
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
                      Expanded(child: Text(_downloadProgressLabel(context, downloadState))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: downloadState.downloadProgress?.indeterminate == false ? downloadState.downloadProgress!.fraction : null),
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
            icon: const Icon(Icons.download),
            label: Text(context.l10n.downloadDives),
          ),
          if (scanState.supportedComputers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(context.l10n.loadingSupportedComputers, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
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
        title: Text(context.l10n.selectDiveComputer),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (matchedComputers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(context.l10n.suggestedFor(deviceName), style: Theme.of(dialogContext).textTheme.bodySmall),
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
                  child: Text(context.l10n.showAllComputers),
                ),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(context.l10n.cancel))],
      ),
    );
  }

  void _showAllComputersDialog(BuildContext context, BleScanState scanState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.allBLEDiveComputers),
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
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(context.l10n.cancel))],
      ),
    );
  }

  String _downloadProgressLabel(BuildContext context, BleDownloadState downloadState) {
    final dives = downloadState.downloadedDives.length;
    final divesLabel = dives > 0 ? context.l10n.divesDownloaded(dives) : '';
    final progress = downloadState.downloadProgress;
    if (progress == null || progress.indeterminate) {
      return context.l10n.downloadingDives(divesLabel);
    }
    return context.l10n.downloadingDivesProgress((progress.fraction * 100).toStringAsFixed(0), divesLabel);
  }

  String _getSignalStrengthLabel(BuildContext context, int rssi) {
    if (rssi >= -50) return context.l10n.excellent;
    if (rssi >= -60) return context.l10n.good;
    if (rssi >= -70) return context.l10n.fair;
    return context.l10n.weak;
  }
}
