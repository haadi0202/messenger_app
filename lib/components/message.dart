class Message {
  String? ID;
  String content;
  String senderEmail;
  DateTime? timeStamp;
  List<String> read;
  String username;
  String? profilePictureUrl; // Can be null if user hasn't uploaded a PFP

  Message({
    this.ID,
    required this.content,
    required this.senderEmail,
    this.timeStamp,
    required this.read,
    required this.username,
    this.profilePictureUrl, // Optional
  });
}
