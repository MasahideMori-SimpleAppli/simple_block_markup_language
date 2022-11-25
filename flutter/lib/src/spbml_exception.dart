///
/// (en)An exception class for SpBML.
/// Returns the type and line number of the exception that occurred.
/// (ja)SpBMLの例外クラスです。発生した例外の種類と行番号を返します。
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-10 15:03:19
///
class SpBMLException implements Exception {
  final EnumSpBMLExceptionType type;
  final int? nowLine;
  final String? detail;

  /// Constructor
  /// * [type] : Exception type.
  /// * [nowLine] : Exception occurred line.
  /// * [detail] : Detailed explanation.
  SpBMLException(this.type, this.nowLine, {this.detail});

  String _getLine() {
    if (nowLine == null) {
      return "";
    } else {
      return "Line:$nowLine,";
    }
  }

  String _getDetail() {
    if (detail == null) {
      return "";
    } else {
      return ", Detail:$detail";
    }
  }

  @override
  String toString() {
    return "SpBMLException, Type:${type.toStr()}, ${_getLine()} ${type.toErrorText()}${_getDetail()}";
  }
}

enum EnumSpBMLExceptionType {
  typeNullException,
  levelException,
  syntaxException,
  nonExistSerialException,
  illegalCalcException,
  illegalArgException
}

extension EXTEnumSpBMLExceptionType on EnumSpBMLExceptionType {
  String toStr() {
    return toString().split('.').last;
  }

  String toErrorText() {
    if (this == EnumSpBMLExceptionType.typeNullException) {
      return "There is no type.";
    } else if (this == EnumSpBMLExceptionType.levelException) {
      return "The number of indent mark is invalid.";
    } else if (this == EnumSpBMLExceptionType.syntaxException) {
      return 'Syntax Error.';
    } else if (this == EnumSpBMLExceptionType.nonExistSerialException) {
      return 'It is non exist serial.';
    } else if (this == EnumSpBMLExceptionType.illegalCalcException) {
      return 'It is illegal calculation.';
    } else if (this == EnumSpBMLExceptionType.illegalArgException) {
      return 'It contains invalid arguments.';
    } else {
      return "An unknown exception.";
    }
  }
}
