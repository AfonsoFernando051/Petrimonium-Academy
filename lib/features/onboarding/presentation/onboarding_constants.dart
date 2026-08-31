/// A typical single-lesson XP reward, shown as an illustrative number in
/// onboarding screens that run before the user has any real progress (and,
/// for `AcademyIntroScreen`, before the Academy catalog may even be
/// reachable over the network). Every lesson in the real catalog is worth
/// 20 XP today — not derived from the catalog itself so these screens don't
/// depend on a network fetch for a decorative number.
const int kStandardLessonXpReward = 20;
