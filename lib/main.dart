import 'dart:async';
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

  final List<String> _ports =
  List.generate(7, (i) => 'dev/ttyS${i + 1}');
  String _selectedPort = 'dev/ttyS3';

  SerialPort? _serialPort;

  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _readerSub;

  Color _pickedColor = Colors.red;


  // ================= utils =================

  void _log(String msg) {
    setState(() {
      _logs.add(
        '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg',
      );
    });
  }

  void _sendCommand(String label, List<int> bytes) {
    if (_serialPort == null || !_serialPort!.isOpen) {
      _log('Port not open, ignore [$label]');
      return;
    }
    final data = Uint8List.fromList(bytes);
    _serialPort!.write(data);
    _log(
      'Send [$label] → ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );
  }

  // ================= serial =================

  void _openPort() {
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

      _startRead(); // 新增：开始读
    } catch (e) {
      _log('Exception: $e');
    }
  }


  void _startRead() {
    if (_serialPort == null) return;

    _reader = SerialPortReader(_serialPort!);

    _readerSub = _reader!.stream.listen(
          (data) {
        final hex = data
            .map((e) => e.toRadixString(16).padLeft(2, '0'))
            .join(' ');

        _log('Recv ← $hex');
      },
      onError: (e) {
        _log('Read error: $e');
      },
      onDone: () {
        _log('Serial stream closed');
      },
    );

    _log('Start listening serial data');
  }


  void _closePort() {
    _serialPort?.close();
    _serialPort = null;
    _log('Port closed');
  }

  // ================= LED =================

  void _controlLed(String label) {
    switch (label) {
      case 'RED_ON':
        _sendCommand(label, [0xAA, 0x13, 0x01, 0x01, 0x55]);
        break;
      case 'GREEN_ON':
        _sendCommand(label, [0xAA, 0x13, 0x01, 0x02, 0x55]);
        break;
      case 'BLUE_ON':
        _sendCommand(label, [0xAA, 0x13, 0x01, 0x03, 0x55]);
        break;
      case 'RED_BLINK':
        _sendCommand(label, [0xAA, 0x14, 0x01, 0x01, 0x55]);
        break;
      case 'GREEN_BLINK':
        _sendCommand(label, [0xAA, 0x14, 0x01, 0x02, 0x55]);
        break;
      case 'BLUE_BLINK':
        _sendCommand(label, [0xAA, 0x14, 0x01, 0x03, 0x55]);
        break;
      case 'MARQUEE':
        _sendCommand(label, [0xAA, 0x15, 0x00, 0x00, 0x55]);
        break;
      case 'OFF':
        _sendCommand(label, [0xAA, 0x12, 0x00, 0x00, 0x55]);
        break;
      case 'FULL_BRIGHTNESS':
        _sendCommand(label, [0xAA, 0x28, 0x00, 0x00, 0x55]);
        break;
      case 'SET_BRIGHTNESS_50':
        _sendCommand(label, [0xAA, 0x28, 0x01, 0x32, 0x55]);
        break;
      case 'CUSTOM_COLOR_ON':
        _sendCommand(label, [0xAA, 0x25, 0x03, 0xCC, 0x33, 0xFF, 0x55]);
        break;
      case 'CUSTOM_COLOR_BLINK':
        _sendCommand(label, [0xAA, 0x26, 0x03, 0x00, 0x00, 0xFF, 0x55]);
        break;
    }
  }

  // ================= Card Reader =================

  void _controlCardReader(String label) {
    switch (label) {
      case 'SEND_SUPER_ADMIN_CARD':
        _sendCommand(label,
            [0xAA, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00, 0x55]);
        break;
      case 'VIRTUAL_WIEGAND':
        _sendCommand(label, [0xAA, 0x08, 0x04, 0x55]);
        break;
      case 'CARD_OUTPUT_DEC':
        _sendCommand(label,
            [0xAA, 0xBB, 0x06, 0x00, 0x00, 0x00, 0x01, 0x06, 0x02, 0x05]);
        break;
      case 'CARD_OUTPUT_HEX':
        _sendCommand(label,
            [0xAA, 0xBB, 0x06, 0x00, 0x00, 0x00, 0x01, 0x06, 0x03, 0x04]);
        break;
      case 'CARD_OUTPUT_DEC_REVERSE':
        _sendCommand(label,
            [0xAA, 0xBB, 0x06, 0x00, 0x00, 0x00, 0x01, 0x06, 0x04, 0x03]);
        break;
    }
  }

  // ================= Relay =================

  void _controlRelay(String label) {
    switch (label) {
      case 'RELAY_ON':
        _sendCommand(label, [0xAA, 0x03, 0x00, 0x00, 0x55]);
        break;
      case 'RELAY_OFF':
        _sendCommand(label, [0xAA, 0x04, 0x00, 0x00, 0x55]);
        break;
      case 'BEEP_ON':
        _sendCommand(label, [0xAA, 0x09, 0x01, 0x00, 0x55]);
        break;
      case 'BEEP_OFF':
        _sendCommand(label, [0xAA, 0x09, 0x01, 0x01, 0x55]);
        break;
      case 'SET_OPEN_TIME':
        _sendCommand(label, [0xAA, 0x01, 0x01, 0x03, 0x55]);
        break;
      case 'REMOTE_OPEN':
        _sendCommand(label, [0xAA, 0x02, 0x00, 0x00, 0x55]);
        break;
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serial Debug Tool')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildLogPanel(),
            _buildPortBar(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _section(
                    title: 'LED Control',
                    children: [
                      _cmdBtn('Red On', () => _controlLed('RED_ON')),
                      _cmdBtn('Green On', () => _controlLed('GREEN_ON')),
                      _cmdBtn('Blue On', () => _controlLed('BLUE_ON')),
                      _cmdBtn('Red Blink', () => _controlLed('RED_BLINK')),
                      _cmdBtn('Green Blink', () => _controlLed('GREEN_BLINK')),
                      _cmdBtn('Blue Blink', () => _controlLed('BLUE_BLINK')),
                      _cmdBtn('Marquee', () => _controlLed('MARQUEE')),
                      _cmdBtn('Off', () => _controlLed('OFF')),
                      _cmdBtn('Full Bright', () => _controlLed('FULL_BRIGHTNESS')),
                      _cmdBtn('Bright 50%', () => _controlLed('SET_BRIGHTNESS_50')),
                      _cmdBtn('Custom Color On', () => _showColorPicker(blink: false)),
                      _cmdBtn('Custom Color Blink', () => _showColorPicker(blink: true)),
                    ],
                  ),
                  _section(
                    title: 'Card Reader',
                    children: [
                      _cmdBtn('Admin Card',
                              () => _controlCardReader('SEND_SUPER_ADMIN_CARD')),
                      _cmdBtn('Virtual Wiegand',
                              () => _controlCardReader('VIRTUAL_WIEGAND')),
                      _cmdBtn('DEC',
                              () => _controlCardReader('CARD_OUTPUT_DEC')),
                      _cmdBtn('HEX',
                              () => _controlCardReader('CARD_OUTPUT_HEX')),
                      _cmdBtn('DEC Rev',
                              () => _controlCardReader('CARD_OUTPUT_DEC_REVERSE')),
                    ],
                  ),
                  _section(
                    title: 'Relay / Beep',
                    children: [
                      _cmdBtn('Relay On', () => _controlRelay('RELAY_ON')),
                      _cmdBtn('Relay Off', () => _controlRelay('RELAY_OFF')),
                      _cmdBtn('Beep On', () => _controlRelay('BEEP_ON')),
                      _cmdBtn('Beep Off', () => _controlRelay('BEEP_OFF')),
                      _cmdBtn('Set Open Time',
                              () => _controlRelay('SET_OPEN_TIME')),
                      _cmdBtn('Remote Open',
                              () => _controlRelay('REMOTE_OPEN')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortBar() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedPort,
            decoration: const InputDecoration(
              labelText: 'Serial Port',
              border: OutlineInputBorder(),
            ),
            items: _ports
                .map((e) =>
                DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _selectedPort = v!),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _openPort, child: const Text('Open')),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _closePort, child: const Text('Close')),
      ],
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: children),
          ],
        ),
      ),
    );
  }

  Widget _cmdBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildLogPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        width: double.infinity, // ⭐ 关键：占满父级可用宽度
        height: 200,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black,
          child: SingleChildScrollView(
            reverse: true,
            child: Text(
              _logs.join('\n'),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker({
    required bool blink,
  }) async {
    int r = _pickedColor.red;
    int g = _pickedColor.green;
    int b = _pickedColor.blue;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select LED Color'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, r, g, b),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _colorSlider(
                    label: 'R',
                    value: r,
                    color: Colors.red,
                    onChanged: (v) => setState(() => r = v),
                  ),
                  _colorSlider(
                    label: 'G',
                    value: g,
                    color: Colors.green,
                    onChanged: (v) => setState(() => g = v),
                  ),
                  _colorSlider(
                    label: 'B',
                    value: b,
                    color: Colors.blue,
                    onChanged: (v) => setState(() => b = v),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _pickedColor = Color.fromARGB(255, r, g, b);

                _sendCustomColor(
                  r: r,
                  g: g,
                  b: b,
                  blink: blink,
                );

                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
  void _sendCustomColor({
    required int r,
    required int g,
    required int b,
    required bool blink,
  }) {
    final cmd = blink ? 0x26 : 0x25;

    _sendCommand(
      blink ? 'CUSTOM_COLOR_BLINK' : 'CUSTOM_COLOR_ON',
      [0xAA, cmd, 0x03, r, g, b, 0x55],
    );
  }

  Widget _colorSlider({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            activeColor: color,
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.toString()),
        ),
      ],
    );
  }


}
