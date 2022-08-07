import 'package:flutter/material.dart';

import 'sbml_exception.dart';

enum EnumSBMLOperator {
  // <
  under,
  // <=
  underOrEqual,
  // >=
  overOrEqual,
  // >
  over,
  // ==
  equal,
  // !=
  notEqual,
  // If contain text, return true.
  contain,
  // text search
  startWith,
  endWith,
  // Regular expressions
  regularExpressions,
}

extension EXTEnumSBMLOperator on EnumSBMLOperator {
  String toStr() {
    return toString().split('.').last;
  }

  static EnumSBMLOperator fromStr(String s) {
    if (s == EnumSBMLOperator.under.toStr()) {
      return EnumSBMLOperator.under;
    } else if (s == EnumSBMLOperator.underOrEqual.toStr()) {
      return EnumSBMLOperator.underOrEqual;
    } else if (s == EnumSBMLOperator.overOrEqual.toStr()) {
      return EnumSBMLOperator.overOrEqual;
    } else if (s == EnumSBMLOperator.over.toStr()) {
      return EnumSBMLOperator.over;
    } else if (s == EnumSBMLOperator.equal.toStr()) {
      return EnumSBMLOperator.equal;
    } else if (s == EnumSBMLOperator.notEqual.toStr()) {
      return EnumSBMLOperator.notEqual;
    } else if (s == EnumSBMLOperator.contain.toStr()) {
      return EnumSBMLOperator.contain;
    } else if (s == EnumSBMLOperator.startWith.toStr()) {
      return EnumSBMLOperator.startWith;
    } else if (s == EnumSBMLOperator.endWith.toStr()) {
      return EnumSBMLOperator.endWith;
    } else if (s == EnumSBMLOperator.regularExpressions.toStr()) {
      return EnumSBMLOperator.regularExpressions;
    } else {
      throw Exception("EnumSBMLOperator: Illegal operator.");
    }
  }

  /// convert number.
  static num _convNum(dynamic v) {
    if (v is num) {
      return v;
    } else {
      return num.parse(v.toString());
    }
  }

  /// convert String.
  static String _convStr(dynamic v) {
    if (v is String) {
      return v;
    } else {
      return v.toString();
    }
  }

  /// calculation
  /// If throw convert error, return false.
  bool calc(dynamic t, dynamic comp) {
    try {
      if (this == EnumSBMLOperator.under) {
        return _convNum(t) < _convNum(comp);
      } else if (this == EnumSBMLOperator.underOrEqual) {
        return _convNum(t) <= _convNum(comp);
      } else if (this == EnumSBMLOperator.overOrEqual) {
        return _convNum(t) >= _convNum(comp);
      } else if (this == EnumSBMLOperator.over) {
        return _convNum(t) > _convNum(comp);
      } else if (this == EnumSBMLOperator.equal) {
        if (comp is num) {
          return _convNum(t) == _convNum(comp);
        } else {
          return t == comp;
        }
      } else if (this == EnumSBMLOperator.notEqual) {
        if (comp is num) {
          return _convNum(t) != _convNum(comp);
        } else {
          return t != comp;
        }
      } else if (this == EnumSBMLOperator.contain) {
        return _convStr(t).contains(_convStr(comp));
      } else if (this == EnumSBMLOperator.startWith) {
        return _convStr(t).startsWith(_convStr(comp));
      } else if (this == EnumSBMLOperator.endWith) {
        return _convStr(t).endsWith(_convStr(comp));
      } else {
        // EnumSBMLOperator.regularExpressions
        final RegExp re = RegExp(_convStr(comp));
        return re.hasMatch(t);
      }
    } catch (e) {
      debugPrint(
          "${EnumSBMLExceptionType.illegalCalcException.toErrorText()} $e");
      return false;
    }
  }
}
