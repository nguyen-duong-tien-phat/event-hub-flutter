import 'package:event_hub_mobile/features/events/data/models/event.dart';
import 'package:event_hub_mobile/features/events/data/repositories/event_repository.dart';
import 'package:flutter/material.dart';

class EventListProvider extends ChangeNotifier {
  final EventRepository _eventRepository;

  EventListProvider({required this._eventRepository});
  
  bool _loading = false;
  String? _error;
  List<Event> _events = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Event> get events => _events;


  Future<void> fetchEvents({int page = 1, int size = 10,Map<String,dynamic>? filter})  async{
    try {
      _loading = true;
      _events = await _eventRepository.getEvents(page: page, size: size);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
    }
  }
}