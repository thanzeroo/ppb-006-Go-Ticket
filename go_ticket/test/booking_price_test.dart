import 'package:flutter_test/flutter_test.dart';
import 'package:go_ticket/core/models/booking_args.dart';
import 'package:go_ticket/core/models/hotel_model.dart';

void main() {
  group('Hotel booking prices', () {
    test('keeps formatted card price and valid original price', () {
      final args = BookingArgs.fromHotel({
        'name': 'Hotel Test',
        'discountedPrice': 'Rp 250.000',
        'originalPrice': 'Rp 300.000',
      });

      expect(args.roomPrice, 250000);
      expect(args.originalPrice, 300000);
    });

    test('uses a nonzero fallback when card price is missing or zero', () {
      final missingPrice = BookingArgs.fromHotel({'name': 'Hotel Test'});
      final zeroPrice = BookingArgs.fromHotel({
        'name': 'Hotel Test',
        'price': 'Rp 0',
      });
      final zeroPriceArgs = BookingArgs.fromHotel({
        'name': 'Hotel Test',
        'price': 'Rp 250.000',
      }).copyWith(roomPrice: 0);

      expect(missingPrice.roomPrice, greaterThan(0));
      expect(zeroPrice.roomPrice, greaterThan(0));
      expect(BookingArgs.fromHotel(zeroPriceArgs).roomPrice, greaterThan(0));
    });

    test('keeps booking total positive when a promo applies to a low rate', () {
      final oneNightArgs = BookingArgs.fromHotel({
        'name': 'Hotel Test',
        'price': 'Rp 100.000',
      });
      final args = oneNightArgs.copyWith(
        checkOut: oneNightArgs.checkIn.add(const Duration(days: 1)),
      );

      expect(args.total, greaterThan(0));
    });

    test('uses a nonzero starting price for hotels with invalid prices', () {
      const hotel = HotelModel(
        id: 'hotel-test',
        name: 'Hotel Test',
        address: 'Alamat Test',
        city: 'Bali',
        province: 'Bali',
        startingPrice: 0,
      );

      expect(hotel.pricePerNight, greaterThan(0));
      expect(hotel.originalPrice, isNull);
    });
  });
}
