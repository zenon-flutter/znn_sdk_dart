import 'bech32.dart';

const String znnTokenStandard = 'zts1tfjkummwyppk76twsnv50e';
const String qsrTokenStandard = 'zts1296kzunpwfpk76twef08fn';
const String ppTokenStandard = 'zts1k5stg3k4dmevfgwtgmg36u';
const String emptyTokenStandard = 'zts1qqqqqqqqqqqqqqqqtq587y';

final TokenStandard znnZts = TokenStandard.parse(znnTokenStandard);
final TokenStandard qsrZts = TokenStandard.parse(qsrTokenStandard);
final TokenStandard ppZts = TokenStandard.parse(ppTokenStandard);
final TokenStandard emptyZts = TokenStandard.parse(emptyTokenStandard);

class TokenStandard {
  static const String prefix = 'zts';
  static const int coreSize = 10;

  late String hrp;
  late List<int> core;

  TokenStandard.parse(String tokenStandard) {
    var bech32 = bech32Codec.decode(tokenStandard);
    hrp = bech32.hrp;
    core = convertBech32Bits(bech32.data, 5, 8, false);
    validate();
  }

  TokenStandard.fromBytes(List<int> bytes) {
    hrp = prefix;
    core = bytes;
    validate();
  }

  factory TokenStandard.bySymbol(String symbol) {
    if (symbol.compareTo('znn') == 0 ||
        symbol.compareTo('ZNN') == 0 ||
        symbol.compareTo('tznn') == 0 ||
        symbol.compareTo('tZNN') == 0) {
      return znnZts;
    } else if (symbol.compareTo('qsr') == 0 ||
        symbol.compareTo('QSR') == 0 ||
        symbol.compareTo('tqsr') == 0 ||
        symbol.compareTo('tQSR') == 0) {
      return qsrZts;
    } else {
      throw ArgumentError('TokenStandard.bySymbol supports only znn/qsr');
    }
  }

  List<int> getBytes() {
    return core;
  }

  void validate() {
    if (hrp != prefix) {
      throw ('invalid ZTS prefix. Expected "$prefix" but got "$hrp"');
    }
    if (core.length != coreSize) {
      throw ('invalid ZTS size. Expected $coreSize but got ${core.length}');
    }
  }

  @override
  String toString() {
    var bech32 = Bech32(hrp, convertBech32Bits(core, 8, 5, true));
    var addressStr = bech32Codec.encode(bech32);
    return addressStr;
  }

  @override
  bool operator ==(Object other) =>
      other is TokenStandard &&
      other.runtimeType == runtimeType &&
      other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;
}
