import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../providers/app_state.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

class ChatScreen extends StatefulWidget {
  final String requestId;

  const ChatScreen({super.key, required this.requestId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(AppState appState) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      await appState.sendMessage(widget.requestId, content);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Eroare: ${e.toString()}')));
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final request = appState.getRequestById(widget.requestId);
        final messages = appState.getMessages(widget.requestId);
        final currentUser = appState.currentUser;

        if (request == null || currentUser == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Nu merge chat-ul')),
          );
        }

        final otherUserId = currentUser.id == request.requesterId
            ? request.volunteerId
            : request.requesterId;
        final otherUser =
            otherUserId != null ? appState.getUserById(otherUserId) : null;
        final otherUserName = currentUser.id == request.requesterId
            ? request.volunteerName ?? 'Voluntar'
            : request.requesterName;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    otherUserName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              otherUserName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (otherUser?.isVerified == true) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: AppTheme.secondaryColor,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            request.categoryLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (otherUser != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              otherUser.lastActiveLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppTheme.secondaryColor,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppTheme.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Niciun mesaj încă',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scrie primul mesaj',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          if (message.isSystemMessage) {
                            return _SystemMessageBubble(message: message);
                          }

                          final isMe = message.senderId == currentUser.id;
                          return _MessageBubble(message: message, isMe: isMe);
                        },
                      ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.dividerColor)),
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Scrie un mesaj...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(appState),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => _sendMessage(appState),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                  border:
                      isMe ? null : Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: isMe ? Colors.white : AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final Message message;

  const _SystemMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
