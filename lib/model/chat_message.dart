import 'dart:convert';

class ChatMessage {
  String content;
  String sender;
  String? type;

  ChatMessage({
    required this.content,
    required this.sender,
    this.type,
  });
  

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'sender': sender,
      'type': type,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      content: map['content'] ?? '',
      sender: map['sender'] ?? '',
      type: map['type'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) => ChatMessage.fromMap(json.decode(source));
}
