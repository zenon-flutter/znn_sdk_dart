import 'package:znn_sdk_dart/src/model/primitives.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';

class PillarInfo {
  String name;
  int rank;
  Address ownerAddress;
  Address producerAddress;
  Address withdrawAddress;
  int giveMomentumRewardPercentage;
  int giveDelegateRewardPercentage;
  bool isRevocable;
  int revokeCooldown;
  int revokeTimestamp;
  PillarEpochStats currentStats;
  int weight;

  PillarInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        rank = json['rank'],
        ownerAddress = Address.parse(json['ownerAddress']),
        producerAddress = Address.parse(json['producerAddress']),
        withdrawAddress = Address.parse(json['withdrawAddress']),
        giveMomentumRewardPercentage = json['giveMomentumRewardPercentage'],
        giveDelegateRewardPercentage = json['giveDelegateRewardPercentage'],
        isRevocable = json['isRevocable'],
        revokeCooldown = json['revokeCooldown'],
        revokeTimestamp = json['revokeTimestamp'],
        currentStats = PillarEpochStats.fromJson(json['currentStats']),
        weight = json['weight'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['rank'] = rank;
    data['ownerAddress'] = ownerAddress.toString();
    data['producerAddress'] = producerAddress.toString();
    data['withdrawAddress'] = withdrawAddress.toString();
    data['isRevocable'] = isRevocable;
    data['revokeCooldown'] = revokeCooldown;
    data['revokeTimestamp'] = revokeTimestamp;
    data['currentStats'] = currentStats.toJson();
    data['weight'] = weight;
    return data;
  }
}

class PillarInfoList {
  int count;
  List<PillarInfo> list;

  PillarInfoList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list =
            (json['list'] as List).map((j) => PillarInfo.fromJson(j)).toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}

class PillarEpochStats {
  int producedMomentums;
  int expectedMomentums;

  PillarEpochStats.fromJson(Map<String, dynamic> json)
      : producedMomentums = json['producedMomentums'],
        expectedMomentums = json['expectedMomentums'];

  Map<String, dynamic> toJson() => {
        'producedMomentums': producedMomentums,
        'expectedMomentums': expectedMomentums
      };
}

class PillarEpochHistory {
  String name;
  int epoch;
  int giveBlockRewardPercentage;
  int giveDelegateRewardPercentage;
  int producedBlockNum;
  int expectedBlockNum;
  int weight;

  PillarEpochHistory(
      this.name,
      this.epoch,
      this.giveBlockRewardPercentage,
      this.giveDelegateRewardPercentage,
      this.producedBlockNum,
      this.expectedBlockNum,
      this.weight);

  PillarEpochHistory.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        epoch = json['epoch'],
        giveBlockRewardPercentage = json['giveBlockRewardPercentage'],
        giveDelegateRewardPercentage = json['giveDelegateRewardPercentage'],
        producedBlockNum = json['producedBlockNum'],
        expectedBlockNum = json['expectedBlockNum'],
        weight = json['weight'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'epoch': epoch,
        'giveBlockRewardPercentage': giveBlockRewardPercentage,
        'giveDelegateRewardPercentage': giveDelegateRewardPercentage,
        'producedBlockNum': producedBlockNum,
        'expectedBlockNum': expectedBlockNum,
        'weight': weight
      };
}

class PillarEpochHistoryList {
  int count;
  List<PillarEpochHistory> list;

  PillarEpochHistoryList.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        list = (json['list'] as List)
            .map((entry) => PillarEpochHistory.fromJson(entry))
            .toList();

  Map<String, dynamic> toJson() =>
      {'count': count, 'list': list.map((v) => v.toJson()).toList()};
}

class DelegationInfo {
  String name;
  int status;
  int weight;
  num? weightWithDecimals;

  DelegationInfo(
      {required this.name, required this.status, required this.weight}) {
    weightWithDecimals = AmountUtils.addDecimals(weight, 8);
  }

  factory DelegationInfo.fromJson(Map<String, dynamic> json) => DelegationInfo(
        name: json['name'],
        status: json['status'],
        weight: json['weight'],
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'status': status, 'weight': weight};

  bool isPillarActive() {
    return status == 1;
  }
}
