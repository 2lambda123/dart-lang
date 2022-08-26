// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;

/// The value returned by [levenshtein] if the distance is determined
/// to be over the specified threshold.
const int LEVENSHTEIN_MAX = 1 << 20;

const int _MAX_VALUE = 1 << 10;

/// Find the Levenshtein distance between two [String]s if it's less than or
/// equal to a given threshold.
///
/// This is the number of changes needed to change one String into another,
/// where each change is a single character modification (deletion, insertion
/// or substitution).
///
/// This implementation follows from Algorithms on Strings, Trees and Sequences
/// by Dan Gusfield and Chas Emerick's implementation of the Levenshtein
/// distance algorithm.
int levenshtein(String s, String t, int threshold,
    {bool caseSensitive = true}) {
  if (threshold < 0) {
    throw ArgumentError('Threshold must not be negative');
  }

  if (!caseSensitive) {
    s = s.toLowerCase();
    t = t.toLowerCase();
  }

  var s_len = s.length;
  var t_len = t.length;

  // if one string is empty,
  // the edit distance is necessarily the length of the other
  if (s_len == 0) {
    return t_len <= threshold ? t_len : LEVENSHTEIN_MAX;
  }
  if (t_len == 0) {
    return s_len <= threshold ? s_len : LEVENSHTEIN_MAX;
  }
  // the distance can never be less than abs(s_len - t_len)
  if ((s_len - t_len).abs() > threshold) {
    return LEVENSHTEIN_MAX;
  }

  // swap the two strings to consume less memory
  if (s_len > t_len) {
    var tmp = s;
    s = t;
    t = tmp;
    s_len = t_len;
    t_len = t.length;
  }

  // 'previous' cost array, horizontally
  var p = List<int>.filled(s_len + 1, 0);
  // cost array, horizontally
  var d = List<int>.filled(s_len + 1, 0);
  // placeholder to assist in swapping p and d
  List<int> holder;

  // fill in starting table values
  var boundary = math.min(s_len, threshold) + 1;
  for (var i = 0; i < boundary; i++) {
    p[i] = i;
  }

  // these fills ensure that the value above the rightmost entry of our
  // stripe will be ignored in following loop iterations
  _setRange(p, boundary, p.length, _MAX_VALUE);
  _setRange(d, 0, d.length, _MAX_VALUE);

  // iterates through t
  for (var j = 1; j <= t_len; j++) {
    // jth character of t
    var t_j = t.codeUnitAt(j - 1);
    d[0] = j;

    // compute stripe indices, constrain to array size
    var min = math.max(1, j - threshold);
    var max = math.min(s_len, j + threshold);

    // the stripe may lead off of the table if s and t are of different sizes
    if (min > max) {
      return LEVENSHTEIN_MAX;
    }

    // ignore entry left of leftmost
    if (min > 1) {
      d[min - 1] = _MAX_VALUE;
    }

    // iterates through [min, max] in s
    for (var i = min; i <= max; i++) {
      if (s.codeUnitAt(i - 1) == t_j) {
        // diagonally left and up
        d[i] = p[i - 1];
      } else {
        // 1 + minimum of cell to the left, to the top, diagonally left and up
        d[i] = 1 + math.min(math.min(d[i - 1], p[i]), p[i - 1]);
      }
    }

    // copy current distance counts to 'previous row' distance counts
    holder = p;
    p = d;
    d = holder;
  }

  // if p[n] is greater than the threshold,
  // there's no guarantee on it being the correct distance
  if (p[s_len] <= threshold) {
    return p[s_len];
  }

  return LEVENSHTEIN_MAX;
}

void _setRange(List<int> a, int start, int end, int value) {
  for (var i = start; i < end; i++) {
    a[i] = value;
  }
}
