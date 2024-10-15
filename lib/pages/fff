// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:messenger_app/components/message.dart';
import 'package:messenger_app/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  ChatPage({
    super.key,
    required this.ID,
    required this.senderEmail,
    required this.refreshParentPage,
  });
  //the ID you will get from HomePage
  late String ID;
  //the User email you will get from HomePage
  late String senderEmail;
  //refresh parent page
  late Function refreshParentPage;

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  //initialize chatsCollection services
  ChatsCollection chatsCollection = ChatsCollection();
  //controller for scrolling
  ScrollController _scrollController = ScrollController();
  //controller for message input
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.senderEmail}"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: chatsCollection.readMessages(chatID: widget.ID),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //initialize documents list
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    //initialize mapMessages list
                    List<Map<String, dynamic>> mapMessages = [];
                    //initialize messages
                    List<Message> messages = [];
                    //populate mapMessages
                    populateMapMessages(documents, mapMessages);
                    //populate messages
                    populateMessages(mapMessages, messages);
                    //mark messages as read
                    markMessagesRead(messages);
                    //refresh parent page
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.refreshParentPage();
                    });

                    // Automatically scroll to the bottom when new messages are added
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController, // Use the scroll controller
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return messageTile(
                          content: messages[index].content,
                          sender: messages[index].senderEmail,
                          read: messages[index].read,
                        );
                      },
                    );
                  }
                  return Center(child: Text("No messages yet."));
                },
              ),
            ),
            // Message input and send button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.indigoAccent),
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        // Make message object to send
                        Message message = Message(
                          content: messageController.text,
                          senderEmail: widget.senderEmail,
                          read: [widget.senderEmail],
                        );
                        // Send message
                        chatsCollection.sendMessage(
                          chatID: widget.ID,
                          content: message.content,
                          sender: message.senderEmail,
                          read: message.read,
                        );
                        // Update timestamp
                        chatsCollection.updateTimeStamp(chatID: widget.ID);
                        // Clear field
                        messageController.clear();
                        // Scroll to bottom
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void markMessagesRead(List<Message> messages) {
    for (var i = 0; i < messages.length; i++) {
      if (!messages[i].read.contains(widget.senderEmail)) {
        messages[i].read.add(widget.senderEmail);
        chatsCollection.updateMessageReadStatus(
          chatID: widget.ID,
          messageID: messages[i].ID,
          readBy: messages[i].read,
        );
      }
    }
  }

  void populateMessages(
      List<Map<String, dynamic>> mapMessages,
      List<Message> messages,
      ) {
    for (var i = 0; i < mapMessages.length; i++) {
      messages.add(Message(
        ID: mapMessages[i]["ID"],
        content: mapMessages[i]["content"],
        senderEmail: mapMessages[i]["sender"],
        timeStamp: mapMessages[i]["timeStamp"].toDate(),
        read: List<String>.from(mapMessages[i]["read"]), // Casting to List<String>
      ));
    }
  }

  void populateMapMessages(
      List<DocumentSnapshot<Object?>> documents,
      List<Map<String, dynamic>> mapMessages,
      ) {
    for (var i = 0; i < documents.length; i++) {
      mapMessages.add({
        "ID": documents[i].id,
        "content": documents[i].get("content"),
        "sender": documents[i].get("sender"),
        "timeStamp": documents[i].get("timeStamp"),
        "read": documents[i].get("read"),
      });
    }
  }

  Widget messageTile({
    required String content,
    required String sender,
    required List<String> read,
  }) {
    bool isOwnMessage = sender == widget.senderEmail;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.indigoAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),

        ),
        child: Column(
          crossAxisAlignment:
          isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}