/// Domain service for formatting a string (truncate and wrap).
class StringFormatter {
  static String format(String line, {int? truncate, int? wrap}) {
    if (truncate == null && wrap == null) {
      return line;
    }

    // Both truncate and wrap provided
    if (truncate != null && wrap != null) {
      if (wrap >= truncate) {
        // Case 2: width >= truncate -> wrap is ignored, truncate only
        return _truncate(line, truncate);
      } else {
        // Case 1: width < truncate -> wrap every width, truncate at truncate with …
        final needsEllipsis = line.length > truncate;
        final content = needsEllipsis ? line.substring(0, truncate) : line;
        final chunks = _wrapToChunks(content, wrap);
        if (needsEllipsis && chunks.isNotEmpty) {
          chunks[chunks.length - 1] = '${chunks.last}…';
        }
        return chunks.join('\n');
      }
    }

    if (truncate != null) {
      return _truncate(line, truncate);
    }

    // wrap only
    return _wrapToChunks(line, wrap!).join('\n');
  }

  static String _truncate(String line, int limit) {
    if (line.length > limit) {
      return '${line.substring(0, limit)}…';
    }
    return line;
  }

  static List<String> _wrapToChunks(String text, int width) {
    if (width <= 0 || text.isEmpty) return [text];
    final chunks = <String>[];
    for (var i = 0; i < text.length; i += width) {
      final end = (i + width < text.length) ? i + width : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }
}
