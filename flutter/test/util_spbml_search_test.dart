import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  test('run UtilSpBMLSearch test', () {
    List<SpBMLBlock> target = SpBMLParser.run(
        "(a)aaa\n+(b, key1:abc, key2:def)bbb\nccc\n(esc)(d)ddd\n+(e)eee\n++(a)fff\n(g)ggg",
        isGraphMode: true);
    // type check
    List<SpBMLBlock>? blockA =
        UtilSpBMLSearch.blockType(target, ["a"], endNum: 1);
    expect(blockA![0].content, "aaa");
    expect(blockA.length, 1);
    List<SpBMLBlock>? blockA2 = UtilSpBMLSearch.blockType(target, ["a"]);
    expect(blockA2!.length, 2);
    expect(blockA2[0].content, "aaa");
    expect(blockA2[1].content, "fff");
    // Content check
    List<SpBMLBlock> target2 = SpBMLParser.run(
        "(a)1\n+(b, key1:abc, key2:def)2\n+(e)3\n++(a)4\n(g)5",
        isGraphMode: true);
    SpBMLSearcher sc1 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.equal, 2),
      SpBMLSearchParam(EnumSpBMLOperator.equal, 3)
    ], EnumSpBMLLogicalOperator.opOr);
    SpBMLSearcher sc2 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.equal, 4),
      SpBMLSearchParam(EnumSpBMLOperator.equal, 5)
    ], EnumSpBMLLogicalOperator.opOr);
    List<SpBMLBlock>? r1 = UtilSpBMLSearch.blockContent(
        target2, [sc1, sc2], EnumSpBMLLogicalOperator.opAnd);
    expect(r1, null);
    List<SpBMLBlock>? r2 = UtilSpBMLSearch.blockContent(
        target2, [sc1, sc2], EnumSpBMLLogicalOperator.opOr);
    expect(r2!.length, 4);
    expect(r2[0].content, "2");
    expect(r2[1].content, "3");
    expect(r2[2].content, "4");
    expect(r2[3].content, "5");
    SpBMLSearcher sc3 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.equal, 2),
      SpBMLSearchParam(EnumSpBMLOperator.equal, 3)
    ], EnumSpBMLLogicalOperator.opAnd);
    SpBMLSearcher sc4 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.equal, 4),
      SpBMLSearchParam(EnumSpBMLOperator.equal, 5)
    ], EnumSpBMLLogicalOperator.opAnd);
    List<SpBMLBlock>? r3 = UtilSpBMLSearch.blockContent(
        target2, [sc3, sc4], EnumSpBMLLogicalOperator.opAnd);
    expect(r3, null);
    List<SpBMLBlock>? r4 = UtilSpBMLSearch.blockContent(
        target2, [sc3, sc4], EnumSpBMLLogicalOperator.opOr);
    expect(r4, null);
    SpBMLSearcher sc5 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.underOrEqual, 3),
      SpBMLSearchParam(EnumSpBMLOperator.overOrEqual, 2)
    ], EnumSpBMLLogicalOperator.opAnd);
    List<SpBMLBlock>? r5 = UtilSpBMLSearch.blockContent(
        target2, [sc5], EnumSpBMLLogicalOperator.opAnd);
    expect(r5!.length, 2);
    expect(r5[0].content, "2");
    expect(r5[1].content, "3");
    SpBMLSearcher sc6 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.under, 3),
    ], EnumSpBMLLogicalOperator.opOr);
    List<SpBMLBlock>? r6 = UtilSpBMLSearch.blockContent(
        target2, [sc6], EnumSpBMLLogicalOperator.opAnd);
    expect(r6!.length, 2);
    expect(r6[0].content, "1");
    expect(r6[1].content, "2");
    SpBMLSearcher sc7 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.over, 3),
    ], EnumSpBMLLogicalOperator.opOr);
    List<SpBMLBlock>? r7 = UtilSpBMLSearch.blockContent(
        target2, [sc7], EnumSpBMLLogicalOperator.opAnd);
    expect(r7!.length, 2);
    expect(r7[0].content, "4");
    expect(r7[1].content, "5");
    // param test
    List<SpBMLBlock> target3 = SpBMLParser.run(
        "(a, abc:000, def:111)aaa\n+(b, def:222)bbb\n(c, abc:222)ccc\n(d, abc:222)ddd",
        isGraphMode: true);
    SpBMLSearcher sc8 = SpBMLSearcher([
      SpBMLSearchParam(EnumSpBMLOperator.equal, 000),
      SpBMLSearchParam(EnumSpBMLOperator.equal, 222)
    ], EnumSpBMLLogicalOperator.opOr);
    List<SpBMLBlock>? r8 = UtilSpBMLSearch.blockParams(
        target3, "abc", [sc8], EnumSpBMLLogicalOperator.opAnd);
    expect(r8![0].content, "aaa");
    expect(r8[1].content, "ccc");
    expect(r8[2].content, "ddd");
    // nest test
    SpBMLSearcher sc9 = SpBMLSearcher(
        [SpBMLSearchParam(EnumSpBMLOperator.equal, 1)],
        EnumSpBMLLogicalOperator.opAnd);
    List<SpBMLBlock>? r9 = UtilSpBMLSearch.blockNestLevel(
        target3, [sc9], EnumSpBMLLogicalOperator.opAnd);
    expect(r9![0].content, "bbb");
    // for main test
    // create block
    SpBMLBuilder b1 = SpBMLBuilder();
    b1.add("typeA", {"parameter": "A"}, "Content Text A");
    b1.add("typeB", {"parameter": "B"}, "Content Text B");
    b1.add("typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
    SpBMLBuilder b2 = SpBMLBuilder();
    b2.set(0, "typeA", {"parameter": "A"}, "Content Text A");
    b2.set(1, "typeB", {"parameter": "B"}, "Content Text B");
    b2.set(2, "typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
    expect(b1.build() == b2.build(), true);
    // search block by type.
    List<SpBMLBlock>? s1 =
        UtilSpBMLSearch.blockType(b1.getBlockList(), ["typeC"]);
    expect(s1![0].type, "typeC");
    // search block by nest level.
    List<SpBMLSearchParam> sp1 = [SpBMLSearchParam(EnumSpBMLOperator.equal, 1)];
    List<SpBMLBlock>? s2 = UtilSpBMLSearch.blockNestLevel(
        b1.getBlockList(),
        [SpBMLSearcher(sp1, EnumSpBMLLogicalOperator.opAnd)],
        EnumSpBMLLogicalOperator.opAnd);
    expect(s2![0].type, "typeC");
    // search block by content
    List<SpBMLSearchParam> sp2 = [
      SpBMLSearchParam(EnumSpBMLOperator.equal, "Content Text C")
    ];
    List<SpBMLBlock>? s3 = UtilSpBMLSearch.blockContent(
        b1.getBlockList(),
        [SpBMLSearcher(sp2, EnumSpBMLLogicalOperator.opAnd)],
        EnumSpBMLLogicalOperator.opAnd);
    expect(s3![0].type, "typeC");
    // search block by parameter
    List<SpBMLSearchParam> sp3 = [
      SpBMLSearchParam(EnumSpBMLOperator.equal, "C")
    ];
    List<SpBMLBlock>? s4 = UtilSpBMLSearch.blockParams(
        b1.getBlockList(),
        "parameter",
        [SpBMLSearcher(sp3, EnumSpBMLLogicalOperator.opAnd)],
        EnumSpBMLLogicalOperator.opAnd);
    expect(s4![0].type, "typeC");
  });
}
