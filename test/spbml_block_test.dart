import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  test('haveSameParams test', () {
    SpBMLBlock a = SpBMLBlock(1, 0, 1, "a", {}, "a");
    SpBMLBlock b = SpBMLBlock(2, 1, 2, "b", {}, "b");
    SpBMLBlock c = SpBMLBlock(3, 2, 3, "c", {"d": "d"}, "c");
    SpBMLBlock d = SpBMLBlock(4, 3, 4, "d", {"d": "d"}, "d");
    expect(a.haveSameParams(b), true);
    expect(b.haveSameParams(c), false);
    expect(c.haveSameParams(d), true);
  });
}
