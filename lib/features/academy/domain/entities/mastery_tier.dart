/// A learner's **Mastery** tier for one school — a performance-based signal,
/// deliberately distinct from Progress (`AcademyController.masteryFor`,
/// which is actually completion percent — see `MasteryCalculator`'s doc
/// comment). A school can be 100% complete while still only `applying`,
/// if some lessons were finished with a wrong answer along the way.
enum MasteryTier { exploring, understanding, applying, mastering }
