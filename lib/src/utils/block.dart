import 'dart:async';

import 'package:hex/hex.dart';
import 'package:znn_sdk_dart/src/globals.dart';
import 'package:znn_sdk_dart/src/model/model.dart';
import 'package:znn_sdk_dart/src/pow/pow.dart';
import 'package:znn_sdk_dart/src/utils/utils.dart';
import 'package:znn_sdk_dart/src/wallet/keypair.dart';
import 'package:znn_sdk_dart/src/zenon.dart';

class BlockUtils {
  static bool isSendBlock(int? blockType) {
    return [BlockTypeEnum.userSend.index, BlockTypeEnum.contractSend.index]
      .contains(blockType);
  }

  static bool isReceiveBlock(int blockType) {
    return [BlockTypeEnum.userReceive.index,
    BlockTypeEnum.genesisReceive.index,
    BlockTypeEnum.contractReceive,
    ].contains(blockType);
  }

  static Hash getTransactionHash(AccountBlockTemplate transaction) {
    var versionBytes = BytesUtils.longToBytes(transaction.version);
    var chainIdentifierBytes = BytesUtils.longToBytes(transaction.chainIdentifier);
    var blockTypeBytes = BytesUtils.longToBytes(transaction.blockType);
    var previousHashBytes = transaction.previousHash.getBytes()!;
    var heightBytes = BytesUtils.longToBytes(transaction.height);
    var momentumAcknowledgedBytes = transaction.momentumAcknowledged.getBytes();
    var addressBytes = transaction.address.getBytes();
    var toAddressBytes = transaction.toAddress.getBytes();
    var amountBytes = BytesUtils.bigIntToBytes(BigInt.from(transaction.amount), 32);
    var tokenStandardBytes = transaction.tokenStandard.getBytes();
    var fromBlockHashBytes = transaction.fromBlockHash.hash;
    var descendentBlocksBytes = Hash.digest([]).getBytes();
    var dataBytes = Hash.digest(transaction.data).getBytes();
    var fusedPlasmaBytes = BytesUtils.longToBytes(transaction.fusedPlasma);
    var difficultyBytes = BytesUtils.longToBytes(transaction.difficulty);
    var nonceBytes = BytesUtils.leftPadBytes(HEX.decode(transaction.nonce), 8);

    var source = BytesUtils.merge([
      versionBytes,
      chainIdentifierBytes,
      blockTypeBytes,
      previousHashBytes,
      heightBytes,
      momentumAcknowledgedBytes,
      addressBytes,
      toAddressBytes,
      amountBytes,
      tokenStandardBytes,
      fromBlockHashBytes,
      descendentBlocksBytes,
      dataBytes,
      fusedPlasmaBytes,
      difficultyBytes,
      nonceBytes
    ]);

    return Hash.digest(source);
  }

  static Future<List<int>> getTransactionSignature(KeyPair keyPair, AccountBlockTemplate transaction) {
    return keyPair.sign(transaction.hash.getBytes()!);
  }

  static Hash getPoWData(AccountBlockTemplate transaction) {
    return Hash.digest(BytesUtils.merge([transaction.address.getBytes(), transaction.previousHash.getBytes()]));
  }

  static Future<void> _autofillTransactionParameters(AccountBlockTemplate accountBlockTemplate) async {
    var z = Zenon();
    var frontierAccountBlock = await z.ledger.getFrontierBlock(accountBlockTemplate.address);

    var height = 1;
    Hash? previousHash = emptyHash;
    if (frontierAccountBlock != null) {
      height = frontierAccountBlock.height + 1;
      previousHash = frontierAccountBlock.hash;
    }

    accountBlockTemplate.height = height;
    accountBlockTemplate.previousHash = previousHash;

    var frontierMomentum = await z.ledger.getFrontierMomentum();
    var momentumAcknowledged = HashHeight(frontierMomentum.hash, frontierMomentum.height);
    accountBlockTemplate.momentumAcknowledged = momentumAcknowledged;
  }

  static Future<bool> _checkAndSetFields(AccountBlockTemplate transaction, KeyPair currentKeyPair) async {
    var z = Zenon();

    transaction.address = (await currentKeyPair.address)!;
    transaction.publicKey = (await currentKeyPair.getPublicKey());

    await _autofillTransactionParameters(transaction);

    if (BlockUtils.isSendBlock(transaction.blockType)) {
    } else {
      if (transaction.fromBlockHash == emptyHash) {
        throw Error();
      }

      var sendBlock = await z.ledger.getBlockByHash(transaction.fromBlockHash);
      if (sendBlock == null) {
        throw Error();
      }
      if (!(sendBlock.toAddress.toString() == transaction.address.toString())) {
        throw Error();
      }

      if (transaction.data.isNotEmpty) {
        throw Error();
      }
    }

    if (transaction.difficulty > 0 && transaction.nonce == '') {
      throw Error();
    }
    return true;
  }

  static Future<bool> _setDifficulty(AccountBlockTemplate transaction,
      {void Function(PowStatus)? generatingPowCallback, waitForRequiredPlasma = false}) async {
    var z = Zenon();
    var powParam = GetRequiredParam(
        address: transaction.address,
        blockType: transaction.blockType,
        toAddress: transaction.toAddress,
        data: transaction.data);

    var response = await z.embedded.plasma.getRequiredPoWForAccountBlock(powParam);

    if (response.requiredDifficulty != 0) {
      transaction.fusedPlasma = response.availablePlasma;
      transaction.difficulty = response.requiredDifficulty;
      logger.info('Generating Plasma for block: hash=${BlockUtils.getPoWData(transaction)}');
      generatingPowCallback?.call(PowStatus.generating);
      transaction.nonce = await generatePoW(BlockUtils.getPoWData(transaction), transaction.difficulty);
      generatingPowCallback?.call(PowStatus.done);
    } else {
      transaction.fusedPlasma = response.basePlasma;
      transaction.difficulty = 0;
      transaction.nonce = '0000000000000000';
    }
    return true;
  }

  static Future<bool> _setHashAndSignature(AccountBlockTemplate transaction, KeyPair currentKeyPair) async {
    transaction.hash = BlockUtils.getTransactionHash(transaction);
    var transSig = await BlockUtils.getTransactionSignature(currentKeyPair, transaction);
    transaction.signature = transSig;
    return true;
  }

  static Future<AccountBlockTemplate> send(AccountBlockTemplate transaction, KeyPair currentKeyPair,
      {void Function(PowStatus)? generatingPowCallback, waitForRequiredPlasma = false}) async {
    var z = Zenon();

    await _checkAndSetFields(transaction, currentKeyPair);
    await _setDifficulty(transaction,
        generatingPowCallback: generatingPowCallback, waitForRequiredPlasma: waitForRequiredPlasma);
    await _setHashAndSignature(transaction, currentKeyPair);

    await z.ledger.publishRawTransaction(transaction);
    logger.info('Published account-block');
    return transaction;
  }

  static Future<bool> requiresPoW(AccountBlockTemplate transaction, {KeyPair? blockSigningKey}) async {
    var z = Zenon();

    if (transaction.difficulty == 0) {
      transaction.address = (await blockSigningKey!.address)!;
      var powParam = GetRequiredParam(
          address: transaction.address,
          blockType: transaction.blockType,
          toAddress: transaction.toAddress,
          data: transaction.data);

      var response = await z.embedded.plasma.getRequiredPoWForAccountBlock(powParam);
      if (response.requiredDifficulty != 0) {
        return true;
      }
    }
    return true;
  }
}
