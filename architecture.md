# OffNet - Offline P2P Messaging &amp; File Transfer Architecture

## 1. Overview

OffNet is an offline communication application designed for peer-to-peer (P2P) messaging and file transfer without relying on internet connectivity. It leverages local networks (Wi-Fi/Ethernet) and hotspot connections for device discovery and communication. This document outlines the architectural design of OffNet, focusing on modularity, scalability, and maintainability.

## 2. Key Architectural Principles

*   **Modularity:** The architecture is divided into distinct modules, each responsible for a specific set of functionalities. This promotes code organization, reusability, and maintainability.
*   **Layered Architecture:** The application is structured in layers, separating concerns and responsibilities. This approach enhances testability and allows for independent development and modification of different parts of the application.
*   **Offline First:** The architecture prioritizes offline functionality. Data persistence and local storage are crucial for ensuring the application works seamlessly even without network connectivity.
*   **Security:** Security is integrated into the architecture from the ground up, with encryption and secure communication protocols being fundamental components.
*   **Flexibility:** The architecture is designed to be flexible and adaptable to different network environments (hotspot, local Wi-Fi, Ethernet) and potential future features.

## 3. Architectural Layers

OffNet&#x27;s architecture is based on a layered approach, comprising the following layers:

1.  **Presentation Layer (UI)**
2.  **Application Layer (Business Logic)**
3.  **Domain Layer (Core Logic)**
4.  **Infrastructure Layer (Platform Specifics)**

\`\`\`
+-------------------------+
| 1. Presentation Layer   | (UI - Flutter Widgets &amp; Screens)
+-------------------------+
          |
          | (Interactions, State Updates)
          v
+-------------------------+
| 2. Application Layer    | (Business Logic - Controllers, Use Cases, State Management)
+-------------------------+
          |
          | (Orchestration, Data Flow)
          v
+-------------------------+
| 3. Domain Layer         | (Core Logic - Entities, Repositories, Use Cases)
+-------------------------+
          |
          | (Platform Abstraction, Data Access)
          v
+-------------------------+
| 4. Infrastructure Layer | (Platform Specifics - Device Discovery, Network, Storage, Security)
+-------------------------+
\`\`\`

### 3.1. Presentation Layer (UI)

*   **Purpose:**  Responsible for rendering the user interface and handling user interactions. Built using Flutter widgets and screens.
*   **Components:**
    *   **Screens:**
        *   \`ChatScreen\`: Displays the chat interface for P2P and group conversations.
        *   \`FileTransferScreen\`: Manages file transfer processes and displays progress.
        *   \`DeviceDiscoveryScreen\`: Allows users to initiate and view device discovery.
        *   \`SettingsScreen\`: Provides application settings and configurations.
    *   **Widgets:** Reusable UI components used across different screens (e.g., message bubbles, device list items, custom buttons).
    *   **State Management:**  Utilizes a state management solution (e.g., Provider, BLoC, Riverpod) to manage UI state and react to changes in the application and domain layers.

### 3.2. Application Layer (Business Logic)

*   **Purpose:**  Acts as an intermediary between the Presentation Layer and the Domain Layer. It contains the application&#x27;s business logic, user flows, and state management orchestration.
*   **Components:**
    *   **Controllers/Managers:**
        *   \`DeviceDiscoveryManager\`: Manages device discovery processes (pinging, Wi-Fi Direct).
        *   \`ChatManager\`: Handles chat sessions, message sending, and receiving.
        *   \`FileManager\`: Manages file transfer operations, file storage, and retrieval.
        *   \`SettingsManager\`: Manages application settings and user preferences.
    *   **Use Cases/Interactors:** Implement specific user actions and business processes. Examples include:
        *   \`SendMessageUseCase\`: Handles sending messages to a peer.
        *   \`ReceiveMessageUseCase\`: Processes incoming messages.
        *   \`TransferFileUseCase\`: Manages the file transfer process.
        *   \`DiscoverDevicesUseCase\`: Initiates device discovery and returns a list of devices.
    *   **Application State:** Manages the overall application state, coordinating state changes between different modules.

### 3.3. Domain Layer (Core Logic)

*   **Purpose:** Contains the core business logic, entities, and rules of the application. It is independent of any specific platform or framework.
*   **Components:**
    *   **Entities:** Represent the core domain objects:
        *   \`Device\`: Represents a network device with properties like ID, name, IP address, connection type.
        *   \`Message\`: Represents a chat message with content, sender, receiver, timestamp, encryption status.
        *   \`File\`: Represents a file being transferred, including metadata, chunks, transfer status.
        *   \`Chat\`: Represents a chat session between devices, containing messages and participants.
        *   \`User\`: Represents the user of the application and their settings.
    *   **Repositories Interfaces:** Define interfaces for data access and persistence, abstracting away the data source implementation. Examples include:
        *   \`DeviceRepository\`: Interface for managing device data (e.g., storing discovered devices, retrieving device information).
        *   \`MessageRepository\`: Interface for storing and retrieving messages.
        *   \`FileRepository\`: Interface for managing file data and transfer status.
        *   \`ChatRepository\`: Interface for managing chat sessions.
    *   **Core Logic/Services:** Implement core functionalities and algorithms:
        *   \`EncryptionService\`: Handles AES encryption and decryption of messages and files.
        *   \`P2PCommunicationService\`: Manages P2P communication logic using TCP/IP sockets.
        *   \`FileChunkingService\`: Handles file chunking for efficient and reliable file transfer.
        *   \`DeviceDiscoveryService\`: Defines the logic for discovering devices on local networks and via hotspot.

### 3.4. Infrastructure Layer (Platform Specifics)

*   **Purpose:**  Provides concrete implementations for platform-specific functionalities and interacts with the underlying operating system and hardware.
*   **Components:**
    *   **Device Discovery Module:**
        *   \`WiFiDirectDiscovery\`: Implements device discovery using Wi-Fi Direct APIs.
        *   \`NetworkPingingDiscovery\`: Implements device discovery by pinging devices in the local network.
    *   **Network Module:**
        *   \`SocketManager\`: Manages TCP/IP socket connections for messaging and file transfer.
        *   \`UDPSocketManager\` (Optional): For specific file transfer scenarios where UDP might be suitable.
    *   **Data Persistence Module:**
        *   \`LocalDatabase\`: Implements local data storage using a database like SQLite or Hive for messages, files, devices, and settings.
    *   **Security Module:**
        *   \`AESEncryptionImpl\`: Concrete implementation of \`EncryptionService\` using AES encryption algorithms.
    *   **Platform Services:** Wrappers around platform-specific APIs:
        *   \`BluetoothService\`: Interface for Bluetooth functionalities (if Bluetooth discovery or communication is added in the future).
        *   \`WiFiService\`: Interface for Wi-Fi related functionalities.

## 4. Technology Stack

*   **Programming Language:** Dart
*   **UI Framework:** Flutter
*   **State Management:** (To be decided based on project complexity, options include Provider, BLoC, Riverpod)
*   **Local Database:** SQLite (via sqflite package) or Hive
*   **Networking:** Dart \`dart:io\` library for TCP/IP sockets
*   **Encryption:**  \`encrypt\` package for AES encryption

## 5. Communication Flow

1.  **Device Discovery:**
    *   \`DeviceDiscoveryScreen\` in the Presentation Layer triggers \`DiscoverDevicesUseCase\` in the Application Layer.
    *   \`DiscoverDevicesUseCase\` uses \`DeviceDiscoveryService\` (from Domain Layer) which in turn utilizes \`WiFiDirectDiscovery\` or \`NetworkPingingDiscovery\` (from Infrastructure Layer) to discover devices.
    *   Discovered devices are returned through layers and displayed on the \`DeviceDiscoveryScreen\`.

2.  **Sending a Message:**
    *   User types a message in \`ChatScreen\` (Presentation Layer) and triggers \`SendMessageUseCase\` (Application Layer).
    *   \`SendMessageUseCase\` creates a \`Message\` entity in the Domain Layer and uses \`P2PCommunicationService\` to send the message via \`SocketManager\` (Infrastructure Layer).
    *   \`EncryptionService\` is used to encrypt the message before sending.
    *   \`MessageRepository\` is used to persist the sent message locally.

3.  **Receiving a Message:**
    *   \`SocketManager\` (Infrastructure Layer) receives an incoming message.
    *   The message is passed to \`P2PCommunicationService\` (Domain Layer) and then to \`ReceiveMessageUseCase\` (Application Layer).
    *   \`EncryptionService\` decrypts the message.
    *   \`MessageRepository\` stores the received message.
    *   The Application Layer updates the state, and the \`ChatScreen\` (Presentation Layer) is updated to display the new message.

4.  **File Transfer:**
    *   \`FileTransferScreen\` (Presentation Layer) initiates \`TransferFileUseCase\` (Application Layer).
    *   \`TransferFileUseCase\` uses \`FileManager\` and \`P2PCommunicationService\` (Domain Layer) to manage file transfer via \`SocketManager\` (Infrastructure Layer).
    *   \`FileChunkingService\` is used to chunk the file for efficient transfer.
    *   \`FileRepository\` manages file metadata and transfer status.

## 6. Benefits of this Architecture

*   **Clear Separation of Concerns:** Each layer and module has a well-defined responsibility, making the codebase easier to understand, maintain, and debug.
*   **Improved Testability:**  Layers can be tested independently (e.g., unit testing Domain Layer logic without UI dependencies).
*   **Reusability:** Domain Layer and Infrastructure Layer components can be reused across different parts of the application or in future projects.
*   **Scalability and Maintainability:** The modular design makes it easier to add new features, modify existing ones, and scale the application as needed.
*   **Platform Independence (Domain Layer):** The core business logic in the Domain Layer is platform-agnostic, making it potentially reusable for other platforms in the future.

## 7. Future Considerations

*   **Bluetooth Support:**  Adding Bluetooth for device discovery and communication could expand the application&#x27;s reach in environments without Wi-Fi.
*   **Group Messaging Enhancements:** Implementing features like message delivery receipts, read statuses, and more advanced group management.
*   **Optimized File Transfer:** Exploring UDP for file transfer in specific scenarios to improve speed, while maintaining TCP for reliability when needed.
*   **Security Audits:**  Regular security audits to ensure the encryption and security measures are robust and up-to-date.

This architecture provides a solid foundation for developing the OffNet application. By adhering to these principles and layer structure, the project can be developed in a structured, maintainable, and scalable manner.