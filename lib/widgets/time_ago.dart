/// Formats a [DateTime] as a short relative string, e.g. "2d ago".
/// Used throughout opportunity/application cards to echo the compact
/// "Posted 3 days ago" style timestamps.
String timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
