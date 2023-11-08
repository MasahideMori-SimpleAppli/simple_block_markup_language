import 'spbml_block.dart';
import 'spbml_exception.dart';
import 'spbml_parser.dart';

///
/// This class is for building and operating SpBML.
///
/// Author Masahide Mori
///
/// First edition creation date 2022-07-16 17:47:57
///
class SpBMLBuilder {
  // ブロック構造のデフォルト値
  final SpBMLBlock rootBlock = SpBMLBlock(_baseSerial, -2, -1, "root", {}, "");

  // 保持しているブロック。キーがブロックシリアル、値がブロックの内容クラス。
  late Map<int, SpBMLBlock> _blockMap;

  // 基底のシリアル
  static const _baseSerial = -1;

  // これまでに設定されたシリアルの最大値のデフォルト値。
  static const _defMaxSerial = -1;

  // これまでに設定されたシリアルの最大値。
  int _maxSerial = _defMaxSerial;

  /// Constructor
  SpBMLBuilder() {
    _blockMap = {-1: rootBlock.deepCopy()};
  }

  /// Clear blocks.
  void clear() {
    _blockMap = {-1: rootBlock.deepCopy()};
    _maxSerial = _defMaxSerial;
  }

  /// Input check of type, serial and parentSerial.
  ///
  /// * [serial] : This block serial. Must be 0 or greater.
  /// * [type] : The block type. The type cannot contain line feed.
  /// The name that root and esc cannot be defined because they are reserved.
  /// * [parentSerial] : The parent block serial number.
  /// If parent is root, this is -1. This value must be -1 or greater.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  void _checkTypeAndSerial(int? serial, String type, int parentSerial) {
    if (serial != null) {
      if (serial < 0) {
        throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
            detail: "The serial must be 0 or greater");
      }
    }
    if (parentSerial < -1) {
      throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
          detail: "The parentSerial must be -1 or greater");
    }
    if (type.contains(SpBMLParser.newLineCode)) {
      throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
          detail: "The type cannot contain line feed.");
    }
    if (type == "root" || type == "esc") {
      throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
          detail:
              "Regarding types, esc and root are reserved and cannot be used.");
    }
  }

  ///　Checks if the parameter contains newlines
  ///　and throws an exception if it does.
  ///
  /// * [params] : Block parameter.
  void _checkParams(Map<String, String> params) {
    for (String i in params.keys) {
      if (i.contains(SpBMLParser.newLineCode) ||
          params[i]!.contains(SpBMLParser.newLineCode)) {
        throw SpBMLException(EnumSpBMLExceptionType.illegalArgException, null,
            detail: "The parameter keys and values cannot contain line feed.");
      }
    }
  }

  /// (en) Add block.
  ///
  /// (ja) ブロックを追加します。
  ///
  /// * [type] : The block type. The type cannot contain line feed.
  /// * [params] : Block parameter. The parameter keys and values cannot contain line feed.
  /// * [content] : The block content.
  /// * [parentSerial] : The parent block serial number.
  /// If parent is root, this is -1. This value must be -1 or greater.
  ///
  /// Returns: Added block.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  ///
  /// Throws [EnumSpBMLExceptionType.illegalArgException]
  SpBMLBlock add(String type, Map<String, String> params, String content,
      {int parentSerial = -1}) {
    _checkTypeAndSerial(null, type, parentSerial);
    _checkParams(params);
    if (_blockMap.containsKey(parentSerial)) {
      final int nowSerial = _maxSerial + 1;
      _maxSerial = nowSerial;
      final SpBMLBlock parent = _blockMap[parentSerial]!;
      final SpBMLBlock child = SpBMLBlock(
          nowSerial, parentSerial, parent.nestLevel + 1, type, params, content);
      parent.children.add(nowSerial);
      _blockMap[nowSerial] = child;
      return child;
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// (en) Set block.
  ///
  /// (ja) 指定したシリアルナンバーを強制し、ブロックをセットします。
  ///
  /// * [serial] : This block serial. Must be 0 or greater.
  /// * [type] : The block type. The type cannot contain line feed.
  /// * [params] : Block parameter. The parameter keys and values cannot contain line feed.
  /// * [content] : The block content.
  /// * [parentSerial] : The parent block serial number.
  /// If parent is root, this is -1.
  ///
  /// Returns: Set block.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  ///
  /// Throws [EnumSpBMLExceptionType.illegalArgException]
  SpBMLBlock set(
      int serial, String type, Map<String, String> params, String content,
      {int parentSerial = -1}) {
    _checkTypeAndSerial(serial, type, parentSerial);
    _checkParams(params);
    if (_blockMap.containsKey(parentSerial)) {
      if (_maxSerial < serial) {
        _maxSerial = serial;
      }
      final SpBMLBlock parent = _blockMap[parentSerial]!;
      final SpBMLBlock child = SpBMLBlock(
          serial, parentSerial, parent.nestLevel + 1, type, params, content);
      parent.children.add(serial);
      _blockMap[serial] = child;
      return child;
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// Reset target nest revel.
  /// It should be noted that the nesting level of the child does not change.
  void _resetNestLevel(SpBMLBlock target) {
    if (_blockMap.containsKey(target.parentSerial)) {
      SpBMLBlock tp = _blockMap[target.parentSerial]!;
      _blockMap[target.serial] =
          target.copyWith(null, null, nestLevel: tp.nestLevel + 1);
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// (en) Reinsert blocks. This should be called after the remove method call.
  /// The block nesting level is reconstructed with under the parent block.
  /// The first block parent serial will change under the new parent block.
  ///
  /// (ja) ブロックを再度挿入します。これは、remove メソッド呼び出しの後に呼び出す必要があります。
  /// ブロックのネストレベルは親ブロックの下に再構築されます。
  /// 最初のブロックの親シリアルは、新しい親ブロックの下で変更されます。
  ///
  /// * [parentSerial] : The parent block serial number. If parent is root, this is -1.
  /// * [blocks] : The SpBMLBlocks get from getUnderAllBlocks. this method is not change block serials.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  void reinsert(int parentSerial, List<SpBMLBlock> blocks) {
    if (blocks.isEmpty) {
      return;
    }
    if (_blockMap.containsKey(parentSerial)) {
      SpBMLBlock parent = _blockMap[parentSerial]!;
      final int parentNestLevel = parent.nestLevel;
      List<SpBMLBlock> blocksCopy = [...blocks];
      // override parent serial.
      SpBMLBlock firstBlock = blocksCopy.removeAt(0).copyWith(null, null,
          parentSerial: parentSerial, nestLevel: parentNestLevel + 1);
      blocksCopy.insert(0, firstBlock);
      parent.children.add(blocksCopy[0].serial);
      for (SpBMLBlock i in blocksCopy) {
        _resetNestLevel(i);
      }
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// internal remove. this is not remove target serial in parent children.
  void _remove(int serial) {
    if (_blockMap.containsKey(serial)) {
      SpBMLBlock t = _blockMap[serial]!;
      for (int i in [...t.children]) {
        // 再帰処理
        _remove(i);
      }
      _blockMap.remove(serial);
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// (en) Remove the block. The lower blocks are deleted together.
  ///
  /// (ja) ブロックを取り外します。 下位のブロックもまとめて削除されます。
  ///
  /// * [serial] : The target block serial.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  void remove(int serial) {
    if (serial == _baseSerial) {
      // ここはクリアにしないと正しく初期化されないので注意。
      clear();
    } else {
      SpBMLBlock t = _blockMap[serial]!;
      if (_blockMap.containsKey(t.parentSerial)) {
        SpBMLBlock p = _blockMap[t.parentSerial]!;
        p.children.remove(serial);
      } else {
        throw SpBMLException(
            EnumSpBMLExceptionType.nonExistSerialException, null);
      }
      _remove(serial);
    }
  }

  /// (en) Remove all blocks and return the removed blocks.
  ///
  /// (ja) 全てのブロックを削除し、削除したブロックを返却します。
  ///
  /// * [serial] : The target block serial.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  List<SpBMLBlock> pop(int serial) {
    List<SpBMLBlock> r = getUnderAllBlocks(serial);
    remove(serial);
    return r;
  }

  /// (en) Get block that have a target serial.
  ///
  /// (ja) 対象のシリアルを持つブロックを取得します。
  ///
  /// * [serial] : The target block serial.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  SpBMLBlock getBlock(int serial) {
    if (_blockMap.containsKey(serial)) {
      return _blockMap[serial]!;
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// (en) Exchange block positions.
  ///
  /// (ja) 2つの既存のブロックの位置を入れ替えます。
  ///
  /// * [serialA] : The target block serial.
  /// * [serialB] : The target block serial.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  void exchangePositions(int serialA, int serialB) {
    if (_blockMap.containsKey(serialA) && _blockMap.containsKey(serialB)) {
      final SpBMLBlock blockA = _blockMap[serialA]!;
      final SpBMLBlock blockB = _blockMap[serialB]!;
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
          throw SpBMLException(
              EnumSpBMLExceptionType.nonExistSerialException, null,
              detail: "The parent serial not exist.");
        }
      } else {
        if (_blockMap.containsKey(blockA.parentSerial) &&
            _blockMap.containsKey(blockB.parentSerial)) {
          final SpBMLBlock aParent = _blockMap[blockA.parentSerial]!;
          final SpBMLBlock bParent = _blockMap[blockB.parentSerial]!;
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
          List<SpBMLBlock> blockAUnder = getUnderAllBlocks(blockA.serial);
          for (SpBMLBlock i in blockAUnder) {
            _resetNestLevel(i);
          }
          List<SpBMLBlock> blockBUnder = getUnderAllBlocks(blockB.serial);
          for (SpBMLBlock i in blockBUnder) {
            _resetNestLevel(i);
          }
        } else {
          throw SpBMLException(
              EnumSpBMLExceptionType.nonExistSerialException, null,
              detail: "The parent serial not exist.");
        }
      }
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// internal getUnderAllBlocks.
  void _getAllBlockSerials(int serial, List<SpBMLBlock> blockRef) {
    if (_blockMap.containsKey(serial)) {
      SpBMLBlock target = _blockMap[serial]!;
      blockRef.add(target);
      // 子ブロックは必ず親ブロックの後にある。
      for (int i in target.children) {
        // 再帰処理
        _getAllBlockSerials(i, blockRef);
      }
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// (en) Gets the block with the specified serial and its child blocks all at once.
  ///
  /// (ja) 指定シリアルを持つブロックと、その子ブロックをまとめて取得します。
  ///
  /// * [serial] : The target block serial.
  /// The return blocks of top index is target serial block.
  ///
  /// Throws [EnumSpBMLExceptionType.nonExistSerialException]
  List<SpBMLBlock> getUnderAllBlocks(int serial) {
    List<SpBMLBlock> blockRef = [];
    _getAllBlockSerials(serial, blockRef);
    return blockRef;
  }

  /// (en) Loads the contents from the SpBML.
  ///
  /// (ja) SpBML からコンテンツを読み込みます。
  ///
  /// * [src] : The SpBML.
  void loadFromSpBML(String src) {
    clear();
    final SpBMLBlock root = _blockMap[-1]!;
    for (SpBMLBlock i in SpBMLParser.run(src, isGraphMode: true)) {
      _blockMap[i.serial] = i;
      if (i.parentSerial == -1) {
        root.children.add(i.serial);
      }
    }
    _maxSerial = _blockMap.length - 1;
  }

  /// (en) Loads the contents from the list of blocks.
  /// The block nesting level and serial number are reconstructed
  /// with the first block as 0.
  ///
  /// (ja) ブロックのリストからコンテンツをロードします。
  /// ブロックのネストレベルとシリアル番号が再構築されます
  /// 最初のブロックを 0 として扱います。
  ///
  /// * [src] : The SpBMLBlocks get from getUnderAllBlocks.
  void loadFromBlockList(List<SpBMLBlock> src) {
    clear();
    if (src.isEmpty) {
      return;
    }
    int newSerial = 0;
    // key pre, value now serial.
    Map<int, int> preSerialMap = {src[0].parentSerial: -1};
    // 新しいシリアル番号をマッピング
    for (SpBMLBlock i in src) {
      preSerialMap[i.serial] = newSerial;
      newSerial += 1;
    }
    List<SpBMLBlock> updated = [];
    newSerial = 0;
    for (SpBMLBlock i in src) {
      updated.add(i.copyWith(null, null,
          parentSerial: preSerialMap[i.parentSerial]!, children: []));
      newSerial += 1;
    }
    // 親シリアルを再構成したものを追加
    for (SpBMLBlock i in updated) {
      add(i.type, i.params, i.content, parentSerial: i.parentSerial);
    }
  }

  /// (en) Returns a list of blocks.
  /// Please note that the order of blocks is undefined with this method.
  ///
  /// (ja) ブロックのリストを取得します。
  /// このメソッドではブロックの順番は不定になるため注意してください。
  List<SpBMLBlock> getBlockList() {
    return List.from(_blockMap.values);
  }

  /// (en) Returns raw block map.
  ///
  /// (ja) このクラスで管理されているブロックのマップを返します。
  Map<int, SpBMLBlock> getBlockMap() {
    return _blockMap;
  }

  /// Recursive process for build function.
  void _build(int serial, List<String> ref) {
    if (_blockMap.containsKey(serial)) {
      SpBMLBlock target = _blockMap[serial]!;
      // SpBMLに変換して情報を追加する。
      ref.addAll(target.toSpBML());
      // 子ブロックは必ず親ブロックの後にある。
      for (int i in target.children) {
        // 再帰処理
        _build(i, ref);
      }
    } else {
      throw SpBMLException(
          EnumSpBMLExceptionType.nonExistSerialException, null);
    }
  }

  /// (en) Builds and returns SpBML text.
  ///
  /// (ja) SpBMLとしてビルドしたテキストを返します。
  String build() {
    List<String> r = [];
    _build(-1, r);
    // ルートの情報（1行目）は不要なので削除。
    r.removeAt(0);
    return r.join('\n');
  }
}
