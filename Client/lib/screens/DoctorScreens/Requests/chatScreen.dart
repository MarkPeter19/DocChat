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
        title: const Text('Chat with AI', style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 14, 9, 26),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white, 
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      ),
      body: Container(
        color: Color.fromARGB(255, 49, 28, 88),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // To start from the bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
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
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color.fromARGB(255, 85, 47, 155), 
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final String sender = message['sender'];
    final String content = message['content'];
    final bool isAI = sender == 'AI';
    final Color bubbleColor = isAI ? Color.fromARGB(255, 0, 0, 0) : Color.fromARGB(255, 133, 62, 255);

    return Align(
      alignment: isAI ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          content,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      Map<String, dynamic> newMessage = {'sender': 'Doctor', 'content': message, 'timestamp': DateTime.now()};
      _messages.insert(0, newMessage);

      try {
        String sourceId = await widget.chatPDFService.addPDFViaURL(widget.pdfUrl);
        String response = await widget.chatPDFService.askQuestion(
          sourceId,
          [{'role': 'user', 'content': message}],
        );

        setState(() {
          _messages.insert(0, {'sender': 'AI', 'content': response, 'timestamp': DateTime.now()});
        });

        if (_messages.first['sender'] == 'AI') {
          await widget.chatPDFService.saveChatMessagesToFirestore(widget.pdfUrl, widget.doctorId, [newMessage, _messages.first]);
        }
      } catch (e) {
        print('Error sending message: $e');
      }

      _messageController.clear();
    }
  }
}
