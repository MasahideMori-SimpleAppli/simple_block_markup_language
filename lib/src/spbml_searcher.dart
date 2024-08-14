import 'enum_spbml_logical_operator.dart';
import 'spbml_search_param.dart';

///
/// This class is an SpBML search information class.
/// You can easily handle complicated search conditions with this class.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-17 17:27:33
///
class SpBMLSearcher {
  final String className = 'SpBMLSearcher';
  final String version = '1';
  List<SpBMLSearchParam> params;
  EnumSpBMLLogicalOperator logicalOp;

  /// Constructor
  /// * [params] : The search parameter list.
  /// * [logicalOp] : Specifies how to logically operate the parameter list.
  SpBMLSearcher(this.params, this.logicalOp);

  /// convert dictionary.
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = className;
    d['version'] = version;
    List<Map<String, dynamic>> mParamList = [];
    for (SpBMLSearchParam i in params) {
      mParamList.add(i.toDict());
    }
    d['paramList'] = mParamList;
    d['logicalOperator'] = logicalOp.toStr();
    return d;
  }

  /// convert from dictionary.
  static SpBMLSearcher fromDict(Map<String, dynamic> src) {
    List<SpBMLSearchParam> mParamList = [];
    for (Map<String, dynamic> i in src['paramList']) {
      mParamList.add(SpBMLSearchParam.fromDict(i));
    }
    return SpBMLSearcher(mParamList,
        EXTEnumSpBMLLogicalOperator.fromStr(src['logicalOperator']));
  }

  /// Calculate.
  ///
  /// * [t]: The target value.
  ///
  /// Returns the following calculation result.
  /// (SpBMLSearchParam[0].calc(t) == True) logicalOperator (SpBMLSearchParam[1].calc(t) == True) logicalOperator ...
  bool calc(dynamic t) {
    if (logicalOp == EnumSpBMLLogicalOperator.opAnd) {
      for (SpBMLSearchParam i in params) {
        if (!i.calc(t)) {
          return false;
        }
      }
      return true;
    } else {
      // or
      for (SpBMLSearchParam i in params) {
        if (i.calc(t)) {
          return true;
        }
      }
      return false;
    }
  }
}
