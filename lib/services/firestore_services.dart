import 'package:cloud_firestore/cloud_firestore.dart';

class UsersCollection {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  //checks if email checks with users in usersCollection
  Future<bool> isEmailInUsersCollection({required email}) async {
    QuerySnapshot querySnapshot =
    await usersCollection.where("email", isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty ? true : false;
  }

  // Adds user information to Firestore
  Future<void> addUserInfo({
    required String userId,
    required String userEmail,
    required String userName,
    String profilePicture = 'assets/avatar.jpg', // Default profile picture
  }) async {
    try {
      await usersCollection.doc(userId).set({
        "email": userEmail,
        "username": userName, // Username provided by the user
        "profile_picture": profilePicture, // Default or provided profile picture
      });
    } catch (e) {
      print("Error adding user info: $e");
    }
  }

}

class ChatsCollection {
  CollectionReference chatsCollection =
  FirebaseFirestore.instance.collection("ChatsCollection");

  // Create a chat collection
  Future<void> createChat({required String chatName, required String chatID}) async {
    try {
      await chatsCollection.add({
        "chatName": chatName,
        "chatID": chatID,
        "timeStamp": Timestamp.now(),
      });
    } catch (e) {
      print("Error creating chat: $e");
    }
  }

  // Read chat collection
  Stream<QuerySnapshot> getChatCollectionSnapshot() {
    return chatsCollection.orderBy("timeStamp", descending: true).snapshots();
  }

  // Method to get the username by email
  Future<String> getUsernameByEmail(String email) async {
  try {
  DocumentSnapshot snapshot = await chatsCollection.doc(email).get(); // Assuming email is the document ID
  if (snapshot.exists) {
  return snapshot.get('username') ?? 'Unknown'; // Default to 'Unknown' if username is not set
  } else {
  return 'Unknown'; // Fallback if no document found
  }
  } catch (e) {
  print("Error fetching username: $e");
  return 'Unknown'; // Handle any errors
  }
  }


  // Send a message
  Future<void> sendMessage({
    required String chatID,
    required String content,
    required String sender,
    required List<String> read,
    required String username,
    required String profilePictureUrl,
  }) async {
    try {
      await chatsCollection.doc(chatID).collection("messages").add({
        'content': content,
        'sender': sender,
        'read': read,
        'username': username,
        'profilePictureUrl': profilePictureUrl,
        'timeStamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Read messages
  Stream<QuerySnapshot> readMessages({required String chatID}) {
    return chatsCollection
        .doc(chatID)
        .collection("messages")
        .orderBy("timeStamp")
        .snapshots();
  }

  // Update the timestamp of a chat
  Future<void> updateTimeStamp({required String chatID}) async {
    try {
      await chatsCollection.doc(chatID).update({"timeStamp": Timestamp.now()});
    } catch (e) {
      print("Error updating timestamp: $e");
    }
  }

  // Update read status of a message
  Future<void> updateMessageReadStatus({
    required String chatID,
    required String? messageID,
    required List<String> readBy,
  }) async {
    try {
      await chatsCollection
          .doc(chatID)
          .collection("messages")
          .doc(messageID)
          .update({"read": readBy});
    } catch (e) {
      print("Error updating message read status: $e");
    }
  }

  // Get the last message by chatID
  Future<DocumentSnapshot?> lastMessageByChatID({required String chatID}) async {
    try {
      QuerySnapshot querySnapshot = await chatsCollection
          .doc(chatID)
          .collection("messages")
          .orderBy("timeStamp", descending: true)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.last;
      }
    } catch (e) {
      print("Error fetching last message: $e");
    }
    return null;
  }
}
