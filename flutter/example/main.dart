import 'package:flutter/material.dart';
import 'package:simple_block_markup_language/enum_sbml_logical_operator.dart';
import 'package:simple_block_markup_language/enum_sbml_operator.dart';
import 'package:simple_block_markup_language/sbml_block.dart';
import 'package:simple_block_markup_language/sbml_builder.dart';
import 'package:simple_block_markup_language/sbml_search_param.dart';
import 'package:simple_block_markup_language/sbml_searcher.dart';
import 'package:simple_block_markup_language/util_sbml_search.dart';

void main() {
  // create block
  SBMLBuilder b1 = SBMLBuilder();
  b1.add("typeA", {"parameter": "A"}, "Content Text A");
  b1.add("typeB", {"parameter": "B"}, "Content Text B");
  b1.add("typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
  SBMLBuilder b2 = SBMLBuilder();
  b2.set(0, "typeA", {"parameter": "A"}, "Content Text A");
  b2.set(1, "typeB", {"parameter": "B"}, "Content Text B");
  b2.set(2, "typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
  debugPrint(b1.build());
  debugPrint((b1.build() == b2.build()).toString());
  // search block by type.
  List<SBMLBlock>? s1 = UtilSBMLSearch.blockType(b1.getBlockList(), ["typeC"]);
  debugPrint((s1![0].type == "typeC").toString());
  // search block by nest level.
  List<SBMLSearchParam> sp1 = [SBMLSearchParam(EnumSBMLOperator.equal, 1)];
  List<SBMLBlock>? s2 = UtilSBMLSearch.blockNestLevel(
      b1.getBlockList(),
      [SBMLSearcher(sp1, EnumSBMLLogicalOperator.opAnd)],
      EnumSBMLLogicalOperator.opAnd);
  debugPrint((s2![0].type == "typeC").toString());
  // search block by content
  List<SBMLSearchParam> sp2 = [
    SBMLSearchParam(EnumSBMLOperator.equal, "Content Text C")
  ];
  List<SBMLBlock>? s3 = UtilSBMLSearch.blockContent(
      b1.getBlockList(),
      [SBMLSearcher(sp2, EnumSBMLLogicalOperator.opAnd)],
      EnumSBMLLogicalOperator.opAnd);
  debugPrint((s3![0].type == "typeC").toString());
  // search block by parameter
  List<SBMLSearchParam> sp3 = [SBMLSearchParam(EnumSBMLOperator.equal, "C")];
  List<SBMLBlock>? s4 = UtilSBMLSearch.blockParams(
      b1.getBlockList(),
      "parameter",
      [SBMLSearcher(sp3, EnumSBMLLogicalOperator.opAnd)],
      EnumSBMLLogicalOperator.opAnd);
  debugPrint((s4![0].type == "typeC").toString());
}
