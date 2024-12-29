import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir a URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isDesktop ? height / 6 : height / 14),
                const Text(
                  'AmbilightApp',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'O AmbilightApp foi criado para proporcionar uma experiência imersiva '
                  'controlando fitas de LED via Bluetooth. O aplicativo permite:\n\n'
                  '- Controlar fitas de LED de forma simples.\n'
                  '- Habilitar o modo Ambilight, que captura de forma inteligente a cor predominante '
                  'do fundo da tela do computador e reflete essa cor na fita de LED.\n\n'
                  'Este programa funciona exclusivamente no sistema operacional Windows.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildSocialButton(
                  widget: const Icon(Icons.code, size: 24, color: Colors.white),
                  label: 'Ver Código no GitHub',
                  color: Colors.blueGrey.shade900,
                  onTap: () =>
                      _openUrl('https://github.com/Michallves/Ambilight-APP'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Criado por Michael Alves',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 32),
                const Text(
                  'Redes Sociais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      widget: Image.asset('assets/images/github_icon.png',
                          width: 24),
                      label: 'GitHub',
                      color: Colors.blueGrey.shade900,
                      onTap: () => _openUrl('https://github.com/michallves'),
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      widget: Image.asset('assets/images/instagram_icon.png',
                          width: 24),
                      label: 'Instagram',
                      color: Colors.blueGrey.shade900,
                      onTap: () => _openUrl('https://instagram.com/michallves'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 40),
                const SizedBox(height: 16),
                const Text(
                  'Versão: V1.1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget widget,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
