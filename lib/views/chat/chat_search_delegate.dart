import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/message_model.dart';
import '../../l10n/app_localizations.dart';

/// SearchDelegate للبحث في رسائل المحادثة الحالية فقط (in-memory)
class ChatSearchDelegate extends SearchDelegate<MessageModel?> {
  final List<MessageModel> messages;

  ChatSearchDelegate({required this.messages});

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (query.isEmpty) {
      return Center(
        child: Text(
          l10n.searchPlaceholder,
          style: const TextStyle(color: AppColors.lightTextSecondary),
        ),
      );
    }

    final q = query.toLowerCase();
    final results = messages
        .where((m) =>
            !m.isDeleted &&
            m.type == MessageType.text &&
            m.content.toLowerCase().contains(q))
        .toList()
        .reversed
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          l10n.noSearchResults,
          style: const TextStyle(color: AppColors.lightTextSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final msg = results[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              msg.type == MessageType.image
                  ? Icons.image_outlined
                  : Icons.message_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          title: _highlight(context, msg.content, query),
          subtitle: Text(
            '${msg.senderName} · ${DateFormatter.formatLastSeen(msg.timestamp, context)}',
            style: const TextStyle(fontSize: 11),
          ),
          onTap: () => close(context, msg),
        );
      },
    );
  }

  Widget _highlight(BuildContext context, String text, String q) {
    final lower = text.toLowerCase();
    final lq = q.toLowerCase();
    final index = lower.indexOf(lq);
    if (index == -1) return Text(text);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 14,
        ),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + q.length),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFB627),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }
}
