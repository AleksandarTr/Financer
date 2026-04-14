bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime normalize(DateTime date) => DateTime.utc(date.year, date.month, date.day);