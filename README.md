# DoorDarshanLive

Smart doorbell ecosystem — **Windows desktop client** built with Qt/QML.

DoorDarshanLive is the desktop companion application for a smart doorbell system. This repository contains the Windows client; the Raspberry Pi backend lives in a separate repository: [dd-rpi-backend](https://github.com/tarang-soni/dd-rpi-backend).

> **Note:** Screenshots below are placeholders. Replace `docs/images/*.png` with real captures.

## About

A smart doorbell ecosystem with a Qt/QML desktop client and Raspberry Pi backend. The desktop app discovers the Pi on the network, opens a control channel over TCP, and renders the doorbell camera's live feed in real time using GStreamer.

### Features

- **Real-time camera streaming** from the Raspberry Pi to the desktop app using GStreamer (RTP/JPEG over UDP).
- **Event-driven architecture** for doorbell notifications, snapshot capture, and remote device communication (Qt signal/slot wiring).
- **Remote device communication** — a lightweight single-byte command protocol over TCP.
- **Automatic device discovery** — UDP broadcast to locate the Pi on the local network.
- **Live status dashboards** — device connection state, stream state, and system information.

## Screenshots

| Dashboard | Device Setup |
|:---------:|:------------:|
| ![Dashboard](docs/images/dashboard.png) | ![Device Setup](docs/images/device-setup.png) |

| History | Settings |
|:-------:|:--------:|
| ![History](docs/images/history.png) | ![Settings](docs/images/settings.png) |

## Architecture

![Architecture](docs/images/architecture.png)

The application follows an event-driven, layered architecture. Components are wired together in `AppController` via Qt signals/slots, and exposed to QML as context properties.

| Component | Layer | Responsibility |
|-----------|-------|----------------|
| `AppController` | core | Central coordinator; wires network, UI, and video together |
| `NetworkManager` | network | Coordinates TCP command transport and device discovery |
| `TcpConnector` | network | TCP server that accepts the Pi's connection and exchanges command bytes |
| `DiscoveryService` | network | UDP broadcast (`DD_DISCOVERY`) to locate the Pi |
| `UIManager` | ui | Bridge between QML and the C++ core; exposes `piConnected`/`isStreaming` |
| `VideoBridge` | video | GStreamer pipeline that decodes the RTP/JPEG stream into frames |
| `CameraImageProvider` | video | `QQuickImageProvider` that feeds frames to QML (`image://camera/live`) |

### Video pipeline

The Pi streams RTP/JPEG over UDP to the desktop app. `VideoBridge` runs the following GStreamer pipeline:

```
udpsrc port=5000
  ! application/x-rtp, media=video, encoding-name=JPEG, payload=26
  ! rtpjitterbuffer
  ! rtpjpegdepay
  ! jpegdec
  ! videoconvert
  ! video/x-raw, format=RGBA
  ! appsink
```

Frames are pulled from the appsink, converted to `QImage`, and served to QML through `CameraImageProvider`.

## Communication Protocol

The desktop app and the Pi exchange **single-byte commands** over TCP.

### Desktop → Pi (`ServerCommand`)

| Command | Value | Description |
|---------|-------|-------------|
| `StartStream` | `0x00` | Ask the Pi to begin streaming video |
| `StopStream` | `0x01` | Ask the Pi to stop streaming |
| `Ping` | `0x02` | Heartbeat / keep-alive |
| `Reboot` | `0x03` | Reboot the remote device |
| `Quit` | `0x04` | Terminate the remote session |

### Pi → Desktop (`ClientResponse`)

| Response | Value | Description |
|----------|-------|-------------|
| `ConnectionSuccess` | `0x10` | Connection established |
| `StreamStarted` | `0x20` | Streaming has begun |
| `StreamStopped` | `0x30` | Streaming has stopped |
| `ErrorDeviceBusy` | `0x40` | Device is busy |
| `Pong` | `0x50` | Reply to a ping |
| `ConnectionEnded` | `0x60` | Client requested disconnect |

### Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| `1234` | TCP | Command / control channel |
| `40000` | UDP | Device discovery |
| `5000` | UDP | RTP/JPEG video stream |

## Tech Stack

- **Qt 6.11.1** (Quick, Network)
- **QML** (UI, `Theme` singleton, reusable components)
- **C++** (core logic, protocol, video)
- **GStreamer 1.0** (video decoding pipeline)
- **CMake** (build system)

## Project Structure

```
qt_DoorDarshanLive/
├── CMakeLists.txt
├── main.cpp
├── Main.qml
├── qml/
│   ├── Theme.qml
│   ├── SidePanel.qml
│   ├── SidebarButton.qml
│   ├── PageFrame.qml
│   ├── StatusRow.qml
│   ├── BoolStatusRow.qml
│   ├── HeadingText.qml
│   ├── CustomBorder.qml
│   ├── DashboardScreen.qml
│   ├── HistoryScreen.qml
│   ├── DeviceSetupScreen.qml
│   ├── SettingsScreen.qml
│   └── Dashboard/
│       ├── Dashboard_ControlPanel.qml
│       ├── Dashboard_DeviceStats.qml
│       ├── Dashboard_SystemInfo.qml
│       └── Dashboard_RecentActivity.qml
├── src/
│   ├── core/
│   │   ├── appcontroller.{h,cpp}
│   │   └── utils.h
│   ├── network/
│   │   ├── networkmanager.{h,cpp}
│   │   ├── tcpconnector.{h,cpp}
│   │   ├── discoveryservice.{h,cpp}
│   │   ├── Protocol.h
│   │   └── tcptestsocket.{h,cpp}
│   ├── ui/
│   │   └── uimanager.{h,cpp}
│   └── video/
│       ├── videobridge.{h,cpp}
│       └── cameraimageprovider.{h,cpp}
└── resources/
    └── fonts/
```

## Prerequisites

- **Qt 6.11.1** with the **MinGW 64-bit** kit (Qt Creator recommended)
- **GStreamer 1.0** runtime + development files (`gstreamer-1.0`, `gstreamer-video-1.0`, `gstreamer-app-1.0`)
- **CMake** ≥ 3.16
- **pkg-config** (with `PKG_CONFIG_PATH` pointing at GStreamer's `lib/pkgconfig`)

## Build

The project is configured via CMake and is easiest to build from Qt Creator with the `Desktop Qt 6.11.1 MinGW 64-bit` kit.

Set the GStreamer pkg-config path before configuring, e.g.:

```powershell
$env:PKG_CONFIG_PATH = "D:/Dev/Environments/GStreamer/1.0/mingw_x86_64/lib/pkgconfig"
```

Then configure and build with CMake (or use Qt Creator):

```powershell
cmake -B build -G "Ninja" -DCMAKE_PREFIX_PATH="<Qt-6.11.1-install-path>"
cmake --build build
```

## Usage

1. Power on the Raspberry Pi (running the [dd-rpi-backend](https://github.com/tarang-soni/dd-rpi-backend) backend) on the same network.
2. Launch the desktop application.
3. Use **Setup** → **Find Pi** to discover the device, then **Connect**.
4. On the **Dashboard**, toggle **Camera : ON** to start the live stream.

## Status / Roadmap

The core client is functional, but several areas are still in progress:

- [x] Live RTP/JPEG streaming via GStreamer
- [x] TCP command protocol + UDP device discovery
- [x] Event-driven signal/slot architecture
- [ ] Snapshot capture (button wired, handler not implemented)
- [ ] Doorbell notifications
- [ ] Motion detection toggle (UI-local only)
- [ ] Dynamic system info (currently placeholder values)
- [ ] Move hardcoded ports/addresses into a shared config header
- [ ] Implement `UIManager::requestQuit()`
