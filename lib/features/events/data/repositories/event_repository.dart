import 'package:event_hub_mobile/core/network/api_client.dart';
import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:flutter/material.dart';

class EventRepository {
  final ApiClient _apiClient;

  EventRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Event>> getEvents({int page = 1, int size = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        '/events',
        queryParameters: {'page': page, 'pageSize': size},
      );

      final items = response.data['items'] as List<dynamic>;

      return items
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch events: $e');
      rethrow; // Important: don't hide the error
    }
  }
}
