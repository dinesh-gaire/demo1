import 'package:objectbox/objectbox.dart';

@Entity()
class SelfUserEntity {
  @Id(assignable: true)
  int id = 0;

  String name;
  String uniqueId;
  String? pathToImage;
  String privateKey;
  String publicKey;

  SelfUserEntity({
    required this.id,
    required this.name,
    required this.uniqueId,
    this.pathToImage,
    required this.privateKey,
    required this.publicKey,
  });
}

@Entity()
class OtherUserEntity {
  @Id(assignable: true)
  int id = 0;

  String name;
  String uniqueId;
  String? pathToImage;
  String? publicKey;
  String chatEncryptionKey;

  OtherUserEntity({
    required this.id,
    required this.name,
    required this.uniqueId,
    this.pathToImage,
    required this.publicKey,
    required this.chatEncryptionKey,
  });
}

@Entity()
class Message {
  @Id(assignable: true)
  int id = 0;
  final ToOne<OtherUserEntity> otherUser =
      ToOne<OtherUserEntity>(); // Relationship
  bool isFromMe;
  String content;
  DateTime timestamp;

  Message({
    required this.content,
    required this.timestamp,
    required this.isFromMe,
  });
}
