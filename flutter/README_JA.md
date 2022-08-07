# simple_block_markup_language

日本語版の解説です。

## 概要
このパッケージには、Simple Block Markup Language (SBML) の実用的な実装が含まれています。
SBMLは、ブロック要素を見やすい形式で記述する単純なマークアップ言語です。
この形式で出力されるファイルの拡張子は .sbml です。
文字エンコーディングは常に UTF-8 を使用します。
改行コードは常に LF (ラインフィード) を使用します。

## 使い方
### 記載方法
基本的な使い方は以下の通りです。
```
(型, パラメータ１:値１, パラメータ２:値２,...)コンテンツテキスト
```

コメントの記載は以下のようにします。
```
// コメントテキスト（プログラムに呼び飛ばして欲しい部分で、メモなどを書く）
```

### 改行について
通常の改行コードで改行します。
文末の改行は無視されます。
```
(a, b:ccc, d:eee)abcdef
ghijklmn
opqrstu...
```

### 入れ子の構造について
先頭に + マーク（ネスト記号）が付いている要素は、入れ子になった要素です。
どの要素が子要素になるかは、要素の位置と + マークの数によって異なります。
コンテンツ領域には、ネスト記号などはありません。
```
(a, b:ccc, d:eee)abcdef
+(f)ghijklmn
opqrstu
+(g)vwxyz
```
上記の例では、(f) と (g) の要素は (a) の要素の子要素です。

### エスケープシーケンス
エスケープは通常、型とパラメーターを記載している括弧内でのみ必要です。
+記号、括弧、コンマ、バックスラッシュなどをパラメーター値として記述する場合は、バックスラッシュを 1 つ前に記述します。
ファイルを読み取るのではなく、Dart コードにString変数として直接書き込む場合は、
バックスラッシュは、Dart 言語上でのエスケープが必要なためもう 1 つ必要になります。
処理の例外として、コンテンツ領域に + 記号と括弧の組み合わせで始まる行を含めたい場合は、先頭に (esc) を記述します。
型、パラメータ キー、およびパラメータ値には改行を含めてはなりません。注意してください。
```
(a, b:c\\ cc, d:eee)abcdef
+(f)ghijklmn
(esc)+(f2)opqrstu
+(g)vwxyz
```

### 予約語
型について、escとrootは予約されているため、利用できません。

### Flutter サンプルコード
add メソッドは、1 ずつ増加するシリアル番号を自動的に割り当てます。
手動で割り当てる場合は、set メソッドを使用します。
付属のユーティリティを使用してブロックを検索することもできます。
```dart
import 'package:flutter/material.dart';
import 'package:simple_block_markup_language/simple_block_markup_language.dart';

void main() {
  // create block
  SBMLBuilder b1 = SBMLBuilder();
  b1.add("typeA", {"parameter": "A"}, "Content Text A");
  b1.add("typeB", {"parameter": "B"}, "Content Text B");
  b1.add("typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
  SBMLBuilder b2 = SBMLBuilder();
  b2.set(0, "typeA", {"parameter": "A"}, "Content Text A");
  b2.set(1, "typeB", {"parameter": "B"}, "Content Text B");
  b2.set(2, "typeC", {"parameter": "C"}, "Content Text C", parentSerial: 1);
  debugPrint(b1.build());
  debugPrint((b1.build() == b2.build()).toString());
  // search block by type.
  List<SBMLBlock>? s1 = UtilSBMLSearch.blockType(b1.getBlockList(), ["typeC"]);
  debugPrint((s1![0].type == "typeC").toString());
  // search block by nest level.
  List<SBMLSearchParam> sp1 = [SBMLSearchParam(EnumSBMLOperator.equal, 1)];
  List<SBMLBlock>? s2 = UtilSBMLSearch.blockNestLevel(
          b1.getBlockList(),
          [SBMLSearcher(sp1, EnumSBMLLogicalOperator.opAnd)],
          EnumSBMLLogicalOperator.opAnd);
  debugPrint((s2![0].type == "typeC").toString());
  // search block by content
  List<SBMLSearchParam> sp2 = [
    SBMLSearchParam(EnumSBMLOperator.equal, "Content Text C")
  ];
  List<SBMLBlock>? s3 = UtilSBMLSearch.blockContent(
          b1.getBlockList(),
          [SBMLSearcher(sp2, EnumSBMLLogicalOperator.opAnd)],
          EnumSBMLLogicalOperator.opAnd);
  debugPrint((s3![0].type == "typeC").toString());
  // search block by parameter
  List<SBMLSearchParam> sp3 = [SBMLSearchParam(EnumSBMLOperator.equal, "C")];
  List<SBMLBlock>? s4 = UtilSBMLSearch.blockParams(
          b1.getBlockList(),
          "parameter",
          [SBMLSearcher(sp3, EnumSBMLLogicalOperator.opAnd)],
          EnumSBMLLogicalOperator.opAnd);
  debugPrint((s4![0].type == "typeC").toString());
}
```

## サポート
もし何らかの理由で有償のサポートが必要な場合は私の会社に問い合わせてください。  
このパッケージは私が個人で開発していますが、会社経由でサポートできる場合があります。  
[SimpleAppli Inc.](https://simpleappli.com/en/index_en.html)

## フォーマット名
Simple Block Markup Language

## 拡張子
.sbml

## MIME Type ( 仮 )
text/x.sbml

## バージョン管理について
それぞれ、Cの部分が変更されます。
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
  - C.X.X
- メソッドの追加など
  - X.C.X
- 軽微な変更やバグ修正
  - X.X.C

バージョンが1未満の場合、上記に関わらず大幅な修正・変更がある場合があります。

## ライセンス
このソフトウェアはMITライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

## 著作権表示
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.