import 'enum_spbml_operator.dart';
import 'spbml_exception.dart';

///
/// This class is an SpBML search parameter class.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-17 17:17:52
///
class SpBMLSearchParam {
  static const String className = 'SpBMLSearchParam';
  static const String version = '1';
  EnumSpBMLOperator op;
  dynamic compV;

  /// Constructor
  /// * [op] : Compare operator.
  /// * [compV] : The compare value. it is number or String.
  SpBMLSearchParam(this.op, this.compV) {
    if (compV is! num && compV is! String) {
      throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null);
    }
  }

  SpBMLSearchParam deepCopy() {
    return SpBMLSearchParam(op, compV);
  }

  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    d['operator'] = op.toStr();
    d['compareValue'] = compV;
    return d;
  }

  static SpBMLSearchParam fromDict(Map<String, dynamic> src) {
    return SpBMLSearchParam(
        EXTEnumSpBMLOperator.fromStr(src['operator']), src['compareValue']);
  }

  /// Calculate.
  ///
  /// * [t]: The target value.
  ///
  /// Returns the following calculation result.
  /// t operator compareValue == True
  bool calc(dynamic t) {
    return op.calc(t, compV);
  }
}
