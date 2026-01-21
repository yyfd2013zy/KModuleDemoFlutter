# KModule Flutter Demo

This is a KModuleDemo  application developed based on Flutter, used to control  hardware modules, including LED lights, card readers, relays, and buzzers.

## Features

### Serial Port Management
- Support opening and closing serial port connections
- Support configuring serial port parameters (baud rate, data bits, stop bits, parity)
- Real-time display of serial port communication logs

### LED Control
- Basic color control: red, green, blue light on/off
- Blink control: red, green, blue light blink mode
- Marquee effect
- Brightness adjustment: full brightness, 50% brightness
- Custom color: support RGB color selection and control

### Card Reader Control
- Send super administrator card
- Virtual Wiegand signal
- Card output format settings: DEC, HEX, DEC reverse

### Relay and Buzzer Control
- Relay on/off control
- Buzzer on/off control
- Set opening time
- Remote opening function

## Technology Stack

- Flutter: Cross-platform UI framework
- Dart: Programming language
- flutter_libserialport: Serial port communication library

## Installation and Running

### Prerequisites
- Flutter SDK: 3.0.0 or above
- Supported platforms: Windows, Linux, macOS (requires corresponding libserialport library support)

### Installation Steps

1. Clone the project
```bash
git clone https://github.com/yyfd2013zy/KModuleDemoFlutter
cd kmodule_flutter
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the project
```bash
flutter run
```

## Project Structure

```
├── lib/
│   └── main.dart          # Main application code
├── pubspec.yaml           # Project configuration and dependencies
└── README.md              # Project documentation
```

## Usage Instructions

1. Select serial port device from the drop-down menu
2. Click "Open" button to open serial port connection
3. Use control buttons of different modules to send commands
4. View serial port communication records in the log panel
5. Click "Close" button to close serial port after completion

## Serial Communication Protocol

The application uses a custom serial communication protocol, and the command format is as follows:
```
AA [CMD] [LENGTH] [DATA...] 55
```
- `AA`: Start character
- `CMD`: Command code
- `LENGTH`: Data length
- `DATA`: Data content
- `55`: End character
