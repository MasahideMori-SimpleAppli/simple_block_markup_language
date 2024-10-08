import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  test('run SpBMLBuilder test', () {
    const String base =
        "(a)aaa\n+(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd\n+(e)eee\n++(f)fff\n(g)ggg";
    // 等価生成テスト
    SpBMLBuilder builder = SpBMLBuilder();
    builder.add("a", {}, "aaa");
    // ここでは動的に作成するのでエスケープが要らない。
    builder.add("b", {"key1": "abc", "key2": "def"}, "bbb\nccc\n(d)ddd",
        parentSerial: 0);
    builder.add("e", {}, "eee", parentSerial: 0);
    builder.add("f", {}, "fff", parentSerial: 2);
    builder.add("g", {}, "ggg");
    expect(builder.build(), base);
    List<SpBMLBlock> e = builder.getUnderAllBlocks(2);
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
    builder.loadFromSpBML(reFormatted);
    expect(builder.build(), reFormatted);
    List<SpBMLBlock> popBlocks = builder.pop(0);
    expect(builder.build(), "");
    builder.loadFromBlockList(popBlocks);
    expect(builder.build(), reFormatted);
    // エスケープシーケンスのテスト
    const String escaped =
        "(a,escape:es\\\\cape,space:s\\ pace,comma:co\\,mma,colon\\::colon,brackets:brackets\\))aaa";
    SpBMLBuilder builder2 = SpBMLBuilder();
    builder2.loadFromSpBML(escaped);
    expect(builder2.build(), escaped);
    // set Method test
    SpBMLBuilder b1 = SpBMLBuilder();
    b1.add("typeA", {"parameterA": "A"}, "Content Text");
    b1.add("typeB", {"parameterB": "B"}, "Content Text");
    b1.add("typeC", {"parameterC": "C"}, "Content Text", parentSerial: 1);
    SpBMLBuilder b2 = SpBMLBuilder();
    b2.set(0, "typeA", {"parameterA": "A"}, "Content Text");
    b2.set(1, "typeB", {"parameterB": "B"}, "Content Text");
    b2.set(2, "typeC", {"parameterC": "C"}, "Content Text", parentSerial: 1);
    expect(b1.build() == b2.build(), true);
    // input check test
    try {
      b2.add("a\na", {}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    try {
      b2.add("a", {"aaaaaa": "a\naa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    try {
      b2.add("a", {"aaa\naaa": "aaa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    try {
      b2.set(0, "a", {"aaaaaa": "a\naa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    try {
      b2.set(0, "a", {"aaa\naaa": "aaa"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    try {
      b2.add("esc", {"a": "a"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    try {
      b2.add("root", {"a": "a"}, "aaa");
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
    // SyntaxError check test.
    try {
      const String eStr = "(esc)aaa\n(b)bbb";
      SpBMLBuilder b3 = SpBMLBuilder();
      b3.loadFromSpBML(eStr);
      expect(false, true);
    } catch (e) {
      expect(e is SpBMLException, true);
    }
  });

  test('SpBMLBuilder replace test', () {
    const String src = "(a)aaa\n"
        "+(b,key1:abc,key2:def)bbb\n"
        "ccc\n"
        "(esc)(d)ddd\n"
        "+(e)eee\n"
        "++(f)fff\n"
        "(g)ggg";
    // 等価生成テスト
    SpBMLBuilder builder = SpBMLBuilder();
    builder.loadFromSpBML(src);
    SpBMLBlock target =
        UtilSpBMLSearch.blockType(builder.getBlockList(), ["b"])!.first;
    builder.replace(target.serial, "h", {}, "replaced");
    const String checkReplaced = "(a)aaa\n"
        "+(h)replaced\n"
        "+(e)eee\n"
        "++(f)fff\n"
        "(g)ggg";
    expect(builder.build() == checkReplaced, true);
  });

  test('SpBMLBuilder loadFromSpBML and build test', () {
    const String src = "(a)aaa\n"
        "(b)bbb\nbbb\n"
        "(c)\n"
        "(d)\nddd\n"
        "(e)eee\n\n"
        "(f)fff\n\nfff\n"
        "(g)\n\n"
        "(h)\n\nhhh";
    // Build後に改行コードの数が想定どおりかどうかをテスト
    SpBMLBuilder builder = SpBMLBuilder();
    builder.loadFromSpBML(src);
    for (SpBMLBlock i in builder.getBlockList()) {
      if (i.type == "a") {
        expect(i.content == "aaa", true);
      } else if (i.type == "b") {
        expect(i.content == "bbb\nbbb", true);
      } else if (i.type == "c") {
        expect(i.content == "", true);
      } else if (i.type == "d") {
        expect(i.content == "\nddd", true);
      } else if (i.type == "e") {
        expect(i.content == "eee\n", true);
      } else if (i.type == "f") {
        expect(i.content == "fff\n\nfff", true);
      } else if (i.type == "g") {
        expect(i.content == "\n", true);
      } else if (i.type == "h") {
        expect(i.content == "\n\nhhh", true);
      }
    }
    final String spbml = builder.build();
    expect(spbml, src);
  });
}
