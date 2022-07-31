## Overview
This package contains a working implementation of Simple Block Markup Language (SBML).
SBML is a simple markup language that describes block elements in an easy-to-see format.
Files output in this format have the extension .sbml.

## Usage
### Description method
The basic form is as follows.
```
(type, parameter1:value1, parameter2:value2,...)content
```

The comment line is as follows.
```
// comment text
```

### new line
Start a new line with a normal line feed code.  
Line breaks at the end of the sentence are ignored.
```
(a, b:ccc, d:eee)abcdef
ghijklmn
opqrstu...
```

### Nested structure
Elements with a + mark at the beginning are nested elements.  
Which element is a child element depends on the position of the element and the number of + marks.
There are no nesting symbols or anything like that in the content area.
```
(a, b:ccc, d:eee)abcdef
+(f)ghijklmn
opqrstu
+(g)vwxyz
```
In the example above, elements of (f) and (g) are child elements of elements of (a).

### Escape sequence
Escapes are normally required only within parentheses denoting types and parameters.
To write a + sign, parentheses, commas, backslashes, etc. as parameter values, write one backslash in front.
Note that if you write directly as text in the code instead of reading the file,  
the backslash itself will be you will need one extra to receive the Dart escape.
As an exception, if you want to include a line in the content area that begins with a combination of a + sign and parentheses, write (esc) at the beginning.
```
(a, b:c\\ cc, d:eee)abcdef
+(f)ghijklmn
(esc)+(f2)opqrstu
+(g)vwxyz
```

### Flutter code sample
The add method automatically assigns a serial number that increases by one.
If you want to assign manually, use the set method.
Blocks can also be searched using the included utility.
```dart
import 'package:flutter/material.dart';
import 'package:simple_block_markup_language/enum_sbml_logical_operator.dart';
import 'package:simple_block_markup_language/enum_sbml_operator.dart';
import 'package:simple_block_markup_language/sbml_block.dart';
import 'package:simple_block_markup_language/sbml_builder.dart';
import 'package:simple_block_markup_language/sbml_search_param.dart';
import 'package:simple_block_markup_language/sbml_searcher.dart';
import 'package:simple_block_markup_language/util_sbml_search.dart';

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

## Support
If you need paid support for any reason, please contact my company.  
This package is developed by me personally, but may be supported via the company.  
[SimpleAppli Inc.](https://simpleappli.com/en/index_en.html)

## Format name
Simple Block Markup Language

## Extension
.sbml

## MIME Type (Temporary)
text/x.sbml

## About version control
The C part will be changed at the time of version upgrade.
- Changes such as adding variables, structure change that cause problems when reading previous files.
  - C.X.X
- Adding methods, etc.
  - X.C.X
- Minor changes and bug fixes.
  - X.X.C
If the version is less than 1, there may be major corrections and changes regardless of the above.

## License
This software is released under the MIT License, see LICENSE file.

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.