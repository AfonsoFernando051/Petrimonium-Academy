# Flutter's own AAR ships its own consumer ProGuard rules (embedding, plugin registrant,
# etc.), so this file only needs app-specific exceptions on top of that.
#
# If a release build crashes with a ClassNotFoundException/NoSuchMethodError that a debug
# build doesn't, it's almost always a reflection-based library that needs an explicit -keep
# here — add it and note which library required it.
