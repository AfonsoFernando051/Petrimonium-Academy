import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';

void main() {
  group('DividendEvent.fromJson', () {
    test('parses all fields from a full response', () {
      final event = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'type': 'JCP',
        'rawLabel': 'Juros sobre capital próprio',
        'ratePerShare': 0.5,
        'dataCom': '2026-01-10',
        'paymentDate': '2026-01-20',
        'approvedOn': '2026-01-01',
        'userQuantity': 100.0,
        'estimatedGrossAmount': 50.0,
        'status': 'PAID',
      });

      expect(event.ticker, 'PETR4');
      expect(event.type, DividendType.JCP);
      expect(event.rawLabel, 'Juros sobre capital próprio');
      expect(event.ratePerShare, 0.5);
      expect(event.dataCom, DateTime.parse('2026-01-10'));
      expect(event.paymentDate, DateTime.parse('2026-01-20'));
      expect(event.approvedOn, DateTime.parse('2026-01-01'));
      expect(event.userQuantity, 100.0);
      expect(event.estimatedGrossAmount, 50.0);
      expect(event.status, DividendStatus.PAID);
    });

    test('unrecognized type falls back to OUTRO', () {
      final event = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'type': 'SOMETHING_NEW',
        'userQuantity': 1.0,
        'estimatedGrossAmount': 1.0,
        'status': 'ANNOUNCED',
      });

      expect(event.type, DividendType.OUTRO);
    });

    test('null type falls back to OUTRO', () {
      final event = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'userQuantity': 1.0,
        'estimatedGrossAmount': 1.0,
        'status': 'ANNOUNCED',
      });

      expect(event.type, DividendType.OUTRO);
    });

    test('status defaults to ANNOUNCED for anything other than PAID', () {
      final event = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'type': 'DIVIDENDO',
        'userQuantity': 1.0,
        'estimatedGrossAmount': 1.0,
        'status': 'ANNOUNCED',
      });
      expect(event.status, DividendStatus.ANNOUNCED);

      final missingStatus = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'type': 'DIVIDENDO',
        'userQuantity': 1.0,
        'estimatedGrossAmount': 1.0,
      });
      expect(missingStatus.status, DividendStatus.ANNOUNCED);
    });

    test('null/empty date strings parse to null rather than throwing', () {
      final event = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'type': 'DIVIDENDO',
        'dataCom': '',
        'paymentDate': null,
        'userQuantity': 1.0,
        'estimatedGrossAmount': 1.0,
        'status': 'ANNOUNCED',
      });

      expect(event.dataCom, isNull);
      expect(event.paymentDate, isNull);
      expect(event.approvedOn, isNull);
    });

    test('missing numeric/label fields fall back to safe defaults', () {
      final event = DividendEvent.fromJson(const {'ticker': 'PETR4'});

      expect(event.rawLabel, '');
      expect(event.ratePerShare, 0.0);
      expect(event.userQuantity, 0.0);
      expect(event.estimatedGrossAmount, 0.0);
      expect(event.status, DividendStatus.ANNOUNCED);
    });
  });

  group('DividendRadar', () {
    test('isEmpty is true only when both lists are empty', () {
      expect(DividendRadar.empty.isEmpty, isTrue);
      expect(const DividendRadar(upcoming: [], history: []).isEmpty, isTrue);
    });

    test('nextPayment returns the first upcoming entry, or null when empty', () {
      expect(DividendRadar.empty.nextPayment, isNull);

      final event = DividendEvent.fromJson(const {
        'ticker': 'PETR4',
        'type': 'DIVIDENDO',
        'userQuantity': 1.0,
        'estimatedGrossAmount': 1.0,
        'status': 'ANNOUNCED',
      });
      final radar = DividendRadar(upcoming: [event], history: const []);
      expect(radar.nextPayment, event);
      expect(radar.isEmpty, isFalse);
    });

    test('fromJson parses both upcoming and history lists', () {
      final radar = DividendRadar.fromJson({
        'upcoming': [
          {
            'ticker': 'PETR4',
            'type': 'DIVIDENDO',
            'userQuantity': 1.0,
            'estimatedGrossAmount': 1.0,
            'status': 'ANNOUNCED',
          },
        ],
        'history': [
          {
            'ticker': 'VALE3',
            'type': 'JCP',
            'userQuantity': 2.0,
            'estimatedGrossAmount': 2.0,
            'status': 'PAID',
          },
        ],
      });

      expect(radar.upcoming, hasLength(1));
      expect(radar.history, hasLength(1));
      expect(radar.upcoming.first.ticker, 'PETR4');
      expect(radar.history.first.ticker, 'VALE3');
    });

    test('fromJson with missing lists yields empty lists', () {
      final radar = DividendRadar.fromJson(const {});
      expect(radar.upcoming, isEmpty);
      expect(radar.history, isEmpty);
    });
  });
}
