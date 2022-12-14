import 'enum_spbml_logical_operator.dart';
import 'spbml_block.dart';
import 'spbml_exception.dart';
import 'spbml_searcher.dart';

///
/// A utility for searching in SpBML data.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-17 20:28:59
///
class UtilSpBMLSearch {
  /// argument check
  ///
  /// return endCount.
  static int _argCheck(int startNum, int endNum) {
    if (endNum < startNum) {
      throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
          detail: "endNum >= startNum required.");
    } else if (startNum <= 0) {
      throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
          detail: "startNum >= 1 required.");
    } else {
      return endNum - startNum + 1;
    }
  }

  /// Return blocks of same block type.
  ///
  /// * [target] : The search target. e.g. get from spbml_builder getUnderAllBlocks function.
  /// * [targetTypes] : The target types. All types are searched by or condition.
  /// * [startNum] : The start point of search cursor. this is equal 1 or over.
  /// * [endNum] : The end point of search.
  /// If null, this value will be initialized as target.length.
  /// e.g. If startNum = 1, endNum = 1. return list.length = 1.
  /// If startNum = 1, endNum = 2. return list.length = 2.
  ///
  /// Returns the first one searched. If not found, it returns null.
  static List<SpBMLBlock>? blockType(
      List<SpBMLBlock> target, List<String> targetTypes,
      {int startNum = 1, int? endNum}) {
    List<SpBMLBlock> r = [];
    final int endCount = _argCheck(startNum, endNum ?? target.length);
    int nowCount = 0;
    for (SpBMLBlock i in target) {
      if (targetTypes.contains(i.type)) {
        nowCount += 1;
        if (nowCount >= startNum) {
          r.add(i);
          if (nowCount >= endCount) {
            break;
          }
        }
      }
    }
    return r.isEmpty ? null : r;
  }

  /// all matching test.
  static bool _checkNest(SpBMLBlock t, List<SpBMLSearcher> searcher,
      EnumSpBMLLogicalOperator logicalOp) {
    if (logicalOp == EnumSpBMLLogicalOperator.opAnd) {
      for (SpBMLSearcher i in searcher) {
        if (!i.calc(t.nestLevel)) {
          return false;
        }
      }
      return true;
    } else {
      // or
      for (SpBMLSearcher i in searcher) {
        if (i.calc(t.nestLevel)) {
          return true;
        }
      }
      return false;
    }
  }

  /// all matching test.
  static bool _checkContent(SpBMLBlock t, List<SpBMLSearcher> searcher,
      EnumSpBMLLogicalOperator logicalOp) {
    if (logicalOp == EnumSpBMLLogicalOperator.opAnd) {
      for (SpBMLSearcher i in searcher) {
        if (!i.calc(t.content)) {
          return false;
        }
      }
      return true;
    } else {
      // or
      for (SpBMLSearcher i in searcher) {
        if (i.calc(t.content)) {
          return true;
        }
      }
      return false;
    }
  }

  /// all matching test.
  static bool _checkParam(SpBMLBlock t, String paramKey,
      List<SpBMLSearcher> searcher, EnumSpBMLLogicalOperator logicalOp) {
    if (!t.params.keys.contains(paramKey)) {
      return false;
    }
    if (logicalOp == EnumSpBMLLogicalOperator.opAnd) {
      for (SpBMLSearcher i in searcher) {
        if (!i.calc(t.params[paramKey])) {
          return false;
        }
      }
      return true;
    } else {
      // or
      for (SpBMLSearcher i in searcher) {
        if (i.calc(t.params[paramKey])) {
          return true;
        }
      }
      return false;
    }
  }

  /// Returns the block searched at the nested level.
  ///
  /// * [target] : The search target. e.g. get from spbml_builder getUnderAllBlocks function.
  /// If you want to search only the part, adjust list length by subList().
  /// * [searcher] : The Searcher object list.
  /// * [logicalOp] : Search condition of "and" or "or" for [searcher] list.
  /// * [startNum] : The start point of search cursor. this is equal 1 or over.
  /// * [endNum] : The end point of search.
  /// If null, this value will be initialized as target.length.
  /// e.g. If startNum = 1, endNum = 1. return list.length = 1.
  /// If startNum = 1, endNum = 2. return list.length = 2.
  ///
  /// Returns the first one searched. If not found, it returns null.
  static List<SpBMLBlock>? blockNestLevel(List<SpBMLBlock> target,
      List<SpBMLSearcher> searcher, EnumSpBMLLogicalOperator logicalOp,
      {int startNum = 1, int? endNum}) {
    List<SpBMLBlock> r = [];
    final int endCount = _argCheck(startNum, endNum ?? target.length);
    int nowCount = 0;
    for (SpBMLBlock i in target) {
      if (_checkNest(i, searcher, logicalOp)) {
        nowCount += 1;
        if (nowCount >= startNum) {
          r.add(i);
          if (nowCount >= endCount) {
            break;
          }
        }
      }
    }
    return r.isEmpty ? null : r;
  }

  /// Returns the block searched at the content.
  ///
  /// * [target] : The search target. e.g. get from spbml_builder getUnderAllBlocks function.
  /// If you want to search only the part, adjust list length by subList().
  /// * [searcher] : The Searcher object list.
  /// * [logicalOp] : Search condition of "and" or "or" for [searcher] list.
  /// * [startNum] : The start point of search cursor. this is equal 1 or over.
  /// * [endNum] : The end point of search.
  /// If null, this value will be initialized as target.length.
  /// e.g. If startNum = 1, endNum = 1. return list.length = 1.
  /// If startNum = 1, endNum = 2. return list.length = 2.
  ///
  /// Returns the first one searched. If not found, it returns null.
  static List<SpBMLBlock>? blockContent(List<SpBMLBlock> target,
      List<SpBMLSearcher> searcher, EnumSpBMLLogicalOperator logicalOp,
      {int startNum = 1, int? endNum}) {
    List<SpBMLBlock> r = [];
    final int endCount = _argCheck(startNum, endNum ?? target.length);
    int nowCount = 0;
    for (SpBMLBlock i in target) {
      if (_checkContent(i, searcher, logicalOp)) {
        nowCount += 1;
        if (nowCount >= startNum) {
          r.add(i);
          if (nowCount >= endCount) {
            break;
          }
        }
      }
    }
    return r.isEmpty ? null : r;
  }

  /// Returns the block searched at the parameter.
  ///
  /// * [target] : The search target. e.g. get from spbml_builder getUnderAllBlocks function.
  /// If you want to search only the part, adjust list length by subList().
  /// * [paramKey] : Target parameter key.
  /// * [searcher] : The Searcher object list.
  /// * [logicalOp] : Search condition of "and" or "or" for [searcher] list.
  /// * [startNum] : The start point of search cursor. this is equal 1 or over.
  /// * [endNum] : The end point of search.
  /// If null, this value will be initialized as target.length.
  /// e.g. If startNum = 1, endNum = 1. return list.length = 1.
  /// If startNum = 1, endNum = 2. return list.length = 2.
  ///
  /// Returns the first one searched. If not found, it returns null.
  static List<SpBMLBlock>? blockParams(List<SpBMLBlock> target, String paramKey,
      List<SpBMLSearcher> searcher, EnumSpBMLLogicalOperator logicalOp,
      {int startNum = 1, int? endNum}) {
    List<SpBMLBlock> r = [];
    final int endCount = _argCheck(startNum, endNum ?? target.length);
    int nowCount = 0;
    for (SpBMLBlock i in target) {
      if (_checkParam(i, paramKey, searcher, logicalOp)) {
        nowCount += 1;
        if (nowCount >= startNum) {
          r.add(i);
          if (nowCount >= endCount) {
            break;
          }
        }
      }
    }
    return r.isEmpty ? null : r;
  }
}
