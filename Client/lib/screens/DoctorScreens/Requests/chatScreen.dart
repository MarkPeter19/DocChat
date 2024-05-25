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
  List<Map<String, dynamic>> _messages = [];
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _loadChatMessages(); 
    _scrollController = ScrollController(initialScrollOffset: 10000.0);
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final String sender = message['sender'];
    final String content = message['content'];
    final DateTime timestamp = message['timestamp'];
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              '${timestamp.hour}:${timestamp.minute}', // Display only hour and minute
              style: TextStyle(color: Color.fromARGB(255, 187, 186, 186), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      Map<String, dynamic> newMessage = {'sender': 'Doctor', 'content': message, 'timestamp': DateTime.now()};
      _messages.add(newMessage); // Adjuk hozzá az üzenetet a listához

      try {
        String sourceId = await widget.chatPDFService.addPDFViaURL(widget.pdfUrl);
        String response = await widget.chatPDFService.askQuestion(
          sourceId,
          [{'role': 'user', 'content': message}],
        );

        setState(() {
          _messages.add({'sender': 'AI', 'content': response, 'timestamp': DateTime.now()});
        });

        if (_messages.last['sender'] == 'AI') {
          await widget.chatPDFService.saveChatMessagesToFirestore(widget.pdfUrl, widget.doctorId, [newMessage, _messages.last]);
        }
      } catch (e) {
        print('Error sending message: $e');
      }

      _messageController.clear();

    }
  }

  void _loadChatMessages() async {
    try {
      List<Map<String, dynamic>> messages = await widget.chatPDFService.getChatMessagesFromFirestore(widget.pdfUrl, widget.doctorId);
      setState(() {
        if (messages.isEmpty) {
          _messages.add({'sender': 'AI', 'content': 'Welcome! Start your conversation with the AI.', 'timestamp': DateTime.now()});
        } else {
          _messages = messages;
        }
      });
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 28, 88),
      appBar: AppBar(
        title: const Text(
          'Chat with AI',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 9, 26),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 49, 28, 88),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false, // Legújabb üzenetek lent
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
      ),
    );
  }
}
