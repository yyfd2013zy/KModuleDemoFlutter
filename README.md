# KModule Flutter Demo
[English Version](README_EN.md) | 中文版本

这是一个基于Flutter开发的KModuleDemo应用，用于控制和调试硬件模块，包括LED灯、读卡器、继电器和蜂鸣器等。

## 功能特性

### 串口管理
- 支持串口连接的打开和关闭
- 支持配置串口参数（波特率、数据位、停止位、校验位）
- 实时显示串口通信日志

### LED控制
- 基本颜色控制：红、绿、蓝灯的开关
- 闪烁控制：红、绿、蓝灯的闪烁模式
- 跑马灯效果
- 亮度调节：全亮度、设置亮度
- 自定义颜色：支持RGB颜色选择和控制

### 读卡器控制
- 发送超级管理员卡
- 虚拟韦根信号
- 卡输出格式设置：DEC、HEX、DEC反向

### 继电器和蜂鸣器控制
- 继电器开关控制
- 蜂鸣器开关控制
- 设置开门时间
- 远程开门功能

## 技术栈

- Flutter：跨平台UI框架
- Dart：编程语言
- flutter_libserialport：串口通信库

## 安装和运行

### 前置条件
- Flutter SDK：3.0.0及以上
- 支持的平台：Windows、Linux、macOS（需要对应的libserialport库支持）

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/yyfd2013zy/KModuleDemoFlutter
cd kmodule_flutter
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行项目
```bash
flutter run
```

## 项目结构

```
├── lib/
│   └── main.dart          # 主应用代码
├── pubspec.yaml           # 项目配置和依赖
└── README.md              # 项目说明文档
```

## 使用说明

1. 从下拉菜单选择串口设备
2. 点击"Open"按钮打开串口连接
3. 使用不同模块的控制按钮发送命令
4. 在日志面板查看串口通信记录
5. 完成后点击"Close"按钮关闭串口

## 串口通信协议

应用使用自定义的串口通信协议，命令格式如下：
```
AA [CMD] [LENGTH] [DATA...] 55
```
- `AA`：起始符
- `CMD`：命令代码
- `LENGTH`：数据长度
- `DATA`：数据内容
- `55`：结束符