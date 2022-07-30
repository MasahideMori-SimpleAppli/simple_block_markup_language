import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/sbml_block.dart';
import 'package:simple_block_markup_language/sbml_builder.dart';

void main() {
  test('run SBMLBuilder test', () {
    const String base =
        "(a)aaa\n+(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd\n+(e)eee\n++(f)fff\n(g)ggg";
    // 等価生成テスト
    SBMLBuilder builder = SBMLBuilder();
    builder.add(-1, "a", {}, "aaa");
    // ここでは動的に作成するのでエスケープが要らない。
    builder.add(0, "b", {"key1": "abc", "key2": "def"}, "bbb\nccc\n(d)ddd");
    builder.add(0, "e", {}, "eee");
    builder.add(2, "f", {}, "fff");
    builder.add(-1, "g", {}, "ggg");
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
  });
}
