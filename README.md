# AmbilightApp

## Descrição
O **AmbilightApp** é uma aplicação exclusiva para o sistema operacional Windows, desenvolvida em Flutter, que proporciona uma experiência imersiva ao controlar fitas de LED via Bluetooth.

## Funcionalidades Principais
- **Controle de Fitas de LED via Bluetooth**: Permite ligar, desligar e ajustar cores das fitas de LED de forma simples.
- **Modo Ambilight**: Captura a tela do computador, identifica a cor predominante (considerando bordas e fundo) e reflete essa cor na fita de LED.

O projeto foi desenvolvido seguindo a **Clean Architecture** e os princípios de **Clean Code**, garantindo modularidade, escalabilidade e facilidade de manutenção.

---

## Tecnologias Usadas e Versões
- **Flutter**: 3.24.5
- **Dart**
- **Bluetooth LE (Low Energy)**
- **Sistema Operacional**: Windows 11
- **Firmware da Fita de LED**: 0x53

### Comunicação via Bluetooth
Os comandos foram desenvolvidos com base em engenharia reversa para operar os dispositivos compatíveis.

#### Comandos de Controle de Energia
- **Ligar a fita de LED**:
  ```plaintext
  00 04 80 00 00 0d 0e 0b 3b 23 00 00 00 00 00 00 00 32 00 00 90
  ```

- **Desligar a fita de LED**:
  ```plaintext
  00 5b 80 00 00 0d 0e 0b 3b 24 00 00 00 00 00 00 00 32 00 00 91
  ```

#### Comandos de Controle de Cor (HSV)
O formato do pacote para controle de cor é:
```plaintext
00 05 80 00 00 0d 0e 0b 3b a1 [Hue] [Saturation] [Brightness] 00 00 00 00 00 00 00 00 [Checksum]
```
- **Hue**: Dividido por dois para caber em um único byte.
- **Saturation** e **Value**: Percentuais de 0 a 100 representados por valores hexadecimais (0x00 a 0x64).
- **Temperatura de Cor Branca (opcional)**: Percentual de 0 (quente) a 100 (frio).

**Exemplo de comando para cor**:
```plaintext
00 05 80 00 00 0d 0e 0b 3b a1 32 64 64 00 00 00 00 00 00 00 00 [Checksum]
```

---

## Implementação Técnica
- **Captura de Tela**: O aplicativo utiliza APIs nativas do Windows para capturar a tela do computador.
- **Processamento de Imagem**: Calcula a cor predominante com foco em bordas e fundo.
- **Comunicação Bluetooth**: Envia pacotes personalizados para ajustar energia e cor das fitas de LED.

---

## Requisitos do Sistema
- **Sistema Operacional**: Windows 11
- **Flutter**: Versão 3.24.5
- **Dispositivo Bluetooth LE**: Compatível com dispositivos Zengge

---

## Como Executar

1. Clone o repositório:
   ```bash
   git clone https://github.com/michallves/ambilightapp.git
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Conecte a fita de LED Bluetooth compatível.
4. Execute o aplicativo:
   ```bash
   flutter run -d windows
   ```

---

## Contribuição
Este é um projeto open-source, e contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests no repositório.

---

## Contato
- **Criador**: Michael Alves
- **GitHub**: [michallves](https://github.com/michallves)
- **Instagram**: [michallves](https://instagram.com/michallves)

---

## Licença
Este projeto está sob a licença MIT. Consulte o arquivo LICENSE para mais informações.
