import 'dart:convert';

import 'sbml_block.dart';
import 'sbml_exception.dart';

///
/// Parser of Simple Block Markup Language.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-7-10 13:25:00
///
class SBMLParser {
  // need escape in param field.
  static const paramStart = "(";
  static const paramEnd = ")";
  static const separate = ":";
  static const paramSeparate = ",";
  static const space = " ";
  static const spaceJP = "　";
  static const escape = "\\";

  // escaped
  static const paramStartESC = "\\(";
  static const paramEndESC = "\\)";
  static const separateESC = "\\:";
  static const paramSeparateESC = "\\,";
  static const spaceESC = "\\ ";
  static const spaceJPESC = "\\　";
  static const escapeESC = "\\\\";

  // other
  static const newLineCode = "\n";
  static const commentCode = "//";
  static const escapeCode = "\\";
  static const escapeLine = "(esc)";
  static const empty = "";

  // プラス記号以外でネストしたい場合は以下２つの変更が必要。
  static const indentationCode = "+";
  static final RegExp paramStartRE = RegExp(r'^\+*\(.*$');

  /// (en)Returns a list of the results of parsing SBML.
  /// (ja)SBMLをパースした結果のリストを返します。
  ///
  /// * [src] : SBML text.
  /// * [isGraphMode] : If True, the list of children serials are stored in the parent.
  ///
  /// Returns A list of parsed results.
  ///
  /// Throws [SBMLException] : If the structure is incorrect.
  static List<SBMLBlock> run(String src, {bool isGraphMode = false}) {
    // 改行単位で区切り、コメント行を除去してエレメント行を汎用クラスで返す。
    List<String> splited = const LineSplitter().convert(src);
    List<SBMLBlock> r = [];
    int nowLine = 0;
    int serial = 0;
    // 基底のColのシリアルは-1。
    List<int> nowParentSerial = [-1];
    for (String line in splited) {
      nowLine += 1;
      // コメント行なら無視
      if (line.startsWith(commentCode)) {
        continue;
      }
      // エスケープ行なら直前の要素の最後に改行と内容を追加
      if (line.startsWith(escapeLine)) {
        if (r.isNotEmpty) {
          r.last.content += "\n${_split(line, paramEnd)[1]}";
        } else {
          throw SBMLException(EnumSBMLExceptionType.syntaxException, nowLine);
        }
        continue;
      }
      if (line.startsWith(paramStartRE)) {
        // 前のブロックの終了位置が確定
        if (r.isNotEmpty) {
          r.last.lineEnd = nowLine;
        }
        // パラメータを取得。
        final List<String> prePreParams =
            _split(line, paramStart, targetCharAdd: true);
        // ネストレベルの操作
        final bool isNested = prePreParams[0] != paramStart;
        int nowNestLevel = 0;
        if (isNested) {
          nowNestLevel = prePreParams[0].length;
        }
        final int preNestLevel = r.isNotEmpty ? r.last.nestLevel : 0;
        if (nowNestLevel > preNestLevel) {
          if (nowNestLevel - preNestLevel > 1) {
            throw SBMLException(EnumSBMLExceptionType.levelException, nowLine);
          }
          // ネストレベルが今回から深くなっているならば、前回の要素が親。
          nowParentSerial.add(r.last.serial);
        } else if (nowNestLevel < preNestLevel) {
          // ネストレベルが今回から浅くなっているならば、ネスト位置を適切な階層まで移動。
          for (int j = 0; j < preNestLevel - nowNestLevel; j++) {
            // ネストレベル依存なので最初のシリアルの-1は必ず残る。配列長チェックは不要。
            nowParentSerial.removeLast();
          }
        }
        // パラメータの抽出
        String preParams = isNested ? prePreParams[2] : prePreParams[1];
        List<String> paramsAndContent =
            _split(preParams, paramEnd, targetCharAdd: true);
        if (paramsAndContent.length == 2) {
          // 長さ2の場合は空のコンテンツ配列を追加する。
          paramsAndContent.add("");
        } else if (paramsAndContent.length < 2) {
          throw SBMLException(EnumSBMLExceptionType.syntaxException, nowLine);
        }
        String? type;
        Map<String, String> params = {};
        bool isFirstParam = true;
        for (String p
            in _split(paramsAndContent[0], paramSeparate, isSplitOne: false)) {
          // エスケープされていない半角、および全角スペースを除去。
          p = _replaceAll(p, " ", "");
          p = _replaceAll(p, "　", "");
          if (p == empty) {
            throw SBMLException(EnumSBMLExceptionType.syntaxException, nowLine);
          }
          if (isFirstParam) {
            //　エスケープを外して適用。
            type = _removeEscapeCode(p);
            isFirstParam = false;
          } else {
            List<String> keyValue = _split(p, separate);
            if (keyValue.length < 2) {
              throw SBMLException(
                  EnumSBMLExceptionType.syntaxException, nowLine);
            } else {
              //　エスケープを外して適用。
              params[_removeEscapeCode(keyValue[0])] =
                  _removeEscapeCode(keyValue[1]);
            }
          }
        }
        if (type == null) {
          throw SBMLException(EnumSBMLExceptionType.typeNullException, nowLine);
        }
        // ブロック要素が確定するので要素を生成
        r.add(SBMLBlock(serial, nowParentSerial.last, nowNestLevel, type,
            params, paramsAndContent[2],
            lineStart: nowLine));
        // グラフモードが有効なら後で探索可能にする
        if (isGraphMode) {
          if (nowParentSerial.length > 1) {
            r[nowParentSerial.last].children.add(serial);
          }
        }
        serial += 1;
      } else {
        if (r.isNotEmpty) {
          // コンテンツ文字列の行
          r.last.content += (newLineCode + line);
        }
      }
    }
    // 最後が1行で終わる場合はlineEndをlineStart+1にする。
    if (r.isNotEmpty) {
      r.last.lineEnd ??= r.last.lineStart! + 1;
    }
    return r;
  }

  /// Escape-enabled split. Target character is always contain in return list.
  /// * [targetChar] : The length must be 1.
  /// * [targetCharAdd] : If true, Add target character to return list.
  /// * [isSplitOne] : If true, split only once.
  static List<String> _split(String src, String targetChar,
      {bool targetCharAdd = false, bool isSplitOne = true}) {
    List<String> r = [];
    String buf = "";
    bool isInEscape = false;
    bool splitCompleted = false;
    for (String i in src.split(empty)) {
      if (splitCompleted) {
        buf += i;
        continue;
      }
      // エスケープ文字
      if (i == escapeCode) {
        if (isInEscape) {
          isInEscape = false;
        } else {
          isInEscape = true;
        }
        buf += i;
      } else {
        // エスケープ文字以外の場合
        if (isInEscape) {
          // 前の文字がエスケープの場合はターゲットは分割対象外。
          buf += i;
          isInEscape = false;
        } else {
          // エスケープ中では無い場合
          if (i == targetChar) {
            // 対象がターゲット文字列
            if (buf.isNotEmpty) {
              r.add(buf);
            }
            if (targetCharAdd) {
              r.add(i);
            }
            buf = "";
            if (isSplitOne) {
              splitCompleted = true;
            }
          } else {
            buf += i;
          }
        }
      }
    }
    if (buf.isNotEmpty) {
      r.add(buf);
    }
    return r;
  }

  /// Escape-enabled replaceAll.
  /// * [targetChar] : The length must be 1.
  /// * [replaced] : The replaced character.
  static String _replaceAll(String src, String targetChar, String replaced) {
    List<String> r = [];
    String buf = "";
    bool isInEscape = false;
    for (String i in src.split(empty)) {
      // エスケープ文字
      if (i == escapeCode) {
        if (isInEscape) {
          isInEscape = false;
        } else {
          isInEscape = true;
        }
        buf += i;
      } else {
        // エスケープ文字以外の場合
        if (isInEscape) {
          // 前の文字がエスケープの場合はターゲットは分割対象外。
          buf += i;
          isInEscape = false;
        } else {
          // エスケープ中では無い場合
          if (i == targetChar) {
            // 対象がターゲット文字列
            if (buf.isNotEmpty) {
              r.add(buf);
            }
            r.add(replaced);
            buf = "";
          } else {
            buf += i;
          }
        }
      }
    }
    if (buf.isNotEmpty) {
      r.add(buf);
    }
    return r.join(empty);
  }

  /// Remove escape code.
  static String _removeEscapeCode(String src) {
    String r = "";
    bool isInEscape = false;
    for (String i in src.split(empty)) {
      // エスケープ文字
      if (i == escapeCode) {
        if (isInEscape) {
          isInEscape = false;
          r += i;
        } else {
          isInEscape = true;
        }
      } else {
        // エスケープ文字以外の場合
        isInEscape = false;
        r += i;
      }
    }
    return r;
  }
}
