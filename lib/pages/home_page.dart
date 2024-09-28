// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:messenger_app/components/chat.dart';
import 'package:messenger_app/pages/chat_page.dart';
import 'package:messenger_app/services/auth.dart';
import 'package:messenger_app/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Initialize unfiltered chats
  List<Chat> chats = [];
  // Error message
  String errorMessage = "";
  // Chat collection service
  ChatsCollection chatsCollection = ChatsCollection();
  // User collection service
  UsersCollection usersCollection = UsersCollection();
  // Auth object
  Auth auth = Auth();
  // Current user email
  String currentUserEmail = "";

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    String userName = auth.currentUser!.email ?? "";
    int index = userName.indexOf("@");
    userName = userName.substring(0, index);
    currentUserEmail = userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text(
          currentUserEmail,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut();
            },
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: chatsCollection.getChatCollectionSnapshit(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Initialize chats as document snapshots
            List<DocumentSnapshot> documentSnapshots = snapshot.data!.docs;
            // Initialize chats as Maps
            List<Map<String, dynamic>> mapChats = [];
            // Populate MapChats
            initializeMapChats(documentSnapshots, mapChats);
            // Initialize unfiltered chats
            List<Chat> unfilteredChats = [];
            // Empty the chat list
            chats = [];
            // Populate unfiltered chats
            populateUnfilteredChats(mapChats, unfilteredChats);
            // Populate chats
            populateChats(unfilteredChats);
            // Future builder to get the latest messages
            return FutureBuilder(
              future: () async {
                for (var i = 0; i < chats.length; i++) {
                  chats[i].lastMessage = await chatsCollection
                      .lastMessageByChatID(chatID: chats[i].ID);
                }
              }(),
              builder: (context, snapshot) {
                // Display chats
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    var chat = chats[index];
                    return chatTile(
                      chatName: chat.chatName,
                      ID: chat.ID,
                      currentUser: currentUserEmail,
                      lastMessage: chat.lastMessage,
                    );
                  },
                );
              },
            );
          }
          return Center(child: Text("No chats available"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return DialogcreateChat(
                errorMessage: errorMessage,
                currentUserEmail: currentUserEmail,
                usersCollection: usersCollection,
                chatsCollection: chatsCollection,
                chats: chats,
              );
            },
          );
        },
        backgroundColor: Colors.indigoAccent,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Create a new chat',
      ),
    );
  }

  // Populates chats that contain the current user email
  void populateChats(List<Chat> unfilteredChats) {
    for (var chat in unfilteredChats) {
      if (chat.chatID.contains(currentUserEmail)) {
        chats.add(chat);
      }
    }
  }

  // Converts mapChats into unfilteredChat objects
  void populateUnfilteredChats(
      List<Map<String, dynamic>> mapChats, List<Chat> unfilteredChats) {
    for (var mapChat in mapChats) {
      unfilteredChats.add(
        Chat(
          chatName: mapChat["chatName"],
          ID: mapChat["ID"],
          chatID: mapChat["chatID"],
        ),
      );
    }
  }

  // Converts document snapshots into MapChats
  void initializeMapChats(List<DocumentSnapshot<Object?>> documentSnapshots,
      List<Map<String, dynamic>> mapChats) {
    for (var doc in documentSnapshots) {
      mapChats.add({
        "ID": doc.id,
        "chatName": doc.get("chatName"),
        "chatID": doc.get("chatID"),
      });
    }
  }

  // The chat tile that displays chat info and navigates to the chat page
  Widget chatTile({
    required String chatName,
    required String ID,
    required String currentUser,
    required DocumentSnapshot? lastMessage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              ID: ID,
              senderEmail: currentUser,
              refreshParentPage: refresh,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigoAccent,
            child: Icon(Icons.chat, color: Colors.white),
          ),
          title: Text(
            chatName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: lastMessage != null
              ? lastMessage.get("read").contains(currentUserEmail)
              ? Text(
            lastMessage.get("content"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
              : Text(
            lastMessage.get("content"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
              : Text("No messages yet"),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class DialogcreateChat extends StatefulWidget {
  DialogcreateChat({
    super.key,
    required this.errorMessage,
    required this.currentUserEmail,
    required this.usersCollection,
    required this.chatsCollection,
    required this.chats,
  });

  String errorMessage;
  String currentUserEmail;
  UsersCollection usersCollection;
  ChatsCollection chatsCollection;
  List<Chat> chats;

  @override
  State<DialogcreateChat> createState() => _DialogcreateChatState();
}

class _DialogcreateChatState extends State<DialogcreateChat> {
  // List of requested user emails
  List<String> requestedUserEmails = [];
  // Chat name controller
  TextEditingController chatNameController = TextEditingController();
  // Requested user controller
  TextEditingController requestedUserEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chatNameController,
              decoration: InputDecoration(
                labelText: "Chat Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: requestedUserEmailController,
              decoration: InputDecoration(
                labelText: "Add User",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    // Clear error text
                    setState(() {
                      widget.errorMessage = "";
                    });
                    // Get requested user email
                    String enteredEmail = requestedUserEmailController.text;
                    // Check if email is valid
                    bool isEmailInUsersCollection = await widget
                        .usersCollection
                        .isEmailInUsersCollection(email: enteredEmail);
                    if (isEmailInUsersCollection) {
                      if (!requestedUserEmails.contains(enteredEmail)) {
                        if (enteredEmail == widget.currentUserEmail) {
                          setState(() {
                            widget.errorMessage = "You cannot add yourself";
                          });
                        } else {
                          requestedUserEmails.add(enteredEmail);
                          setState(() {
                            widget.errorMessage = "Added!";
                          });
                        }
                      } else {
                        setState(() {
                          widget.errorMessage = "User is already added";
                        });
                      }
                    } else {
                      setState(() {
                        widget.errorMessage = "Invalid email";
                      });
                    }
                    requestedUserEmailController.clear();
                  },
                  child: Text("Add User"),
                ),
                TextButton(
                  onPressed: requestedUserEmails.isNotEmpty
                      ? () {
                    requestedUserEmails.add(widget.currentUserEmail);
                    String chatID = generatechatID(
                        requestedUsersEmails: requestedUserEmails);
                    if (!ischatIDalreadyInAvailableChats(
                        chatID: chatID, chats: widget.chats)) {
                      widget.chatsCollection.createChat(
                        chatName: chatNameController.text,
                        chatID: chatID,
                      );
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        widget.errorMessage =
                        "You already have this chat";
                      });
                    }
                  }
                      : null,
                  child: Text("Create Chat"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool ischatIDalreadyInAvailableChats(
      {required String chatID, required List<Chat> chats}) {
    return chats.any((chat) => chat.chatID == chatID);
  }

  String generatechatID({required List<String> requestedUsersEmails}) {
    requestedUsersEmails.sort();
    return requestedUsersEmails.join("");
  }
}