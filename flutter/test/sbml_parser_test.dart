import 'package:flutter_test/flutter_test.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  test('run SBMLParser test', () {
    const String base =
        "(a)aaa\n+(b,key1:abc,key2:def)bbb\nccc\n(esc)(d)ddd\n+(e)eee\n++(f)fff\n(g)ggg";
    List<SBMLBlock> blocks = SBMLParser.run(base, isGraphMode: true);
    expect(blocks[0].serial, 0);
    expect(blocks[1].serial, 1);
    expect(blocks[2].serial, 2);
    expect(blocks[3].serial, 3);
    expect(blocks[4].serial, 4);
    expect(blocks[0].parentSerial, -1);
    expect(blocks[1].parentSerial, 0);
    expect(blocks[2].parentSerial, 0);
    expect(blocks[3].parentSerial, 2);
    expect(blocks[4].parentSerial, -1);
    expect(blocks[0].nestLevel, 0);
    expect(blocks[1].nestLevel, 1);
    expect(blocks[2].nestLevel, 1);
    expect(blocks[3].nestLevel, 2);
    expect(blocks[4].nestLevel, 0);
    expect(blocks[0].type, "a");
    expect(blocks[1].type, "b");
    expect(blocks[2].type, "e");
    expect(blocks[3].type, "f");
    expect(blocks[4].type, "g");
    expect(blocks[0].params, {});
    expect(blocks[1].params, {"key1": "abc", "key2": "def"});
    expect(blocks[2].params, {});
    expect(blocks[3].params, {});
    expect(blocks[4].params, {});
    expect(blocks[0].content, "aaa");
    expect(blocks[1].content, "bbb\nccc\n(d)ddd");
    expect(blocks[2].content, "eee");
    expect(blocks[3].content, "fff");
    expect(blocks[4].content, "ggg");
    expect(blocks[0].lineStart, 1);
    expect(blocks[1].lineStart, 2);
    expect(blocks[2].lineStart, 5);
    expect(blocks[3].lineStart, 6);
    expect(blocks[4].lineStart, 7);
    expect(blocks[0].lineEnd, 2);
    expect(blocks[1].lineEnd, 5);
    expect(blocks[2].lineEnd, 6);
    expect(blocks[3].lineEnd, 7);
    expect(blocks[4].lineEnd, 8);
    expect(blocks[0].children, [1, 2]);
    expect(blocks[1].children, []);
    expect(blocks[2].children, [3]);
    expect(blocks[3].children, []);
    expect(blocks[4].children, []);
    // エスケープシーケンスのテスト
    const String escaped =
        "(a, escape: es\\\\cape, space: s\\ pace,comma: co\\,mma, colon\\::colon, brackets:brackets\\))aaa";
    List<SBMLBlock> escBlocks = SBMLParser.run(escaped, isGraphMode: true);
    expect(escBlocks[0].params["escape"], "es\\cape");
    expect(escBlocks[0].params["space"], "s pace");
    expect(escBlocks[0].params["comma"], "co,mma");
    expect(escBlocks[0].params["colon:"], "colon");
    expect(escBlocks[0].params["brackets"], "brackets)");
    const String escBlockLine =
        "(a, b:c\\ cc, d:eee)abcdef\n+(f)ghijklmn\n(esc)+(f2)opqrstu\n+(g)vwxyz";
    List<SBMLBlock> escBlockLines =
        SBMLParser.run(escBlockLine, isGraphMode: true);
    expect(escBlockLines.length, 3);
    expect(escBlockLines[0].content, "abcdef");
    expect(escBlockLines[1].content, "ghijklmn\n+(f2)opqrstu");
    expect(escBlockLines[2].content, "vwxyz");
  });
}
