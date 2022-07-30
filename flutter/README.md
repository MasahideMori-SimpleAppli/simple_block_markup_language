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

## License
This software is released under the MIT License, see LICENSE file.

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.