import 'dart:convert';

import 'spbml_parser.dart';

///
/// Block of Simple Block Markup Language.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-7-10 12:57:46
///
class SpBMLBlock {
  final int serial;
  final int parentSerial;
  final int nestLevel;
  final String type;
  final Map<String, String> params;
  String content;

  // 行番号は変換途中で確定する。
  int? lineStart;
  int? lineEnd;

  // グラフの探索をさせたい時に使う子のシリアルのリスト。
  List<int> children;

  /// * [serial] : The block serial number. The value is 0 or over.
  /// This value is not permanent as it is automatically set in the order
  /// in which it was parsed.
  /// Note that this number is independent of the order of the blocks
  /// in the text.
  /// * [parentSerial] : The parent block serial number.
  /// If parent is root, this is -1. If root, this is -2.
  /// * [nestLevel] : The block nest level. If root, this is -1.
  /// * [type] : The block type.
  /// The name that root and esc cannot be defined because they are reserved.
  /// * [params] : Block parameter.
  /// * [content] : The block content.
  /// * [lineStart] : Line number of block start position.
  /// This is a parameter for the parser and is usually not manipulated.
  /// * [lineEnd] : line number of block end position.
  /// This is a parameter for the parser and is usually not manipulated.
  /// The line length == lineEnd - lineStart.
  /// LineEnd == content line number last + 1.
  /// * [children] : This is a list of child serial numbers.
  /// This is usually used when searching in the builder.
  /// The order of the child blocks is as shown in this list.
  SpBMLBlock(this.serial, this.parentSerial, this.nestLevel, this.type,
      this.params, this.content,
      {this.lineStart, this.lineEnd, List<int>? children})
      : children = children ?? [];

  /// deep copy
  SpBMLBlock deepCopy() {
    return SpBMLBlock(
        serial, parentSerial, nestLevel, type, {...params}, content,
        lineStart: lineStart, lineEnd: lineEnd, children: [...children]);
  }

  /// copy with override parameters.
  SpBMLBlock copyWith(int? lineStart, int? lineEnd,
      {int? serial,
      int? parentSerial,
      int? nestLevel,
      String? type,
      Map<String, String>? params,
      String? content,
      List<int>? children}) {
    return SpBMLBlock(
        serial ?? this.serial,
        parentSerial ?? this.parentSerial,
        nestLevel ?? this.nestLevel,
        type ?? this.type,
        params ?? {...this.params},
        content ?? this.content,
        lineStart: lineStart,
        lineEnd: lineEnd,
        children: children ?? [...this.children]);
  }

  /// to Map object
  Map<String, dynamic> toDict() {
    return {
      "serial": serial,
      "parentSerial": parentSerial,
      "nestLevel": nestLevel,
      "type": type,
      "params": params,
      "content": content,
      "lineStart": lineStart,
      "lineEnd": lineEnd,
      "children": children
    };
  }

  /// get nest level code text.
  String _getNestCode() {
    String r = "";
    for (int i = 0; i < nestLevel; i++) {
      r += SpBMLParser.indentationCode;
    }
    return r;
  }

  /// return escaped text.
  String _escape(String s) {
    return s
        .replaceAll(SpBMLParser.escape, SpBMLParser.escapeESC)
        .replaceAll(SpBMLParser.paramStart, SpBMLParser.paramStartESC)
        .replaceAll(SpBMLParser.paramEnd, SpBMLParser.paramEndESC)
        .replaceAll(SpBMLParser.separate, SpBMLParser.separateESC)
        .replaceAll(SpBMLParser.paramSeparate, SpBMLParser.paramSeparateESC)
        .replaceAll(SpBMLParser.space, SpBMLParser.spaceESC)
        .replaceAll(SpBMLParser.spaceJP, SpBMLParser.spaceJPESC);
  }

  /// Convert to SpBML.
  List<String> toSpBML() {
    List<String> r = [];
    // 最初のパラメータ込みの行を作成する。
    List<String> contentLines = const LineSplitter().convert(content);
    String firstLine = _getNestCode() + SpBMLParser.paramStart + type;
    for (String i in params.keys) {
      firstLine += SpBMLParser.paramSeparate;
      firstLine += _escape(i);
      firstLine += SpBMLParser.separate;
      firstLine += _escape(params[i]!);
    }
    firstLine += SpBMLParser.paramEnd;
    if (contentLines.isNotEmpty) {
      firstLine += contentLines.removeAt(0);
    }
    r.add(firstLine);
    // コンテンツ行がまだあれば追加。
    // ここでは、条件によってはエスケープが必要になる。
    for (String i in contentLines) {
      if (i.startsWith(SpBMLParser.paramStartRE)) {
        r.add(SpBMLParser.escapeLine + i);
      } else {
        r.add(i);
      }
    }
    return r;
  }

  /// (en) Returns true if other block has the same parameters as this block.
  /// This method is limited to comparing only the params.
  ///
  /// (ja) 他のブロックがこのブロックと同一のパラメータを持っている場合はtrueを返します。
  /// このメソッドで比較されるのはparamsのみに限定されます。
  bool haveSameParams(SpBMLBlock other) {
    if (params.length != other.params.length) {
      return false;
    }
    for (String key in params.keys) {
      if (!other.params.containsKey(key) || params[key] != other.params[key]) {
        return false;
      }
    }
    return true;
  }
}
