import 'package:flutter/material.dart';

import 'spbml_exception.dart';

enum EnumSpBMLOperator {
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

extension EXTEnumSpBMLOperator on EnumSpBMLOperator {
  String toStr() {
    return toString().split('.').last;
  }

  static EnumSpBMLOperator fromStr(String s) {
    if (s == EnumSpBMLOperator.under.toStr()) {
      return EnumSpBMLOperator.under;
    } else if (s == EnumSpBMLOperator.underOrEqual.toStr()) {
      return EnumSpBMLOperator.underOrEqual;
    } else if (s == EnumSpBMLOperator.overOrEqual.toStr()) {
      return EnumSpBMLOperator.overOrEqual;
    } else if (s == EnumSpBMLOperator.over.toStr()) {
      return EnumSpBMLOperator.over;
    } else if (s == EnumSpBMLOperator.equal.toStr()) {
      return EnumSpBMLOperator.equal;
    } else if (s == EnumSpBMLOperator.notEqual.toStr()) {
      return EnumSpBMLOperator.notEqual;
    } else if (s == EnumSpBMLOperator.contain.toStr()) {
      return EnumSpBMLOperator.contain;
    } else if (s == EnumSpBMLOperator.startWith.toStr()) {
      return EnumSpBMLOperator.startWith;
    } else if (s == EnumSpBMLOperator.endWith.toStr()) {
      return EnumSpBMLOperator.endWith;
    } else if (s == EnumSpBMLOperator.regularExpressions.toStr()) {
      return EnumSpBMLOperator.regularExpressions;
    } else {
      throw Exception("EnumSpBMLOperator: Illegal operator.");
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
      if (this == EnumSpBMLOperator.under) {
        return _convNum(t) < _convNum(comp);
      } else if (this == EnumSpBMLOperator.underOrEqual) {
        return _convNum(t) <= _convNum(comp);
      } else if (this == EnumSpBMLOperator.overOrEqual) {
        return _convNum(t) >= _convNum(comp);
      } else if (this == EnumSpBMLOperator.over) {
        return _convNum(t) > _convNum(comp);
      } else if (this == EnumSpBMLOperator.equal) {
        // The reason this is necessary is that
        // there is no distinction between strings and numbers in SpBML.
        if (comp is num) {
          return _convNum(t) == _convNum(comp);
        } else {
          return t == comp;
        }
      } else if (this == EnumSpBMLOperator.notEqual) {
        // The reason this is necessary is that
        // there is no distinction between strings and numbers in SpBML.
        if (comp is num) {
          return _convNum(t) != _convNum(comp);
        } else {
          return t != comp;
        }
      } else if (this == EnumSpBMLOperator.contain) {
        return _convStr(t).contains(_convStr(comp));
      } else if (this == EnumSpBMLOperator.startWith) {
        return _convStr(t).startsWith(_convStr(comp));
      } else if (this == EnumSpBMLOperator.endWith) {
        return _convStr(t).endsWith(_convStr(comp));
      } else {
        // EnumSpBMLOperator.regularExpressions
        final RegExp re = RegExp(_convStr(comp));
        return re.hasMatch(t);
      }
    } catch (e) {
      debugPrint(
          "${EnumSpBMLExceptionType.illegalCalcException.toErrorText()} $e");
      return false;
    }
  }
}
