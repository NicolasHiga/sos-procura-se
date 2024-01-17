import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';

class MiloPage extends StatelessWidget {
  const MiloPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fale com Milo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/milo.png',
                height: MediaQuery.of(context).size.height * 0.30,
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Milo',
                      style: TextStyle(
                        color: ColorsApp.instance.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' é o nosso assistente virtual pronto para ajudar com todas as suas dúvidas e necessidades. Ele está aqui para orientá-lo no que precisar, tornando a sua experiência mais fácil.',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/home/milo/chat');
                  },
                  child: const Text(
                    'Converse com Milo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
