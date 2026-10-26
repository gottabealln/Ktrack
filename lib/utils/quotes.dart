const List<String> motivationalQuotes = [
  "You are stronger than the storm inside you.",
  "Healing is not linear, but it is happening.",
  "Breathe. You survived every bad day so far.",
  "Your feelings are valid. Your pain is real. You matter.",
  "One small step today is still progress.",
  "You are not broken. You are healing.",
  "The panic will pass. It always does.",
  "Rest is not weakness, it is wisdom.",
  "You are brave even on days you feel small.",
  "Your past does not define your future.",
  "Breathe in courage, breathe out fear.",
  "You are worthy of peace and gentleness.",
  "This moment will not last forever.",
  "You are doing better than you think.",
  "Your presence in this world matters.",
];

String getDailyQuote() {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return motivationalQuotes[dayOfYear % motivationalQuotes.length];
}