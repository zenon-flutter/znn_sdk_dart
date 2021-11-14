import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class StakeApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  Future<StakeList> getEntriesByAddress(Address address, {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest('embedded.stake.getEntriesByAddress', [address.toString(), pageIndex, pageSize]);
    return StakeList.fromJson(response!);
  }

  Future<UncollectedReward> getUncollectedReward(Address address) async {
    var response = await client.sendRequest('embedded.stake.getUncollectedReward', [address.toString()]);
    return UncollectedReward.fromJson(response!);
  }

  Future<RewardHistoryList> getFrontierRewardByPage(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response =
        await client.sendRequest('embedded.stake.getFrontierRewardByPage', [address.toString(), pageIndex, pageSize]);
    return RewardHistoryList.fromJson(response!);
  }

  AccountBlockTemplate stake(int durationInSec, int amount) {
    return AccountBlockTemplate.callContract(
        stakeAddress, znnZts, amount, Definitions.stake.encodeFunction('Stake', [durationInSec.toString()]));
  }

  AccountBlockTemplate cancel(Hash id) {
    return AccountBlockTemplate.callContract(
        stakeAddress, znnZts, 0, Definitions.stake.encodeFunction('Cancel', [id.getBytes()]));
  }

  AccountBlockTemplate updateContract() {
    return AccountBlockTemplate.callContract(
        stakeAddress, znnZts, 0, Definitions.stake.encodeFunction('UpdateEmbeddedStake', []));
  }

  AccountBlockTemplate collectReward() {
    return AccountBlockTemplate.callContract(
        stakeAddress, znnZts, 0, Definitions.common.encodeFunction('CollectReward', []));
  }
}
