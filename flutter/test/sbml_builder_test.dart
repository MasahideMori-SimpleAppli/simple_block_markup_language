import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/sbml_block.dart';
import 'package:simple_block_markup_language/sbml_builder.dart';
import 'package:simple_block_markup_language/sbml_exception.dart';

void main() {
  test('run SBMLBuilder test', () {
    const String base =
        "(a)aaa\n+(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd\n+(e)eee\n++(f)fff\n(g)ggg";
    // 等価生成テスト
    SBMLBuilder builder = SBMLBuilder();
    builder.add("a", {}, "aaa");
    // ここでは動的に作成するのでエスケープが要らない。
    builder.add("b", {"key1": "abc", "key2": "def"}, "bbb\nccc\n(d)ddd",
        parentSerial: 0);
    builder.add("e", {}, "eee", parentSerial: 0);
    builder.add("f", {}, "fff", parentSerial: 2);
    builder.add("g", {}, "ggg");
    expect(builder.build(), base);
    List<SBMLBlock> e = builder.getUnderAllBlocks(2);
    builder.remove(2);
    const String removed =
        "(a)aaa\n+(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd\n(g)ggg";
    expect(builder.build(), removed);
    const String inserted =
        "(a)aaa\n+(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd\n(g)ggg\n+(e)eee\n++(f)fff";
    builder.reinsert(4, e);
    expect(builder.build(), inserted);
    expect(2, builder.getBlock(2).serial);
    const String exchanged =
        "(e)eee\n+(f)fff\n(g)ggg\n+(a)aaa\n++(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd";
    builder.exchangePositions(0, 2);
    expect(builder.build(), exchanged);
    const String reFormatted = "(e)eee\n+(f)fff";
    builder.clear();
    expect(builder.build(), "");
    builder.loadFromBlockList(e);
    expect(builder.build(), reFormatted);
    builder.clear();
    builder.loadFromSBML(reFormatted);
    expect(builder.build(), reFormatted);
    List<SBMLBlock> popBlocks = builder.pop(0);
    expect(builder.build(), "");
    builder.loadFromBlockList(popBlocks);
    expect(builder.build(), reFormatted);
    // エスケープシーケンスのテスト
    const String escaped =
        "(a,escape:es\\\\cape,space:s\\ pace,comma:co\\,mma,colon\\::colon,brackets:brackets\\))aaa";
    SBMLBuilder builder2 = SBMLBuilder();
    builder2.loadFromSBML(escaped);
    expect(builder2.build(), escaped);
    // set Method test
    SBMLBuilder b1 = SBMLBuilder();
    b1.add("typeA", {"parameterA": "A"}, "Content Text");
    b1.add("typeB", {"parameterB": "B"}, "Content Text");
    b1.add("typeC", {"parameterC": "C"}, "Content Text", parentSerial: 1);
    SBMLBuilder b2 = SBMLBuilder();
    b2.set(0, "typeA", {"parameterA": "A"}, "Content Text");
    b2.set(1, "typeB", {"parameterB": "B"}, "Content Text");
    b2.set(2, "typeC", {"parameterC": "C"}, "Content Text", parentSerial: 1);
    expect(b1.build() == b2.build(), true);
    // input check test
    try {
      b2.add("a\na", {}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    try {
      b2.add("a", {"aaaaaa": "a\naa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    try {
      b2.add("a", {"aaa\naaa": "aaa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    try {
      b2.set(0, "a", {"aaaaaa": "a\naa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    try {
      b2.set(0, "a", {"aaa\naaa": "aaa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    try {
      b2.add("esc", {"a": "a"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    try {
      b2.add("root", {"a": "a"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
    // SyntaxError check test.
    try {
      const String eStr = "(esc)aaa\n(b)bbb";
      SBMLBuilder b3 = SBMLBuilder();
      b3.loadFromSBML(eStr);
      expect(false, true);
    } catch (e) {
      expect(e is SBMLException, true);
    }
  });
}
