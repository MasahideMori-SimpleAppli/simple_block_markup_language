///
/// (en)An exception class for SBML.
/// Returns the type and line number of the exception that occurred.
/// (ja)SBMLの例外クラスです。発生した例外の種類と行番号を返します。
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-10 15:03:19
///
class SBMLException implements Exception {
  final EnumSBMLExceptionType type;
  final int? nowLine;
  final String? detail;

  /// Constructor
  /// * [type] : Exception type.
  /// * [nowLine] : Exception occurred line.
  /// * [detail] : Detailed explanation.
  SBMLException(this.type, this.nowLine, {this.detail});

  String getLine() {
    if (nowLine == null) {
      return "";
    } else {
      return "Line:$nowLine,";
    }
  }

  String getDetail() {
    if (detail == null) {
      return "";
    } else {
      return ", Detail:$detail";
    }
  }

  @override
  String toString() {
    return "SBMLException, Type:${type.toStr()}, ${getLine()} ${type.toErrorText()}${getDetail()}";
  }
}

enum EnumSBMLExceptionType {
  typeNullException,
  levelException,
  syntaxException,
  nonExistSerialException,
  illegalCalcException,
  illegalArgException
}

extension EXTEnumSBMLExceptionType on EnumSBMLExceptionType {
  String toStr() {
    return toString().split('.').last;
  }

  String toErrorText() {
    if (this == EnumSBMLExceptionType.typeNullException) {
      return "There is no type.";
    } else if (this == EnumSBMLExceptionType.levelException) {
      return "The number of indent mark is invalid.";
    } else if (this == EnumSBMLExceptionType.syntaxException) {
      return 'Syntax Error.';
    } else if (this == EnumSBMLExceptionType.nonExistSerialException) {
      return 'It is non exist serial.';
    } else if (this == EnumSBMLExceptionType.illegalCalcException) {
      return 'It is illegal calculation.';
    } else if (this == EnumSBMLExceptionType.illegalArgException) {
      return 'It contains invalid arguments.';
    } else {
      return "An unknown exception.";
    }
  }
}
