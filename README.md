# znn_sdk_dart

Pub package mirror for znn_sdk_dart: https://testnet.znn.space/#!downloads.md#SDKs

## What is Zenon?

Zenon is a cryptocurrency based on a decentralized network that aims to create next-generation tools powering the digital ecosystem of the future.
Website: https://zenon.network/

### Import the znn_sdk_dart package
To use the znn_sdk_dart plugin, follow the [plugin installation instructions](https://pub.dartlang.org/packages/znn_sdk_dart#pub-pkg-tab-installing).

### Use the package

Add the following import to your Dart code:
```dart
import 'package:znn_sdk_dart/znn_sdk_dart.dart';
// For hexadecimal encoding and decoding
import 'package:hex/hex.dart';
```


```dart
final mnemonic =
    'route become dream access impulse price inform obtain engage ski believe awful absent pig thing vibrant possible exotic flee pepper marble rural fire fancy';

var keyStore = KeyStore.fromMnemonic(mnemonic);
var keyPair = keyStore.getKeyPair(0);
var privateKey = keyPair.getPrivateKey();
var publicKey = await keyPair.getPublicKey();
var address = await keyPair.address;

print('entropy: ${keyStore.entropy}');
print('private key: ${HEX.encode(privateKey!)}');
print('public key: ${HEX.encode(publicKey)}');
print('address: $address');
print('core bytes: ${HEX.encode(address!.core!)}');
```

## Example

See the [example application](https://github.com/zenon-flutter/znn_sdk_dart/tree/master/example) source
for a complete sample app using the znn_sdk_dart package.

## Issues and feedback

Please file [issues](https://github.com/zenon-flutter/znn_sdk_dart/issues/new)
to send feedback or report a bug. Thank you!
