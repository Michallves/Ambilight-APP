import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  height: 32,
                ),
                const Text(
                  'Pagina não encotrada',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(
                  height: 32,
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: FilledButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Voltar')),
                )
              ],
            ),
          ),
        ),
      ),
    )));
  }
}
