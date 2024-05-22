import 'package:flutter/material.dart';
import 'package:doctorgpt/services/chatPDF_services';

class ChatScreen extends StatefulWidget {
  final String pdfUrl; 
  final String doctorId;
  final ChatPDFService chatPDFService;

  const ChatScreen({
    Key? key,
    required this.pdfUrl, 
    required this.doctorId,
    required this.chatPDFService,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]['sender']),
                  subtitle: Text(_messages[index]['content']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
  String message = _messageController.text.trim();
  if (message.isNotEmpty) {
    // Csak az új üzenetet adjuk hozzá a _messages listához
    Map<String, dynamic> newMessage = {'sender': 'Doctor', 'content': message, 'timestamp': DateTime.now()};
    _messages.add(newMessage);

    try {
      // Hozzáadja a PDF-t és elmenti az azonosítót
      String sourceId = await widget.chatPDFService.addPDFViaURL(widget.pdfUrl);

      // Küldi a kérdést a PDF-hez és megkapja a választ
      String response = await widget.chatPDFService.askQuestion(
        sourceId,
        [{'role': 'user', 'content': message}],
      );

      // Hozzáadja az AI választ az üzenetek listájához
      setState(() {
        _messages.add({'sender': 'AI', 'content': response, 'timestamp': DateTime.now()});
      });

      // Csak az AI válaszait mentjük Firestore-ba
      if (_messages.last['sender'] == 'AI') {
        await widget.chatPDFService.saveChatMessagesToFirestore(widget.pdfUrl, widget.doctorId, [newMessage, _messages.last]);
      }
    } catch (e) {
      // Hiba kezelése
      print('Error sending message: $e');
    }

    // Üzenetmező törlése
    _messageController.clear();
  }
}


}
