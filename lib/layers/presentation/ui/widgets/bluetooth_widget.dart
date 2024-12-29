import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BluetoothWidget extends StatefulWidget {
  final DeviceEntity deviceEntity;

  const BluetoothWidget({super.key, required this.deviceEntity});

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.deviceEntity.icon,
        size: 28,
      ),
      title: Text(widget.deviceEntity.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tipo: ${widget.deviceEntity.typeName}"),
          Row(
            children: [
              Text('Status: '),
              Text(
                widget.deviceEntity.isConnected ? 'Conectado' : 'Desconectado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.deviceEntity.isConnected
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        try {
          final isConnected = await widget.deviceEntity.isConnected;
          if (isConnected) {
            GoRouter.of(context).go(
              '/led/${widget.deviceEntity.mac}',
              extra: widget.deviceEntity,
            );
          } else {
            try {
              await widget.deviceEntity.connect();
              GoRouter.of(context).go(
                '/led/${widget.deviceEntity.mac}',
                extra: widget.deviceEntity,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: $e')),
              );
            }
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
      trailing: isLoading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  final isConnected = await widget.deviceEntity.isConnected;
                  if (isConnected) {
                    await widget.deviceEntity.disconnect();
                  } else {
                    await widget.deviceEntity.connect();
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
              child: Text(
                  widget.deviceEntity.isConnected ? 'Desconectar' : 'Conectar'),
            ),
    );
  }
}
