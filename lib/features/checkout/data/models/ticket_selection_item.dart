import '../../../tickets/data/models/ticket.dart';

class TicketSelectionItem {
  final Ticket ticket;
  final int quantity;

  const TicketSelectionItem({required this.ticket, required this.quantity});

  double get subtotal => ticket.price * quantity;
}
