enum EnumSBMLLogicalOperator { opAnd, opOr }

extension EXTEnumSBMLLogicalOperator on EnumSBMLLogicalOperator {
  String toStr() {
    return toString().split('.').last;
  }

  static EnumSBMLLogicalOperator fromStr(String s) {
    if (s == EnumSBMLLogicalOperator.opAnd.toStr()) {
      return EnumSBMLLogicalOperator.opAnd;
    } else if (s == EnumSBMLLogicalOperator.opOr.toStr()) {
      return EnumSBMLLogicalOperator.opOr;
    } else {
      throw Exception("EnumSBMLLogicalOperator: Illegal operator.");
    }
  }
}
