class OnboardingStatusModel {
  final bool hasAnswered;
  final String? profile;

  const OnboardingStatusModel({
    required this.hasAnswered,
    required this.profile,
  });

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusModel(
      hasAnswered: json['hasAnswered'] as bool,
      profile: json['profile'] as String?,
    );
  }
}

