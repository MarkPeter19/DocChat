import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctorgpt/screens/PatientScreens/Messages/ImagePreviewScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/services/chats_services.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'package:path/path.dart' as Path;

class PatientChatScreen extends StatefulWidget {
  final String patientId;
  final String doctorId;

  const PatientChatScreen({
    Key? key,
    required this.patientId,
    required this.doctorId,
  }) : super(key: key);

  @override
  _PatientChatScreenState createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  late final ScrollController _scrollController;
  final ChatServices _chatServices = ChatServices();
  final DoctorServices _doctorServices = DoctorServices();
  final ImagePicker _picker = ImagePicker();
   final _auth = FirebaseAuth.instance;


  Map<String, dynamic>? _doctorData;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadDatas();
    _loadChatMessages();
  }

  void _loadDatas() async {
    try {
      Map<String, dynamic> doctorData =
          await _doctorServices.fetchDoctorData(widget.doctorId);
      setState(() {
        _doctorData = doctorData;
      });
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  void _loadChatMessages() async {
    try {
      List<Map<String, dynamic>> messages = await _chatServices
          .getChatMessagesFromFirestore(widget.patientId, widget.doctorId);
      setState(() {
        _messages = messages;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('Error loading chat messages: $e');
    }
  }

  void _getImageFromCamera() async {
    final pickedFile = await _picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _sendMessage(imageFile);
    }
  }

  void _getImageFromGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _sendMessage(imageFile);
    }
  }

  void _sendMessage(File? imageFile) async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty || imageFile != null) {
      if (imageFile != null) {
        _uploadImageAndSendMessage(imageFile);
      } else {
        Map<String, dynamic> newMessage = {
          'sender': 'Patient',
          'content': message,
          'imageUrl': '', // Üres kép URL, mivel ez egy szöveg üzenet
          'timestamp': DateTime.now()
        };

        setState(() {
          _messages.add(newMessage);
        });

        try {
          await _chatServices.saveChatMessagesToFirestore(
              widget.patientId, widget.doctorId, [newMessage]);
        } catch (e) {
          print('Error sending message: $e');
        }
      }

      _messageController.clear();
    }
  }

  Future<void> _uploadImageAndSendMessage(File imageFile) async {
    String fileName = Path.basename(imageFile.path);
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('chatImages/${_auth.currentUser!.uid}/$fileName');

    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() async {
      String downloadUrl = await storageReference.getDownloadURL();

      Map<String, dynamic> newMessage = {
        'sender': 'Patient',
        'content': '', // Üres tartalom, mivel ez egy kép
        'imageUrl': downloadUrl, // Kép URL hozzáadása
        'timestamp': DateTime.now()
      };

      setState(() {
        _messages.add(newMessage);
      });

      await _chatServices.saveChatMessagesToFirestore(
          widget.patientId, widget.doctorId, [newMessage]);

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }).catchError((error) {
      print('Hiba a kép feltöltése közben: $error');
    });
  }


  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final String sender = message['sender'];
    final String content = message['content'];
    final String? imageUrl = message['imageUrl'];
    final DateTime timestamp = message['timestamp'];
    final bool isPatient = sender == 'Patient';
    final Color bubbleColor = isPatient
        ? const Color.fromARGB(255, 0, 199, 169)
        : const Color.fromARGB(255, 146, 71, 245);

    return Row(
      mainAxisAlignment:
          isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: isPatient ? Alignment.topRight : Alignment.topLeft,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPatient && _doctorData != null)
                    Text(
                      _doctorData!['fullName'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  if (isPatient) const Text('You'),
                  if (imageUrl != null && imageUrl.isNotEmpty) // Ha van kép URL
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreviewScreen(
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(
                                    80.0), // Padding a progress indicator körül
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white), // Fehér színű indikátor
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  if (content.isNotEmpty) // Ha van szöveg tartalom
                    Text(
                      content,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}', // Display hour and minute
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 229, 215, 255),
      appBar: AppBar(
        title: Row(
          children: [
            if (_doctorData != null &&
                _doctorData!['profilePictureURL'] != null)
              CircleAvatar(
                backgroundImage:
                    NetworkImage(_doctorData!['profilePictureURL']),
              )
            else
              const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                child: Icon(Icons.person),
              ),
            const SizedBox(width: 20),
            Text(
              _doctorData != null ? _doctorData!['fullName'] : '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 146, 71, 245),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 245, 245, 245),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 240, 231, 255),
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
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      color: const Color.fromARGB(255, 146, 71, 245),
                      onPressed: _getImageFromCamera,
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      color: const Color.fromARGB(255, 146, 71, 245),
                      onPressed: _getImageFromGallery,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        cursorColor: Colors.white,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 146, 71, 245),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: const Color.fromARGB(255, 146, 71, 245),
                      onPressed: () {
                        _sendMessage(null); // For sending message without image
                      },
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
