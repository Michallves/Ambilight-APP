import 'package:flutter/material.dart';

class AmbilightIcon extends StatelessWidget {
  final IconData icon; // Ícone a ser exibido
  final double size; // Tamanho do ícone e do efeito

  const AmbilightIcon({
    super.key,
    this.icon = Icons.tv,
    this.size = 19.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Efeito de luz ao fundo
        Container(
          width: size * 2, // Proporcional ao tamanho do ícone
          height: size * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                Colors.transparent,
              ],
              stops: [0.6, 1.0],
            ),
          ),
        ),
        // Ícone
        Icon(
          icon,
          size: size,
        ),
      ],
    );
  }
}
