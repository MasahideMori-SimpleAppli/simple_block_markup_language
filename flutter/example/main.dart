import 'package:flutter/material.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  // create block
  SpBMLBuilder b1 = SpBMLBuilder();
  b1.add("typeA", {"parameter": "A"}, "Content Text A");
  b1.add("typeB", {"parameter": "B"}, "Content Text B");
  b1.add("typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
  SpBMLBuilder b2 = SpBMLBuilder();
  b2.set(0, "typeA", {"parameter": "A"}, "Content Text A");
  b2.set(1, "typeB", {"parameter": "B"}, "Content Text B");
  b2.set(2, "typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
  debugPrint(b1.build());
  debugPrint((b1.build() == b2.build()).toString());
  // search block by type.
  List<SpBMLBlock>? s1 =
      UtilSpBMLSearch.blockType(b1.getBlockList(), ["typeC"]);
  debugPrint((s1![0].type == "typeC").toString());
  // search block by nest level.
  List<SpBMLSearchParam> sp1 = [SpBMLSearchParam(EnumSpBMLOperator.equal, 1)];
  List<SpBMLBlock>? s2 = UtilSpBMLSearch.blockNestLevel(
      b1.getBlockList(),
      [SpBMLSearcher(sp1, EnumSpBMLLogicalOperator.opAnd)],
      EnumSpBMLLogicalOperator.opAnd);
  debugPrint((s2![0].type == "typeC").toString());
  // search block by content
  List<SpBMLSearchParam> sp2 = [
    SpBMLSearchParam(EnumSpBMLOperator.equal, "Content Text C")
  ];
  List<SpBMLBlock>? s3 = UtilSpBMLSearch.blockContent(
      b1.getBlockList(),
      [SpBMLSearcher(sp2, EnumSpBMLLogicalOperator.opAnd)],
      EnumSpBMLLogicalOperator.opAnd);
  debugPrint((s3![0].type == "typeC").toString());
  // search block by parameter
  List<SpBMLSearchParam> sp3 = [SpBMLSearchParam(EnumSpBMLOperator.equal, "C")];
  List<SpBMLBlock>? s4 = UtilSpBMLSearch.blockParams(
      b1.getBlockList(),
      "parameter",
      [SpBMLSearcher(sp3, EnumSpBMLLogicalOperator.opAnd)],
      EnumSpBMLLogicalOperator.opAnd);
  debugPrint((s4![0].type == "typeC").toString());
}
