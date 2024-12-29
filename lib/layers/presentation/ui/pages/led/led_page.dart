import 'package:ambilight_app/layers/presentation/ui/widgets/ambilight_icon.dart';
import 'package:flutter/material.dart';
import 'package:ambilight_app/layers/domain/entities/device_entity.dart';
import 'package:go_router/go_router.dart';

class LedPage extends StatefulWidget {
  final DeviceEntity deviceEntity;
  const LedPage({super.key, required this.deviceEntity});

  @override
  State<LedPage> createState() => _LedPageState();
}

class _LedPageState extends State<LedPage> {
  @override
  Widget build(BuildContext context) {
    final deviceName = widget.deviceEntity.device.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define o número de colunas com base no tamanho da tela
            final crossAxisCount = constraints.maxWidth ~/ 180;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1, // Mantém os botões quadrados
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildGridCard(
                    icon: Icons.lightbulb,
                    label: 'Ligar/Desligar',
                    route: '/led/${widget.deviceEntity.mac}/toggle',
                  );
                } else if (index == 1) {
                  return _buildGridCard(
                    icon: Icons.color_lens,
                    label: 'Cores',
                    route: '/led/${widget.deviceEntity.mac}/color',
                  );
                } else if (index == 2) {
                  return _buildGridCardCustom(
                    icon: AmbilightIcon(
                      size: 40,
                    ),
                    label: 'Ambilight',
                    route: '/led/${widget.deviceEntity.mac}/ambilight',
                  );
                } else if (index == 3) {
                  return _buildGridCard(
                    icon: Icons.info,
                    label: 'Sobre',
                    route: '/led/${widget.deviceEntity.mac}/about',
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String label,
    required String route, // Rota do GoRouter
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go(route, extra: widget.deviceEntity),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCardCustom({
    required Widget icon,
    required String label,
    required String route, // Rota do GoRouter
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go(route, extra: widget.deviceEntity),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
