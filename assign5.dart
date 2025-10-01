
import 'dart:async';

Future<bool> checkSeatAvailability(int requestedSeats) async 
{
  
  await Future.delayed(const Duration(seconds: 2));
  
  const seatsLeft = 3;
  return requestedSeats <= seatsLeft;
}

Future<String> bookTickets(int requestedSeats) async 
{
  final available = await checkSeatAvailability(requestedSeats);
  if (!available) return 'Booking Failed: No seats';
  
  await Future.delayed(const Duration(seconds: 1));
  return 'Booking Confirmed';
}

void main() async 
{
  print('Railway Booking');
  try {
    
    final result = await bookTickets(2).timeout(const Duration(seconds: 5));
    print(result);
  } on TimeoutException {
    print('Booking Failed: Timeout');
  } catch (e) {
    print('Booking Failed: $e');
  }

  
  try {
    final result = await bookTickets(5).timeout(const Duration(seconds: 5));
    print(result);
  } on TimeoutException {
    print('Booking Failed: Timeout');
  } catch (e) {
    print('Booking Failed: $e');
  }
  print('');
}
