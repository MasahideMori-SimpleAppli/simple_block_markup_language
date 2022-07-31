import 'package:simple_block_markup_language/sbml_block.dart';
import 'package:simple_block_markup_language/sbml_exception.dart';
import 'package:simple_block_markup_language/sbml_parser.dart';

///
/// This class is for building and operating SBML.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-16 17:47:57
///
class SBMLBuilder {
  // ブロック構造のデフォルト値
  final SBMLBlock rootBlock = SBMLBlock(_baseSerial, -2, -1, "root", {}, "");

  // 保持しているブロック。キーがブロックシリアル、値がブロックの内容クラス。
  late Map<int, SBMLBlock> _blockMap;

  // 基底のシリアル
  static const _baseSerial = -1;

  // これまでに設定されたシリアルの最大値のデフォルト値。
  static const _defMaxSerial = -1;

  // これまでに設定されたシリアルの最大値。
  int _maxSerial = _defMaxSerial;

  /// Constructor
  SBMLBuilder() {
    _blockMap = {-1: rootBlock.deepCopy()};
  }

  /// Clear blocks.
  void clear() {
    _blockMap = {-1: rootBlock.deepCopy()};
    _maxSerial = _defMaxSerial;
  }

  /// Add block.
  ///
  /// * [type] : The block type.
  /// * [params] : Block parameter.
  /// * [content] : The block content.
  /// * [parentSerial] : The parent block serial number.
  /// If parent is root, this is -1. This value must be -1 or greater.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  void add(String type, Map<String, String> params, String content,
      {int parentSerial = -1}) {
    if (parentSerial < -1) {
      throw SBMLException(EnumSBMLExceptionType.illegalArgException, null,
          detail: "The parentSerial must be -1 or greater");
    }
    if (_blockMap.containsKey(parentSerial)) {
      final int nowSerial = _maxSerial + 1;
      _maxSerial = nowSerial;
      final SBMLBlock parent = _blockMap[parentSerial]!;
      final SBMLBlock child = SBMLBlock(
          nowSerial, parentSerial, parent.nestLevel + 1, type, params, content);
      parent.children.add(nowSerial);
      _blockMap[nowSerial] = child;
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Set block.
  ///
  /// * [serial] : This block serial. Must be 0 or greater.
  /// * [type] : The block type.
  /// * [params] : Block parameter.
  /// * [content] : The block content.
  /// * [parentSerial] : The parent block serial number.
  /// If parent is root, this is -1.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  void set(int serial, String type, Map<String, String> params, String content,
      {int parentSerial = -1}) {
    if (serial < 0) {
      throw SBMLException(EnumSBMLExceptionType.illegalArgException, null,
          detail: "The serial must be 0 or greater");
    }
    if (parentSerial < -1) {
      throw SBMLException(EnumSBMLExceptionType.illegalArgException, null,
          detail: "The parentSerial must be -1 or greater");
    }
    if (_blockMap.containsKey(parentSerial)) {
      if (_maxSerial < serial) {
        _maxSerial = serial;
      }
      final SBMLBlock parent = _blockMap[parentSerial]!;
      final SBMLBlock child = SBMLBlock(
          serial, parentSerial, parent.nestLevel + 1, type, params, content);
      parent.children.add(serial);
      _blockMap[serial] = child;
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Reset target nest revel.
  /// It should be noted that the nesting level of the child does not change.
  void _resetNestLevel(SBMLBlock target) {
    if (_blockMap.containsKey(target.parentSerial)) {
      SBMLBlock tp = _blockMap[target.parentSerial]!;
      _blockMap[target.serial] =
          target.copyWith(null, null, nestLevel: tp.nestLevel + 1);
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Reinsert blocks. This should be called after the remove method call.
  /// The block nesting level is reconstructed with under the parent block.
  /// The first block parent serial will change under the new parent block.
  ///
  /// * [parentSerial] : The parent block serial number. If parent is root, this is -1.
  /// * [blocks] : The SBMLBlocks get from getUnderAllBlocks. this method is not change block serials.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  void reinsert(int parentSerial, List<SBMLBlock> blocks) {
    if (blocks.isEmpty) {
      return;
    }
    if (_blockMap.containsKey(parentSerial)) {
      SBMLBlock parent = _blockMap[parentSerial]!;
      final int parentNestLevel = parent.nestLevel;
      List<SBMLBlock> blocksCopy = [...blocks];
      // override parent serial.
      SBMLBlock firstBlock = blocksCopy.removeAt(0).copyWith(null, null,
          parentSerial: parentSerial, nestLevel: parentNestLevel + 1);
      blocksCopy.insert(0, firstBlock);
      parent.children.add(blocksCopy[0].serial);
      for (SBMLBlock i in blocksCopy) {
        _resetNestLevel(i);
      }
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// internal remove. this is not remove target serial in parent children.
  void _remove(int serial) {
    if (_blockMap.containsKey(serial)) {
      SBMLBlock t = _blockMap[serial]!;
      for (int i in [...t.children]) {
        // 再帰処理
        _remove(i);
      }
      _blockMap.remove(serial);
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Remove the block. The lower blocks are deleted together.
  ///
  /// * [serial] : The target block serial.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  void remove(int serial) {
    if (serial == _baseSerial) {
      // ここはクリアにしないと正しく初期化されないので注意。
      clear();
    } else {
      SBMLBlock t = _blockMap[serial]!;
      if (_blockMap.containsKey(t.parentSerial)) {
        SBMLBlock p = _blockMap[t.parentSerial]!;
        p.children.remove(serial);
      } else {
        throw SBMLException(
            EnumSBMLExceptionType.nonExistSerialException, null);
      }
      _remove(serial);
    }
  }

  /// Remove and return the removed all blocks.
  ///
  /// * [serial] : The target block serial.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  List<SBMLBlock> pop(int serial) {
    List<SBMLBlock> r = getUnderAllBlocks(serial);
    remove(serial);
    return r;
  }

  /// Get block that have a target serial.
  ///
  /// * [serial] : The target block serial.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  SBMLBlock getBlock(int serial) {
    if (_blockMap.containsKey(serial)) {
      return _blockMap[serial]!;
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Exchange block positions.
  ///
  /// * [serialA] : The target block serial.
  /// * [serialB] : The target block serial.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  void exchangePositions(int serialA, int serialB) {
    if (_blockMap.containsKey(serialA) && _blockMap.containsKey(serialB)) {
      final SBMLBlock blockA = _blockMap[serialA]!;
      final SBMLBlock blockB = _blockMap[serialB]!;
      //　親ビューが同じかどうかで処理が変化する。
      if (blockA.parentSerial == blockB.parentSerial) {
        if (_blockMap.containsKey(blockA.parentSerial)) {
          final List<int> order = _blockMap[blockA.parentSerial]!.children;
          final int indexA = order.indexOf(blockA.serial);
          final int indexB = order.indexOf(blockB.serial);
          order.removeAt(indexA);
          order.insert(indexA, blockB.serial);
          order.removeAt(indexB);
          order.insert(indexB, blockA.serial);
          // ネストレベルは変化しない。
        } else {
          throw SBMLException(
              EnumSBMLExceptionType.nonExistSerialException, null,
              detail: "The parent serial not exist.");
        }
      } else {
        if (_blockMap.containsKey(blockA.parentSerial) &&
            _blockMap.containsKey(blockB.parentSerial)) {
          final SBMLBlock aParent = _blockMap[blockA.parentSerial]!;
          final SBMLBlock bParent = _blockMap[blockB.parentSerial]!;
          final List<int> orderA = aParent.children;
          final List<int> orderB = bParent.children;
          final int indexA = orderA.indexOf(blockA.serial);
          final int indexB = orderB.indexOf(blockB.serial);
          orderA.removeAt(indexA);
          orderA.insert(indexA, blockB.serial);
          orderB.removeAt(indexB);
          orderB.insert(indexB, blockA.serial);
          _blockMap[blockA.serial] = blockA.copyWith(null, null,
              parentSerial: bParent.serial, nestLevel: aParent.nestLevel + 1);
          _blockMap[blockB.serial] = blockB.copyWith(null, null,
              parentSerial: aParent.serial, nestLevel: bParent.nestLevel + 1);
          // 下位のネストレベルを再調整
          List<SBMLBlock> blockAUnder = getUnderAllBlocks(blockA.serial);
          for (SBMLBlock i in blockAUnder) {
            _resetNestLevel(i);
          }
          List<SBMLBlock> blockBUnder = getUnderAllBlocks(blockB.serial);
          for (SBMLBlock i in blockBUnder) {
            _resetNestLevel(i);
          }
        } else {
          throw SBMLException(
              EnumSBMLExceptionType.nonExistSerialException, null,
              detail: "The parent serial not exist.");
        }
      }
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// internal getUnderAllBlocks.
  void _getAllBlockSerials(int serial, List<SBMLBlock> blockRef) {
    if (_blockMap.containsKey(serial)) {
      SBMLBlock target = _blockMap[serial]!;
      blockRef.add(target.deepCopy());
      // 子ブロックは必ず親ブロックの後にある。
      for (int i in target.children) {
        // 再帰処理
        _getAllBlockSerials(i, blockRef);
      }
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Get all blocks below the specified block by a list.
  ///
  /// * [serial] : The target block serial. The return blocks of top index is target serial block.
  ///
  /// Throws [EnumSBMLExceptionType.nonExistSerialException]
  List<SBMLBlock> getUnderAllBlocks(int serial) {
    List<SBMLBlock> blockRef = [];
    _getAllBlockSerials(serial, blockRef);
    return blockRef;
  }

  /// Loads the contents from the SBML.
  ///
  /// * [src] : The SBML.
  void loadFromSBML(String src) {
    clear();
    final SBMLBlock root = _blockMap[-1]!;
    for (SBMLBlock i in SBMLParser.run(src, isGraphMode: true)) {
      _blockMap[i.serial] = i;
      if (i.parentSerial == -1) {
        root.children.add(i.serial);
      }
    }
    _maxSerial = _blockMap.length - 1;
  }

  /// Loads the contents from the list of blocks.
  /// The block nesting level and serial number are reconstructed with the first block as 0.
  ///
  /// * [src] : The SBMLBlocks get from getUnderAllBlocks.
  void loadFromBlockList(List<SBMLBlock> src) {
    clear();
    if (src.isEmpty) {
      return;
    }
    int newSerial = 0;
    // key pre, value now serial.
    Map<int, int> preSerialMap = {src[0].parentSerial: -1};
    // 新しいシリアル番号をマッピング
    for (SBMLBlock i in src) {
      preSerialMap[i.serial] = newSerial;
      newSerial += 1;
    }
    List<SBMLBlock> updated = [];
    newSerial = 0;
    for (SBMLBlock i in src) {
      updated.add(i.copyWith(null, null,
          parentSerial: preSerialMap[i.parentSerial]!, children: []));
      newSerial += 1;
    }
    // 親シリアルを再構成したものを追加
    for (SBMLBlock i in updated) {
      add(i.type, i.params, i.content, parentSerial: i.parentSerial);
    }
  }

  /// Returns a list of blocks.
  List<SBMLBlock> getBlockList() {
    return List.from(_blockMap.values);
  }

  /// Returns raw block map.
  Map<int, SBMLBlock> getBlockMap() {
    return _blockMap;
  }

  /// Recursive process for build function.
  void _build(int serial, List<String> ref) {
    if (_blockMap.containsKey(serial)) {
      SBMLBlock target = _blockMap[serial]!;
      // SBMLに変換して情報を追加する。
      ref.addAll(target.toSBML());
      // 子ブロックは必ず親ブロックの後にある。
      for (int i in target.children) {
        // 再帰処理
        _build(i, ref);
      }
    } else {
      throw SBMLException(EnumSBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Builds and returns SBML text.
  ///
  String build() {
    List<String> r = [];
    _build(-1, r);
    // ルートの情報（1行目）は不要なので削除。
    r.removeAt(0);
    return r.join('\n');
  }
}
