import 'package:simple_block_markup_language/enum_sbml_operator.dart';
import 'package:simple_block_markup_language/sbml_exception.dart';

///
/// This class is an SBML search parameter class.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-17 17:17:52
///
class SBMLSearchParam {
  static const String className = 'SBMLSearchParam';
  static const String version = '1';
  EnumSBMLOperator op;
  dynamic compV;

  /// Constructor
  /// * [op] : Compare operator.
  /// * [compV] : The compare value. it is number or String.
  SBMLSearchParam(this.op, this.compV) {
    if (compV is! num && compV is! String) {
      throw SBMLException(EnumSBMLExceptionType.illegalArgException, null);
    }
  }

  SBMLSearchParam deepCopy() {
    return SBMLSearchParam(op, compV);
  }

  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    d['operator'] = op.toStr();
    d['compareValue'] = compV;
    return d;
  }

  static SBMLSearchParam fromDict(Map<String, dynamic> src) {
    return SBMLSearchParam(
        EXTEnumSBMLOperator.fromStr(src['operator']), src['compareValue']);
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
