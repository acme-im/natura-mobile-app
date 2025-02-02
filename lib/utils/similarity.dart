// based on https://github.com/tdebatty/java-string-similarity

import 'dart:collection';

const int kDefaultK = 3;

class ShingleBased {
  final int _k;
  static final RegExp spaceRegExp = RegExp('\\s+');

  ShingleBased({final int k = kDefaultK}) : _k = k {
    if (_k <= 0) {
      throw 'k should be positive!';
    }
  }

  int get k => _k;

  Map<String, int> getProfile(final String string) {
    var shingles = HashMap<String, int>();
    var stringNoSpace = string.replaceAll(spaceRegExp, ' ');
    for (var i = 0; i < (stringNoSpace.length - _k + 1); i++) {
      var shingle = stringNoSpace.substring(i, i + _k);
      var old = shingles[shingle];
      if (old != null) {
        shingles[shingle] = old + 1;
      } else {
        shingles[shingle] = 1;
      }
    }
    return Map.unmodifiable(shingles);
  }
}

class Jaccard extends ShingleBased {
  Jaccard(final int k) : super(k: k);

  double similarity(final String s1, final String s2) {
    if (s1.isEmpty) {
      throw 's1 must not be empty';
    }

    if (s2.isEmpty) {
      throw 's2 must not be empty';
    }

    if (s1 == s2) {
      return 1;
    }

    var profile1 = getProfile(s1);
    var profile2 = getProfile(s2);

    Set<String> union = HashSet<String>();
    union.addAll(profile1.keys);
    union.addAll(profile2.keys);

    var inter = profile1.keys.length + profile2.keys.length - union.length;

    return 1.0 * inter / union.length;
  }

  double distance(final String s1, final String s2) {
    return 1.0 - similarity(s1, s2);
  }
}
