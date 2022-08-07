import 'enum_sbml_logical_operator.dart';
import 'sbml_search_param.dart';

///
/// This class is an SBML search information class.
/// You can easily handle complicated search conditions with this class.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-17 17:27:33
///
class SBMLSearcher {
  final String className = 'SBMLSearcher';
  final String version = '1';
  List<SBMLSearchParam> params;
  EnumSBMLLogicalOperator logicalOp;

  /// Constructor
  /// * [params] : The search parameter list.
  /// * [logicalOp] : Specifies how to logically operate the parameter list.
  SBMLSearcher(this.params, this.logicalOp);

  /// convert dictionary.
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    List<Map<String, dynamic>> mParamList = [];
    for (SBMLSearchParam i in params) {
      mParamList.add(i.toDict());
    }
    d['paramList'] = mParamList;
    d['logicalOperator'] = logicalOp.toStr();
    return d;
  }

  /// convert from dictionary.
  static SBMLSearcher fromDict(Map<String, dynamic> src) {
    List<SBMLSearchParam> mParamList = [];
    for (Map<String, dynamic> i in src['paramList']) {
      mParamList.add(SBMLSearchParam.fromDict(i));
    }
    return SBMLSearcher(
        mParamList, EXTEnumSBMLLogicalOperator.fromStr(src['logicalOperator']));
  }

  /// Calculate.
  ///
  /// * [t]: The target value.
  ///
  /// Returns the following calculation result.
  /// (SBMLSearchParam[0].calc(t) == True) logicalOperator (SBMLSearchParam[1].calc(t) == True) logicalOperator ...
  bool calc(dynamic t) {
    if (logicalOp == EnumSBMLLogicalOperator.opAnd) {
      for (SBMLSearchParam i in params) {
        if (!i.calc(t)) {
          return false;
        }
      }
      return true;
    } else {
      // or
      for (SBMLSearchParam i in params) {
        if (i.calc(t)) {
          return true;
        }
      }
      return false;
    }
  }
}
