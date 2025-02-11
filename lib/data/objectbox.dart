import 'package:offnet/data/models.dart';
import 'package:offnet/objectbox.g.dart';
import 'package:offnet/core/logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class ObjectBox {
  late Store store;

  late final Box<OtherUserEntity> otherUserBox;
  late final Box<SelfUserEntity> selfUserBox;
  late final Box<Message> messageBox;

  ObjectBox._create(this.store) {
    otherUserBox = Box<OtherUserEntity>(store);
    selfUserBox = Box<SelfUserEntity>(store);
    messageBox = Box<Message>(store);

    _addDummyData();
  }

  bool isAuthenticated() {
    return !selfUserBox.isEmpty();
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    if (Admin.isAvailable()) {
      Admin(store); // Enable Admin panel
      AppLogger.info('Admin is iniitialized');
    }

    return ObjectBox._create(store);
  }

  void _addDummyData() {
    if (otherUserBox.isEmpty()) {
      final user1 = OtherUserEntity(
        id: 0,
        name: 'Alice',
        uniqueId: 'alice123',
        publicKey: 'alicePublicKey',
        chatEncryptionKey: 'aliceChatKey',
      );
      final user2 = OtherUserEntity(
        id: 0,
        name: 'Bob',
        uniqueId: 'bob123',
        publicKey: 'bobPublicKey',
        chatEncryptionKey: 'bobChatKey',
      );
      otherUserBox.putMany([user1, user2]);

      final message1 = Message(
        content: 'Hello, Bob!',
        timestamp: DateTime.now(),
        isFromMe: true,
      )..otherUser.target = user1;

      final message2 = Message(
        content: 'Hi, Alice!',
        timestamp: DateTime.now(),
        isFromMe: false,
      )..otherUser.target = user2;

      messageBox.putMany([message1, message2]);
    }
  }

  void initializeSelf(SelfUserEntity selfUser) {
    selfUserBox.put(selfUser);
    AppLogger.info(
        'User: ${selfUser.name}, ID: ${selfUser.uniqueId}, PublicKey: ${selfUser.publicKey} is successfully initialized');
  }
}
