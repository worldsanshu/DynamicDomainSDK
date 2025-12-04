// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../core/controller/im_controller.dart';
import '../../core/im_callback.dart';

class ChatAnalyticsLogic extends GetxController {
  final imLogic = Get.find<IMController>();

  // Loading states
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  // Statistics data
  final totalMessagesSent = 0.obs;
  final totalMessagesReceived = 0.obs;
  final totalConversations = 0.obs;
  final totalFriends = 0.obs;
  final totalGroups = 0.obs;

  // Activity data for charts
  final weeklyActivity = <String, int>{}.obs;
  final messageTypeStats = <String, int>{}.obs;
  final topContacts = <ContactStats>[].obs;
  final topGroups = <GroupStats>[].obs;

  // Recent activity
  final recentMessages = <Message>[].obs;
  final onlineStatus = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
    _setupRealtimeUpdates();
  }

  /// Load all analytics data - OPTIMIZED VERSION
  Future<void> loadAnalyticsData() async {
    try {
      isLoading.value = true;

      // ✅ OPTIMIZATION: Load conversations ONCE instead of 6 times
      final conversations =
          await OpenIM.iMManager.conversationManager.getAllConversationList();

      // ✅ OPTIMIZATION: Load messages for all conversations in parallel
      final conversationMessages = await _loadAllMessages(conversations);

      // ✅ OPTIMIZATION: Process all stats from cached data
      await Future.wait([
        _loadBasicStats(conversations, conversationMessages),
        _loadWeeklyActivity(conversations, conversationMessages),
        _loadMessageTypeStats(conversations, conversationMessages),
        _loadTopContacts(conversations, conversationMessages),
        _loadTopGroups(conversations, conversationMessages),
        _loadRecentMessages(conversations, conversationMessages),
      ]);
    } catch (e) {
      Logger.print('Error loading analytics data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load messages for all conversations in parallel - OPTIMIZED
  Future<Map<String, List<Message>>> _loadAllMessages(
      List<ConversationInfo> conversations) async {
    final conversationMessages = <String, List<Message>>{};

    // ✅ Load messages in parallel with limit to avoid overwhelming the API
    final futures = <Future<void>>[];

    for (var conv in conversations.take(20)) {
      // Limit to top 20 conversations
      futures.add(
        OpenIM.iMManager.messageManager
            .getAdvancedHistoryMessageList(
          conversationID: conv.conversationID,
          count: 100, // Get reasonable amount per conversation
        )
            .then((result) {
          conversationMessages[conv.conversationID] = result.messageList ?? [];
        }).catchError((e) {
          Logger.print('Error loading messages for ${conv.conversationID}: $e');
          conversationMessages[conv.conversationID] = [];
        }),
      );
    }

    await Future.wait(futures);
    return conversationMessages;
  }

  /// Refresh data
  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadAnalyticsData();
    isRefreshing.value = false;
  }

  /// Load basic statistics - OPTIMIZED
  Future<void> _loadBasicStats(List<ConversationInfo> conversations,
      Map<String, List<Message>> conversationMessages) async {
    try {
      totalConversations.value = conversations.length;

      // Count friends and groups
      int friendCount = 0;
      int groupCount = 0;

      for (var conv in conversations) {
        if (conv.conversationType == ConversationType.single) {
          friendCount++;
        } else if (conv.conversationType == ConversationType.group ||
            conv.conversationType == ConversationType.superGroup) {
          groupCount++;
        }
      }

      totalFriends.value = friendCount;
      totalGroups.value = groupCount;

      // ✅ OPTIMIZATION: Count messages from cached data
      int sentCount = 0;
      int receivedCount = 0;

      conversationMessages.forEach((convId, messages) {
        for (var msg in messages) {
          if (msg.sendID == OpenIM.iMManager.userID) {
            sentCount++;
          } else {
            receivedCount++;
          }
        }
      });

      totalMessagesSent.value = sentCount;
      totalMessagesReceived.value = receivedCount;
    } catch (e) {
      Logger.print('Error loading basic stats: $e');
    }
  }

  /// Load weekly activity data - OPTIMIZED
  Future<void> _loadWeeklyActivity(List<ConversationInfo> conversations,
      Map<String, List<Message>> conversationMessages) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // Initialize week data
      final activityData = <String, int>{};
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.day}/${date.month}';
        activityData[dateKey] = 0;
      }

      // ✅ OPTIMIZATION: Count messages from cached data
      conversationMessages.forEach((convId, messages) {
        for (var msg in messages) {
          if (msg.sendTime != null &&
              msg.sendTime! > weekAgo.millisecondsSinceEpoch) {
            final msgDate = DateTime.fromMillisecondsSinceEpoch(msg.sendTime!);
            final dateKey = '${msgDate.day}/${msgDate.month}';
            if (activityData.containsKey(dateKey)) {
              activityData[dateKey] = activityData[dateKey]! + 1;
            }
          }
        }
      });

      weeklyActivity.value = activityData;
    } catch (e) {
      Logger.print('Error loading weekly activity: $e');
    }
  }

  /// Load message type statistics - OPTIMIZED
  Future<void> _loadMessageTypeStats(List<ConversationInfo> conversations,
      Map<String, List<Message>> conversationMessages) async {
    try {
      final typeStats = <String, int>{
        'Text': 0,
        'Image': 0,
        'Voice': 0,
        'Video': 0,
        'File': 0,
        'Custom': 0,
      };

      // ✅ OPTIMIZATION: Count message types from cached data
      conversationMessages.forEach((convId, messages) {
        for (var msg in messages) {
          switch (msg.contentType) {
            case MessageType.text:
            case MessageType.atText:
            case MessageType.quote:
              typeStats['Text'] = typeStats['Text']! + 1;
              break;
            case MessageType.picture:
              typeStats['Image'] = typeStats['Image']! + 1;
              break;
            case MessageType.voice:
              typeStats['Voice'] = typeStats['Voice']! + 1;
              break;
            case MessageType.video:
              typeStats['Video'] = typeStats['Video']! + 1;
              break;
            case MessageType.file:
              typeStats['File'] = typeStats['File']! + 1;
              break;
            default:
              typeStats['Custom'] = typeStats['Custom']! + 1;
              break;
          }
        }
      });

      messageTypeStats.value = typeStats;
    } catch (e) {
      Logger.print('Error loading message type stats: $e');
    }
  }

  /// Load top contacts - OPTIMIZED
  Future<void> _loadTopContacts(List<ConversationInfo> conversations,
      Map<String, List<Message>> conversationMessages) async {
    try {
      final contactStats = <String, int>{};
      final contactInfo = <String, ConversationInfo>{};

      final singleChats = conversations
          .where((c) => c.conversationType == ConversationType.single)
          .toList();

      // ✅ OPTIMIZATION: Count messages from cached data
      for (var conv in singleChats) {
        final messages = conversationMessages[conv.conversationID] ?? [];
        if (messages.isNotEmpty) {
          contactStats[conv.userID ?? ''] = messages.length;
          contactInfo[conv.userID ?? ''] = conv;
        }
      }

      // Sort and get top 5
      final sortedContacts = contactStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topContactsList = <ContactStats>[];
      for (var entry in sortedContacts.take(5)) {
        final conv = contactInfo[entry.key];
        if (conv != null) {
          topContactsList.add(ContactStats(
            userId: entry.key,
            name: conv.showName ?? 'Unknown',
            messageCount: entry.value,
            avatar: conv.faceURL,
          ));
        }
      }

      topContacts.value = topContactsList;
    } catch (e) {
      Logger.print('Error loading top contacts: $e');
    }
  }

  /// Load top groups - OPTIMIZED
  Future<void> _loadTopGroups(List<ConversationInfo> conversations,
      Map<String, List<Message>> conversationMessages) async {
    try {
      final groupStats = <String, int>{};
      final groupInfo = <String, ConversationInfo>{};

      final groupChats = conversations
          .where((c) =>
              c.conversationType == ConversationType.group ||
              c.conversationType == ConversationType.superGroup)
          .toList();

      // ✅ OPTIMIZATION: Count messages from cached data
      for (var conv in groupChats) {
        final messages = conversationMessages[conv.conversationID] ?? [];
        if (messages.isNotEmpty) {
          groupStats[conv.groupID ?? ''] = messages.length;
          groupInfo[conv.groupID ?? ''] = conv;
        }
      }

      // Sort and get top 5
      final sortedGroups = groupStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topGroupsList = <GroupStats>[];
      for (var entry in sortedGroups.take(5)) {
        final conv = groupInfo[entry.key];
        if (conv != null) {
          topGroupsList.add(GroupStats(
            groupId: entry.key,
            name: conv.showName ?? 'Unknown Group',
            messageCount: entry.value,
            avatar: conv.faceURL,
            memberCount: 0, // Could be enhanced to get actual member count
          ));
        }
      }

      topGroups.value = topGroupsList;
    } catch (e) {
      Logger.print('Error loading top groups: $e');
    }
  }

  /// Load recent messages - OPTIMIZED
  Future<void> _loadRecentMessages(List<ConversationInfo> conversations,
      Map<String, List<Message>> conversationMessages) async {
    try {
      final allMessages = <Message>[];

      // ✅ OPTIMIZATION: Get messages from cached data
      conversationMessages.forEach((convId, messages) {
        allMessages.addAll(messages);
      });

      // Sort by time and take latest 10
      allMessages.sort((a, b) => (b.sendTime ?? 0).compareTo(a.sendTime ?? 0));
      recentMessages.value = allMessages.take(10).toList();
    } catch (e) {
      Logger.print('Error loading recent messages: $e');
    }
  }

  /// Setup realtime updates
  void _setupRealtimeUpdates() {
    // Listen to new messages
    imLogic.imSdkStatusSubject.listen((status) {
      onlineStatus.value = status.status == IMSdkStatus.connectionSucceeded;
    });

    // Refresh data every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!isLoading.value) {
        loadAnalyticsData();
      }
    });
  }

  /// Get formatted statistics
  String get totalMessages =>
      (totalMessagesSent.value + totalMessagesReceived.value).toString();
  String get messagesPerDay => (totalMessages.isNotEmpty
      ? (int.parse(totalMessages) / 7).toStringAsFixed(1)
      : '0');

  double get messageRatio => totalMessages.isNotEmpty
      ? totalMessagesSent.value /
          (totalMessagesSent.value + totalMessagesReceived.value)
      : 0.5;
}

/// Data models for statistics
class ContactStats {
  final String userId;
  final String name;
  final int messageCount;
  final String? avatar;

  ContactStats({
    required this.userId,
    required this.name,
    required this.messageCount,
    this.avatar,
  });
}

class GroupStats {
  final String groupId;
  final String name;
  final int messageCount;
  final String? avatar;
  final int memberCount;

  GroupStats({
    required this.groupId,
    required this.name,
    required this.messageCount,
    this.avatar,
    required this.memberCount,
  });
}
