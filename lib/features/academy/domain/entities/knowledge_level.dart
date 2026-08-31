/// The learner's **Knowledge Progress** tier — how much of the curriculum
/// they've actually completed, distinct from Game Level (XP-driven, see
/// `LevelCalculator`). See `KnowledgeProgressCalculator` for how a tier is
/// derived and `docs/PRODUCT_VISION.md` §9 for why these two tracks must
/// never be conflated in product copy or logic.
enum KnowledgeLevel {
  absoluteBeginner,
  financialApprentice,
  financialOrganizer,
  financialProtector,
  beginnerInvestor,
  investor,
  analyst,
  wealthBuilder,
  financialStrategist,
  financialMaster,
}
