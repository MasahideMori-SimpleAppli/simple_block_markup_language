enum EnumSpBMLLogicalOperator { opAnd, opOr }

extension EXTEnumSpBMLLogicalOperator on EnumSpBMLLogicalOperator {
  String toStr() {
    return toString().split('.').last;
  }

  static EnumSpBMLLogicalOperator fromStr(String s) {
    if (s == EnumSpBMLLogicalOperator.opAnd.toStr()) {
      return EnumSpBMLLogicalOperator.opAnd;
    } else if (s == EnumSpBMLLogicalOperator.opOr.toStr()) {
      return EnumSpBMLLogicalOperator.opOr;
    } else {
      throw Exception("EnumSpBMLLogicalOperator: Illegal operator.");
    }
  }
}
