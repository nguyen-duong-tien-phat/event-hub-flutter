class BookingTicket {
  final String ticketId;
  final int quantity;

  const BookingTicket({required this.ticketId, required this.quantity});
  Map<String, dynamic> toJson() {
    return {'ticketId': ticketId, 'quantity': quantity};
  }
}
