/// (en) Utilities for line splitting and more.
///
/// (ja) 行の分割などのためのユーティリティです。
class UtilSpBMLLine {
  static final RegExp _regExp = RegExp(r'\r\n?|\n');

  /// (en) It recognizes line break codes of various operating systems and
  /// splits the text on a line break code basis.
  /// This works differently than LineSplitter in that
  /// if there are only line breaks (LF, CR LF, CR),
  /// the resulting array will have two, whereas with LineSplitter
  /// there will only be one.
  ///
  /// (ja) 様々なOSの改行コードを認識し、改行コード単位で分割します。
  /// これは LineSplitter とは動作が異なり、改行 (LF、CR LF、CR) のみがある場合、
  /// 結果の配列は 2 つになります。LineSplitterの場合は1つのみです。
  ///
  /// // Example1 //
  ///
  /// String text = "\n";
  /// List<String> splitTextOfLineSplitter = const LineSplitter().convert(text);
  /// expect(splitTextOfLineSplitter.length, 1);
  /// expect(splitTextOfLineSplitter[0], "");
  /// List<String> splitText = UtilSpBMLLine.split(text);
  /// expect(splitText.length, 2);
  /// expect(splitText[0], "");
  /// expect(splitText[1], "");
  ///
  /// // Example2 //
  ///
  /// String text2 = "Line1\r\nLine2\nLine3\rLine4";
  /// List<String> splitText2 = UtilSpBMLLine.split(text2);
  /// expect(splitText2[0], "Line1");
  /// expect(splitText2[1], "Line2");
  /// expect(splitText2[2], "Line3");
  /// expect(splitText2[3], "Line4");
  static List<String> split(String text) {
    return text.split(_regExp);
  }
}
