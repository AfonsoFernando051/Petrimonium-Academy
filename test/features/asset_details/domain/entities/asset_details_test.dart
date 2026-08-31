import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_data_status.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/asset_details/domain/entities/user_position.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';

void main() {
  DividendEvent buildDividend({required DividendStatus status}) {
    return DividendEvent(
      ticker: 'PETR4',
      type: DividendType.DIVIDENDO,
      rawLabel: 'Dividendo',
      ratePerShare: 1.0,
      dataCom: null,
      paymentDate: null,
      approvedOn: null,
      userQuantity: 10,
      estimatedGrossAmount: 10,
      status: status,
    );
  }

  group('AssetDetails computed getters', () {
    test('displayName prefers shortName over ticker', () {
      const details = AssetDetails(ticker: 'PETR4', shortName: 'Petrobras');
      expect(details.displayName, 'Petrobras');
    });

    test('displayName falls back to ticker when shortName is null', () {
      const details = AssetDetails(ticker: 'PETR4');
      expect(details.displayName, 'PETR4');
    });

    test('isOwned is true only when userPosition exists and quantity > 0', () {
      const noPosition = AssetDetails(ticker: 'PETR4');
      expect(noPosition.isOwned, isFalse);

      const zeroPosition = UserPosition(
        quantity: 0,
        averagePrice: 0,
        investedValue: 0,
        currentValue: 0,
        unrealizedGain: 0,
        unrealizedGainPercent: 0,
        portfolioWeight: 0,
      );
      const zeroQuantity = AssetDetails(ticker: 'PETR4', userPosition: zeroPosition);
      expect(zeroQuantity.isOwned, isFalse);

      const ownedPosition = UserPosition(
        quantity: 10,
        averagePrice: 30,
        investedValue: 300,
        currentValue: 355,
        unrealizedGain: 55,
        unrealizedGainPercent: 18.3,
        portfolioWeight: 5,
      );
      const owned = AssetDetails(ticker: 'PETR4', userPosition: ownedPosition);
      expect(owned.isOwned, isTrue);
    });

    test('isStock/isFii/isEtf/isBdr reflect assetType exactly', () {
      expect(const AssetDetails(ticker: 'PETR4', assetType: 'stock').isStock, isTrue);
      expect(const AssetDetails(ticker: 'PETR4', assetType: 'stock').isFii, isFalse);
      expect(const AssetDetails(ticker: 'HGLG11', assetType: 'fii').isFii, isTrue);
      expect(const AssetDetails(ticker: 'IVVB11', assetType: 'etf').isEtf, isTrue);
      expect(const AssetDetails(ticker: 'AAPL34', assetType: 'bdr').isBdr, isTrue);
      expect(const AssetDetails(ticker: 'X').isStock, isFalse);
    });

    test('upcomingDividends returns only ANNOUNCED entries', () {
      final details = AssetDetails(
        ticker: 'PETR4',
        recentDividends: [
          buildDividend(status: DividendStatus.ANNOUNCED),
          buildDividend(status: DividendStatus.PAID),
        ],
      );

      expect(details.upcomingDividends, hasLength(1));
      expect(details.upcomingDividends.first.status, DividendStatus.ANNOUNCED);
    });

    test('paidDividends returns only PAID entries', () {
      final details = AssetDetails(
        ticker: 'PETR4',
        recentDividends: [
          buildDividend(status: DividendStatus.ANNOUNCED),
          buildDividend(status: DividendStatus.PAID),
          buildDividend(status: DividendStatus.PAID),
        ],
      );

      expect(details.paidDividends, hasLength(2));
      expect(details.paidDividends.every((d) => d.status == DividendStatus.PAID), isTrue);
    });
  });

  group('AssetDetails.fromJson', () {
    test('parses a full response including nested position and dividends', () {
      final details = AssetDetails.fromJson({
        'ticker': 'PETR4',
        'shortName': 'Petrobras',
        'longName': 'Petroleo Brasileiro SA',
        'assetType': 'stock',
        'sector': 'Energy',
        'industry': 'Oil & Gas',
        'logoUrl': 'https://example.com/logo.png',
        'currentPrice': 35.5,
        'previousClose': 34.9,
        'dailyChange': 0.6,
        'dailyChangePercent': 1.7,
        'currency': 'BRL',
        'marketCap': 500000000.0,
        'priceToEarnings': 8.2,
        'priceToBook': 1.1,
        'evToEbitda': 4.5,
        'dividendYield': 0.09,
        'returnOnEquity': 0.25,
        'returnOnAssets': 0.1,
        'netMargin': 0.2,
        'operatingMargin': 0.3,
        'netDebt': 1000000.0,
        'debtToEquity': 0.5,
        'totalCash': 200000.0,
        'totalRevenue': 900000.0,
        'ebitda': 300000.0,
        'netAssetValue': 12.0,
        'pvp': 1.2,
        'fiftyTwoWeekHigh': 40.0,
        'fiftyTwoWeekLow': 25.0,
        'averageVolume': 1000000,
        'regularMarketVolume': 1200000,
        'userPosition': {
          'quantity': 10.0,
          'averagePrice': 30.0,
          'investedValue': 300.0,
          'currentValue': 355.0,
          'unrealizedGain': 55.0,
          'unrealizedGainPercent': 18.3,
          'portfolioWeight': 5.0,
        },
        'recentDividends': [
          {
            'ticker': 'PETR4',
            'type': 'DIVIDENDO',
            'rawLabel': 'Dividendo',
            'ratePerShare': 1.0,
            'userQuantity': 10.0,
            'estimatedGrossAmount': 10.0,
            'status': 'PAID',
          },
        ],
        'dataSource': 'brapi',
        'lastUpdated': '2026-08-20T10:00:00Z',
        'dataStatus': 'fresh',
      });

      expect(details.ticker, 'PETR4');
      expect(details.shortName, 'Petrobras');
      expect(details.assetType, 'stock');
      expect(details.currentPrice, 35.5);
      expect(details.userPosition?.quantity, 10.0);
      expect(details.recentDividends, hasLength(1));
      expect(details.dataStatus, AssetDataStatus.fresh);
      expect(details.averageVolume, 1000000);
    });

    test('missing fields fall back to safe defaults', () {
      final details = AssetDetails.fromJson(const {});

      expect(details.ticker, '');
      expect(details.assetType, 'unknown');
      expect(details.currentPrice, isNull);
      expect(details.userPosition, isNull);
      expect(details.recentDividends, isEmpty);
      expect(details.dataStatus, AssetDataStatus.unavailable);
    });
  });
}
