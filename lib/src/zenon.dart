import 'dart:async';
import 'dart:io';

import 'package:znn_sdk_dart/src/api/api.dart' as api;
import 'package:znn_sdk_dart/src/globals.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/pow/pow.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';
import 'package:znn_sdk_dart/src/wallet/wallet.dart';

import 'client/websocket.dart';

var noKeyPairSelectedException =
    ZnnSdkException('Zenon SDK has no default keyPair selected');

class Zenon {
  static final Zenon _singleton = Zenon._internal();

  KeyPair? defaultKeyPair;
  KeyStore? defaultKeyStore;
  File? defaultKeyStorePath;

  late WsClient wsClient;
  late KeyStoreManager keyStoreManager;

  late api.LedgerApi ledger;
  late api.StatsApi stats;
  late api.EmbeddedApi embedded;
  late api.SubscribeApi subscribe;

  factory Zenon() {
    return _singleton;
  }

  Zenon._internal() {
    keyStoreManager = KeyStoreManager(walletPath: znnDefaultWalletDirectory);

    wsClient = WsClient();
    ledger = api.LedgerApi();
    stats = api.StatsApi();
    embedded = api.EmbeddedApi();
    subscribe = api.SubscribeApi();

    ledger.setClient(wsClient);
    stats.setClient(wsClient);
    embedded.setClient(wsClient);
    subscribe.setClient(wsClient);
  }

  Future<AccountBlockTemplate> send(AccountBlockTemplate transaction,
      {KeyPair? currentKeyPair,
      void Function(PowStatus)? generatingPowCallback,
      waitForRequiredPlasma = false}) async {
    currentKeyPair ??= defaultKeyPair;
    if (currentKeyPair == null) throw noKeyPairSelectedException;
    return BlockUtils.send(transaction, currentKeyPair,
        generatingPowCallback: generatingPowCallback,
        waitForRequiredPlasma: waitForRequiredPlasma);
  }

  Future<bool> requiresPoW(AccountBlockTemplate transaction,
      {KeyPair? blockSigningKey}) async {
    blockSigningKey ??= defaultKeyPair;
    return BlockUtils.requiresPoW(transaction,
        blockSigningKey: blockSigningKey);
  }
}
