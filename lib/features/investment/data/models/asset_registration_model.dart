import 'package:petrimonium/features/investment/data/models/investment_type_enum.dart';

class AssetRegistrationModel {
  final String name;
  final double quantity;
  final double purchasePrice;
  final String purchaseDate;
  final InvestmentTypeEnum type;

  AssetRegistrationModel({
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate,
      'type': type.name,
    };
  }
}
