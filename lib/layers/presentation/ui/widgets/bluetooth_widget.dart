import 'package:ambilight_app/layers/domain/entities/bluetooth_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BluetoothWidget extends StatefulWidget {
  final BluetoothEntity bluetoothEntity;

  const BluetoothWidget({super.key, required this.bluetoothEntity});

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lightbulb),
      title: Text(widget.bluetoothEntity.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MAC: ${widget.bluetoothEntity.mac}'),
          Text(
            widget.bluetoothEntity.isConnected
                ? 'Status: Conectado'
                : 'Status: Desconectado',
            style: TextStyle(
              color: widget.bluetoothEntity.isConnected
                  ? Colors.green
                  : Colors.red,
            ),
          )
        ],
      ),
      onTap: () async {
        final isConnected = widget.bluetoothEntity.isConnected;
        if (isConnected) {
          // Navega para a tela de gerenciamento da fita de LED
          GoRouter.of(context).go(
            '/led/${widget.bluetoothEntity.mac}',
            extra: widget.bluetoothEntity,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conecte ao dispositivo primeiro!')),
          );
        }
      },
      trailing: isLoading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  final isConnected = await widget.bluetoothEntity.isConnected;
                  if (isConnected) {
                    await widget.bluetoothEntity.disconnect();
                  } else {
                    await widget.bluetoothEntity.connect();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text(widget.bluetoothEntity.isConnected
                  ? 'Desconectar'
                  : 'Conectar'),
            ),
    );
  }
}
