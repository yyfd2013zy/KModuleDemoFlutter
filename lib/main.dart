import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serial Tool',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const SerialHomePage(),
    );
  }
}

class SerialHomePage extends StatefulWidget {
  const SerialHomePage({super.key});

  @override
  State<SerialHomePage> createState() => _SerialHomePageState();
}

class _SerialHomePageState extends State<SerialHomePage> {
  final List<String> _logs = [];

  /// 固定串口列表：dev/ttyS1 ~ dev/ttyS7
  final List<String> _ports =
  List.generate(7, (i) => 'dev/ttyS${i + 1}');

  /// 默认值
  String _selectedPort = 'dev/ttyS3';

  SerialPort? _serialPort;

  // ========= utils =========

  void _log(String msg) {
    setState(() {
      _logs.add(
        '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg',
      );
    });
  }

  // ========= serial =========

  void _openPort() {
    _log('Open port: $_selectedPort');

    try {
      _serialPort = SerialPort(_selectedPort);

      if (!_serialPort!.openReadWrite()) {
        _log('Open failed: ${SerialPort.lastError}');
        return;
      }

      _serialPort!.config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none;

      _log('Port opened: $_selectedPort');
    } catch (e) {
      _log('Exception: $e');
    }
  }

  void _closePort() {
    _serialPort?.close();
    _serialPort = null;
    _log('Port closed');
  }

  void _controlLed(String label) {
    if (_serialPort == null || !_serialPort!.isOpen) {
      _log('Port not open, ignore [$label]');
      return;
    }

    Uint8List data;

    switch (label) {
      case 'RED_ON':
        data = Uint8List.fromList([0xAA, 0x13, 0x01, 0x01, 0x55]);
        break;
      case 'GREEN_ON':
        data = Uint8List.fromList([0xAA, 0x13, 0x01, 0x02, 0x55]);
        break;
      case 'BLUE_ON':
        data = Uint8List.fromList([0xAA, 0x13, 0x02, 0x03, 0x55]);
        break;
      default:
        return;
    }

    _serialPort!.write(data);

    _log(
      'Send [$label] → ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );
  }

  // ========= UI =========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serial Debug Tool')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ======= serial select =======
            DropdownButtonFormField<String>(
              value: _selectedPort,
              decoration: const InputDecoration(
                labelText: 'Serial Port',
                border: OutlineInputBorder(),
              ),
              items: _ports
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => _selectedPort = v!),
            ),

            const SizedBox(height: 12),

            /// ======= open / close =======
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openPort,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Open'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _closePort,
                    icon: const Icon(Icons.stop),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ======= LED control =======
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _cmdBtn('Red On', () => _controlLed('RED_ON')),
                _cmdBtn('Green On', () => _controlLed('GREEN_ON')),
                _cmdBtn('Blue On', () => _controlLed('BLUE_ON')),
              ],
            ),

            const SizedBox(height: 16),

            /// ======= log =======
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _logs.join('\n'),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cmdBtn(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Text(text),
    );
  }
}
