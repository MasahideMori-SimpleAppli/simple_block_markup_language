import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  test('run UtilSpBMLLine test', () {
    // LineSplitterと異なる動作であることを確認。
    String text = "\n";
    List<String> splitTextOfLineSplitter = const LineSplitter().convert(text);
    expect(splitTextOfLineSplitter.length, 1);
    expect(splitTextOfLineSplitter[0], "");
    List<String> splitText = UtilSpBMLLine.split(text);
    expect(splitText.length, 2);
    expect(splitText[0], "");
    expect(splitText[1], "");
    String text2 = "Line1\r\nLine2\nLine3\rLine4";
    List<String> splitText2 = UtilSpBMLLine.split(text2);
    expect(splitText2[0], "Line1");
    expect(splitText2[1], "Line2");
    expect(splitText2[2], "Line3");
    expect(splitText2[3], "Line4");
  });
}
