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
        title: Text(widget.senderEmail),
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
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    List<Map<String, dynamic>> mapMessages = [];
                    List<Message> messages = [];

                    // Populate mapMessages and messages
                    populateMapMessages(documents, mapMessages);
                    populateMessages(mapMessages, messages);

                    // Mark messages as read
                    markMessagesRead(messages);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.refreshParentPage();
                    });

                    // Auto scroll to the bottom after building
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return messageTile(
                          content: messages[index].content,
                          sender: messages[index].senderEmail,
                          read: messages[index].read,
                          username: messages[index].username,

                          profilePictureUrl: messages[index]
                              .profilePictureUrl,
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
                  // In the onPressed function of the IconButton
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.indigoAccent),
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {
                        // Fetch username from Firestore based on senderEmail
                        String username = await chatsCollection.getUsernameByEmail(widget.senderEmail);

                        // Create message object to send
                        Message message = Message(
                          content: messageController.text,
                          senderEmail: widget.senderEmail,
                          read: [widget.senderEmail],
                          username: username, // Use the fetched username here
                          profilePictureUrl: 'assets/avatar.png', // Use a default if no user profile picture is set
                        );

                        // Send message to Firestore
                        chatsCollection.sendMessage(
                          chatID: widget.ID,
                          content: message.content,
                          sender: message.senderEmail,
                          read: message.read,
                          username: message.username,
                          profilePictureUrl: message.profilePictureUrl ?? 'assets/avatar.png', // Provide the asset path as the default value
                        );

                        // Update timestamp
                        chatsCollection.updateTimeStamp(chatID: widget.ID);

                        // Clear input field
                        messageController.clear();

                        // Scroll to the bottom
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

  void populateMessages(List<Map<String, dynamic>> mapMessages,
      List<Message> messages,) {
    for (var i = 0; i < mapMessages.length; i++) {
      messages.add(Message(
        ID: mapMessages[i]["ID"],
        content: mapMessages[i]["content"],
        senderEmail: mapMessages[i]["sender"],
        timeStamp: mapMessages[i]["timeStamp"]?.toDate(),
        // Handle possible null timestamp
        read: List<String>.from(mapMessages[i]["read"] ?? []),
        // Safe cast to List<String>
        username: mapMessages[i]["username"],
        // Handle null username
        profilePictureUrl: mapMessages[i]["profilePictureUrl"] ??
            '', // Handle null profile picture URL
      ));
    }
  }

  void populateMapMessages(List<DocumentSnapshot<Object?>> documents,
      List<Map<String, dynamic>> mapMessages,) {
    for (var i = 0; i < documents.length; i++) {
      mapMessages.add({
        "ID": documents[i].id,
        "content": documents[i].get("content"),
        "sender": documents[i].get("sender"),
        "timeStamp": documents[i].get("timeStamp"),
        "read": documents[i].get("read") ?? [],
        // Ensure 'read' is not null
        "username": documents[i].get("username") ?? 'Unknown',
        // Handle missing username
        "profilePictureUrl": documents[i].get("profilePictureUrl") ?? '',
        // Handle missing profile picture URL
      });
    }
  }

  Widget messageTile({
    required String content,
    required String sender,
    required List<String> read,
    required String username,
    String? profilePictureUrl,
    DateTime? timeStamp,
  }) {
    bool isOwnMessage = sender == widget.senderEmail;

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Limit max width to 75% of the screen width
        ),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.indigoAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Only take up as much space as necessary
          mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isOwnMessage)
              CircleAvatar(
                backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : AssetImage('assets/avatar.jpg') as ImageProvider,
                radius: 20, // Adjust size as needed
              ),
            const SizedBox(width: 8),
            Flexible( // Use Flexible to wrap text and prevent overflow
              child: Column(
                crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOwnMessage ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content,
                    style: TextStyle(
                      color: isOwnMessage ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (timeStamp != null)
                    Text(
                      formatTimestamp(timeStamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOwnMessage ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


// Helper function to format the timestamp nicely
  String formatTimestamp(DateTime timeStamp) {
    // You can adjust this based on your preference
    return "${timeStamp.hour.toString().padLeft(2, '0')}:${timeStamp.minute
        .toString().padLeft(2, '0')} - ${timeStamp.day}/${timeStamp
        .month}/${timeStamp.year}";
  }

}