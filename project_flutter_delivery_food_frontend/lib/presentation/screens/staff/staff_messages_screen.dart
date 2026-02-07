import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/user_provider.dart';

class StaffMessagesScreen extends StatefulWidget {
  const StaffMessagesScreen({super.key});

  @override
  State<StaffMessagesScreen> createState() => _StaffMessagesScreenState();
}

class _StaffMessagesScreenState extends State<StaffMessagesScreen> {
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    Future.microtask(() {
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      final staffProvider = context.read<StaffProvider>();

      if (userProvider.restaurantId != null) {
        staffProvider.fetchMessages(
          userProvider.restaurantId!,
          userId: userProvider.userId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProv = context.watch<StaffProvider>();
    final userProv = context.watch<UserProvider>();
    final isDelivery = userProv.isDelivery;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDelivery ? Colors.blue[800] : Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: staffProv.isLoadingMessages
          ? const Center(child: CircularProgressIndicator())
          : staffProv.messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: staffProv.messages.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final message = staffProv.messages[index];
                return _buildMessageCard(message, userProv);
              },
            ),
    );
  }

  Widget _buildMessageCard(dynamic message, UserProvider userProv) {
    final sender = message['senderId'];
    final senderName = sender != null
        ? sender['username'] ?? 'Unknown'
        : 'Unknown';
    final senderEmail = sender != null ? sender['email'] ?? '' : '';
    final content = message['content'] ?? '';
    final type = message['type'] ?? 'general';
    final createdAt = message['createdAt'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.person, color: Colors.orange[800]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (senderEmail.isNotEmpty)
                        Text(
                          senderEmail,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: type == 'reply'
                        ? Colors.blue[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type == 'reply' ? 'Reply' : 'Message',
                    style: TextStyle(
                      fontSize: 11,
                      color: type == 'reply'
                          ? Colors.blue[800]
                          : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              _formatDate(createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            if (type != 'reply')
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Reply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showReplyDialog(message, userProv),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _showReplyDialog(dynamic message, UserProvider userProv) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Message'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Type your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (replyController.text.trim().isEmpty) return;

              final success = await context
                  .read<StaffProvider>()
                  .replyToMessage(
                    restaurantId: userProv.restaurantId!,
                    receiverId: message['senderId']['_id'],
                    content: replyController.text.trim(),
                    orderId: message['orderId']?['_id'],
                    userId: userProv.userId,
                  );

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply sent successfully')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
