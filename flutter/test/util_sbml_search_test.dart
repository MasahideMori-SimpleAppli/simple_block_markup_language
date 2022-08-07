import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/sbml.dart';

void main() {
  test('run UtilSBMLSearch test', () {
    List<SBMLBlock> target = SBMLParser.run(
        "(a)aaa\n+(b, key1:abc, key2:def)bbb\nccc\n(esc)(d)ddd\n+(e)eee\n++(a)fff\n(g)ggg",
        isGraphMode: true);
    // type check
    List<SBMLBlock>? blockA =
        UtilSBMLSearch.blockType(target, ["a"], endNum: 1);
    expect(blockA![0].content, "aaa");
    expect(blockA.length, 1);
    List<SBMLBlock>? blockA2 = UtilSBMLSearch.blockType(target, ["a"]);
    expect(blockA2!.length, 2);
    expect(blockA2[0].content, "aaa");
    expect(blockA2[1].content, "fff");
    // Content check
    List<SBMLBlock> target2 = SBMLParser.run(
        "(a)1\n+(b, key1:abc, key2:def)2\n+(e)3\n++(a)4\n(g)5",
        isGraphMode: true);
    SBMLSearcher sc1 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.equal, 2),
      SBMLSearchParam(EnumSBMLOperator.equal, 3)
    ], EnumSBMLLogicalOperator.opOr);
    SBMLSearcher sc2 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.equal, 4),
      SBMLSearchParam(EnumSBMLOperator.equal, 5)
    ], EnumSBMLLogicalOperator.opOr);
    List<SBMLBlock>? r1 = UtilSBMLSearch.blockContent(
        target2, [sc1, sc2], EnumSBMLLogicalOperator.opAnd);
    expect(r1, null);
    List<SBMLBlock>? r2 = UtilSBMLSearch.blockContent(
        target2, [sc1, sc2], EnumSBMLLogicalOperator.opOr);
    expect(r2!.length, 4);
    expect(r2[0].content, "2");
    expect(r2[1].content, "3");
    expect(r2[2].content, "4");
    expect(r2[3].content, "5");
    SBMLSearcher sc3 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.equal, 2),
      SBMLSearchParam(EnumSBMLOperator.equal, 3)
    ], EnumSBMLLogicalOperator.opAnd);
    SBMLSearcher sc4 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.equal, 4),
      SBMLSearchParam(EnumSBMLOperator.equal, 5)
    ], EnumSBMLLogicalOperator.opAnd);
    List<SBMLBlock>? r3 = UtilSBMLSearch.blockContent(
        target2, [sc3, sc4], EnumSBMLLogicalOperator.opAnd);
    expect(r3, null);
    List<SBMLBlock>? r4 = UtilSBMLSearch.blockContent(
        target2, [sc3, sc4], EnumSBMLLogicalOperator.opOr);
    expect(r4, null);
    SBMLSearcher sc5 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.underOrEqual, 3),
      SBMLSearchParam(EnumSBMLOperator.overOrEqual, 2)
    ], EnumSBMLLogicalOperator.opAnd);
    List<SBMLBlock>? r5 = UtilSBMLSearch.blockContent(
        target2, [sc5], EnumSBMLLogicalOperator.opAnd);
    expect(r5!.length, 2);
    expect(r5[0].content, "2");
    expect(r5[1].content, "3");
    SBMLSearcher sc6 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.under, 3),
    ], EnumSBMLLogicalOperator.opOr);
    List<SBMLBlock>? r6 = UtilSBMLSearch.blockContent(
        target2, [sc6], EnumSBMLLogicalOperator.opAnd);
    expect(r6!.length, 2);
    expect(r6[0].content, "1");
    expect(r6[1].content, "2");
    SBMLSearcher sc7 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.over, 3),
    ], EnumSBMLLogicalOperator.opOr);
    List<SBMLBlock>? r7 = UtilSBMLSearch.blockContent(
        target2, [sc7], EnumSBMLLogicalOperator.opAnd);
    expect(r7!.length, 2);
    expect(r7[0].content, "4");
    expect(r7[1].content, "5");
    // param test
    List<SBMLBlock> target3 = SBMLParser.run(
        "(a, abc:000, def:111)aaa\n+(b, def:222)bbb\n(c, abc:222)ccc\n(d, abc:222)ddd",
        isGraphMode: true);
    SBMLSearcher sc8 = SBMLSearcher([
      SBMLSearchParam(EnumSBMLOperator.equal, 000),
      SBMLSearchParam(EnumSBMLOperator.equal, 222)
    ], EnumSBMLLogicalOperator.opOr);
    List<SBMLBlock>? r8 = UtilSBMLSearch.blockParams(
        target3, "abc", [sc8], EnumSBMLLogicalOperator.opAnd);
    expect(r8![0].content, "aaa");
    expect(r8[1].content, "ccc");
    expect(r8[2].content, "ddd");
    // nest test
    SBMLSearcher sc9 = SBMLSearcher(
        [SBMLSearchParam(EnumSBMLOperator.equal, 1)],
        EnumSBMLLogicalOperator.opAnd);
    List<SBMLBlock>? r9 = UtilSBMLSearch.blockNestLevel(
        target3, [sc9], EnumSBMLLogicalOperator.opAnd);
    expect(r9![0].content, "bbb");
    // for main test
    // create block
    SBMLBuilder b1 = SBMLBuilder();
    b1.add("typeA", {"parameter": "A"}, "Content Text A");
    b1.add("typeB", {"parameter": "B"}, "Content Text B");
    b1.add("typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
    SBMLBuilder b2 = SBMLBuilder();
    b2.set(0, "typeA", {"parameter": "A"}, "Content Text A");
    b2.set(1, "typeB", {"parameter": "B"}, "Content Text B");
    b2.set(2, "typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
    expect(b1.build() == b2.build(), true);
    // search block by type.
    List<SBMLBlock>? s1 =
        UtilSBMLSearch.blockType(b1.getBlockList(), ["typeC"]);
    expect(s1![0].type, "typeC");
    // search block by nest level.
    List<SBMLSearchParam> sp1 = [SBMLSearchParam(EnumSBMLOperator.equal, 1)];
    List<SBMLBlock>? s2 = UtilSBMLSearch.blockNestLevel(
        b1.getBlockList(),
        [SBMLSearcher(sp1, EnumSBMLLogicalOperator.opAnd)],
        EnumSBMLLogicalOperator.opAnd);
    expect(s2![0].type, "typeC");
    // search block by content
    List<SBMLSearchParam> sp2 = [
      SBMLSearchParam(EnumSBMLOperator.equal, "Content Text C")
    ];
    List<SBMLBlock>? s3 = UtilSBMLSearch.blockContent(
        b1.getBlockList(),
        [SBMLSearcher(sp2, EnumSBMLLogicalOperator.opAnd)],
        EnumSBMLLogicalOperator.opAnd);
    expect(s3![0].type, "typeC");
    // search block by parameter
    List<SBMLSearchParam> sp3 = [SBMLSearchParam(EnumSBMLOperator.equal, "C")];
    List<SBMLBlock>? s4 = UtilSBMLSearch.blockParams(
        b1.getBlockList(),
        "parameter",
        [SBMLSearcher(sp3, EnumSBMLLogicalOperator.opAnd)],
        EnumSBMLLogicalOperator.opAnd);
    expect(s4![0].type, "typeC");
  });
}
