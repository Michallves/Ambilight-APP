import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:ambilight_app/layers/presentation/provider/bluetooth_provider.dart';
import 'package:ambilight_app/layers/presentation/ui/widgets/bluetooth_widget.dart';
import 'package:ambilight_app/layers/presentation/ui/widgets/button_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // Inicia a verificação e escaneamento automaticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);
      bluetoothProvider.checkBluetoothState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
        builder: (context, bluetoothProvider, child) {
      final bool isBluetoothEnabled = bluetoothProvider.isBluetoothEnabled;
      final List<DeviceEntity> bluetoothDevices =
          bluetoothProvider.bluetoothDevices;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Ambilight App'),
          actions: [
            ButtonHeaderWidget(
                widget: const Icon(Icons.settings),
                onPressed: () => context.go('/config'))
          ],
        ),
        body: Column(
          children: [
            // Indicação do estado do Bluetooth
            Container(
              color: isBluetoothEnabled ? Colors.green : Colors.red,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBluetoothEnabled
                        ? 'Bluetooth está habilitado'
                        : 'Bluetooth está desabilitado',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Icon(
                    isBluetoothEnabled
                        ? Icons.bluetooth
                        : Icons.bluetooth_disabled,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              // Lista de dispositivos encontrados
              child: bluetoothDevices.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum dispositivo LED encontrado.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: bluetoothDevices.length,
                      itemBuilder: (context, index) {
                        return BluetoothWidget(
                          deviceEntity: bluetoothDevices[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}
