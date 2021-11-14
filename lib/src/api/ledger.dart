import 'dart:async';

import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class LedgerApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  // This method returns null if the block was accepted
  Future publishRawTransaction(AccountBlockTemplate accountBlockTemplate) {
    return client.sendRequest('ledger.publishRawTransaction', [accountBlockTemplate.toJson()]);
  }

  Future<AccountBlockList> getUnconfirmedBlocksByAddress(Address address,
      {int pageIndex = 0, int pageSize = memoryPoolPageSize}) async {
    var response = await client.sendRequest('ledger.getUnconfirmedBlocksByAddress', [address.toString(), pageIndex, pageSize]);
    return AccountBlockList.fromJson(response!);
  }

  Future<AccountBlockList> getUnreceivedBlocksByAddress(Address address,
      {int pageIndex = 0, int pageSize = memoryPoolPageSize}) async {
    var response = await client.sendRequest('ledger.getUnreceivedBlocksByAddress', [address.toString(), pageIndex, pageSize]);
    return AccountBlockList.fromJson(response!);
  }

  Future<AccountBlock?> getFrontierBlock(Address? address) async {
    var response = await client.sendRequest('ledger.getFrontierAccountBlock', [address.toString()]);
    return response == null ? null : AccountBlock.fromJson(response);
  }

  Future<AccountBlock?> getBlockByHash(Hash? hash) async {
    var response = await client.sendRequest('ledger.getAccountBlockByHash', [hash.toString()]);
    return response == null ? null : AccountBlock.fromJson(response);
  }

  Future<AccountBlockList> getBlocksByHeight(Address address, [int height = 1, int count = rpcMaxPageSize]) async {
    var response = await client.sendRequest('ledger.getAccountBlocksByHeight', [address.toString(), height, count]);
    return AccountBlockList.fromJson(response!);
  }

  // pageIndex = 0 returns the most recent account blocks sorted descending by height
  Future<AccountBlockList> getBlocksByPage(Address address, {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest('ledger.getAccountBlocksByPage', [address.toString(), pageIndex, pageSize]);
    return AccountBlockList.fromJson(response!);
  }

  Future<Momentum> getFrontierMomentum() async {
    var response = await client.sendRequest('ledger.getFrontierMomentum', []) as Map<String, dynamic>;
    return Momentum.fromJson(response);
  }

  Future<Momentum?> getMomentumBeforeTime(int time) async {
    var response = await client.sendRequest('ledger.getMomentumBeforeTime', [time]);
    return response == null ? null : Momentum.fromJson(response);
  }

  Future<Momentum?> getMomentumByHash(Hash hash) async {
    var response = await client.sendRequest('ledger.getMomentumByHash', [hash.toString()]);
    return response == null ? null : Momentum.fromJson(response);
  }

  Future<MomentumList> getMomentumsByHeight(int height, int count) async {
    height = height < 1 ? 1 : height;
    count = count > rpcMaxPageSize ? rpcMaxPageSize : count;
    var response = await client.sendRequest('ledger.getMomentumsByHeight', [height, count]);
    return MomentumList.fromJson(response);
  }
  // pageIndex = 0 returns the most recent momentums sorted in descending order by height
  Future<MomentumList> getMomentumsByPage({int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest('ledger.getMomentumsByPage', [pageIndex, pageSize]);
    return MomentumList.fromJson(response);
  }

  Future<DetailedMomentumList> getDetailedMomentumsByHeight(int height, int count) async {
    height = height < 1 ? 1 : height;
    count = count > rpcMaxPageSize ? rpcMaxPageSize : count;
    var response = await client.sendRequest('ledger.getDetailedMomentumsByHeight', [height, count]);
    return DetailedMomentumList.fromJson(response);
  }

  Future<AccountInfo> getAccountInfoByAddress(Address address) async {
    var response = await (client.sendRequest('ledger.getAccountInfoByAddress', [address.toString()]));
    return AccountInfo.fromJson(response);
  }
}
