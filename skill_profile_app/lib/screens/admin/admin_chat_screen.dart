import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_chat_detail_screen.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  List<dynamic> _chats = [];
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadChats());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadChats() async {
    try {
      final result = await ApiService.get('/admin/chats');
      final chats = result['chats'] ?? result['data'] ?? [];
      if (mounted) {
        setState(() => _chats = chats is List ? chats : []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat dengan User'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? const Center(child: Text('Belum ada chat'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    final user = chat['user'] ?? {};
                    final lastMsg = chat['last_message'] ?? chat['lastMessage'];
                    final unread = chat['unread_count'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            (user['name'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                        title: Text(user['name'] ?? 'User'),
                        subtitle: Text(
                          lastMsg?['message'] ?? 'Belum ada pesan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: unread > 0
                            ? CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Text(
                                  '$unread',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminChatDetailScreen(
                                chatId: chat['id'],
                                userName: user['name'] ?? 'User',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
