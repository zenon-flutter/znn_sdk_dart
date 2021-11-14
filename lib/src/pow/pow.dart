import 'dart:async';
import 'dart:convert' as convert;
import 'dart:ffi';
import 'dart:io' show Directory, File, Platform;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:znn_sdk_dart/src/globals.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

enum PowStatus {
  generating,
  done,
}

var invalidPowLinksLibPathException = ZnnSdkException('libpow_links library could not be found');

typedef _GeneratePowFunc = Pointer<Utf8> Function(Pointer<Utf8> data, Pointer<Utf8> difficulty);
typedef _GeneratePoW = Pointer<Utf8> Function(Pointer<Utf8> data, Pointer<Utf8> difficulty);
typedef _BenchmarkPowFunc = Pointer<Utf8> Function(Pointer<Utf8> difficulty);
typedef _BenchmarkPoW = Pointer<Utf8> Function(Pointer<Utf8> difficulty);

var _generatePoWFunction;
var _benchmarkFunction;

// Loads the dynamic pow_links library and maps the required functions.
void initializePoWLinks() {
  var insideSdk = path.join('znn_sdk_dart', 'lib', 'src', 'pow', 'blobs');
  var currentPathListParts = path.split(Directory.current.path);
  currentPathListParts.removeLast();
  var executablePathListParts = path.split(Platform.resolvedExecutable);
  executablePathListParts.removeLast();
  var possiblePaths = List<String>.empty(growable: true);
  possiblePaths.add(Directory.current.path);
  possiblePaths.add(path.joinAll(executablePathListParts));
  executablePathListParts.removeLast();
  possiblePaths.add(path.join(path.joinAll(executablePathListParts), 'Resources'));
  possiblePaths.add(path.join(path.joinAll(currentPathListParts), insideSdk));
  possiblePaths.add(path.join(path.joinAll(currentPathListParts), 'packages', insideSdk));

  var libraryPath = '';
  var found = false;

  for (var currentPath in possiblePaths) {
    libraryPath = path.join(currentPath, 'libpow_links.so');

    if (Platform.isMacOS) {
      libraryPath = path.join(currentPath, 'libpow_links.dylib');
    }
    if (Platform.isWindows) {
      libraryPath = path.join(currentPath, 'libpow_links.dll');
    }

    var libFile = File(libraryPath);

    if (libFile.existsSync()) {
      found = true;
      break;
    }
  }

  logger.info('Loading libpow_links from path ' + libraryPath);

  if (!found) {
    throw invalidPowLinksLibPathException;
  }

  // Open the dynamic library
  final dylib = DynamicLibrary.open(libraryPath);

  // Look up the CPP function 'generatePoW'
  final generatePoWPointer = dylib.lookup<NativeFunction<_GeneratePowFunc>>('generatePoW');
  _generatePoWFunction = generatePoWPointer.asFunction<_GeneratePoW>();

  // Look up the C function 'benchmark'
  final functionPointer = dylib.lookup<NativeFunction<_BenchmarkPowFunc>>('benchmark');
  _benchmarkFunction = functionPointer.asFunction<_BenchmarkPoW>();
}

class _GeneratePowFunctionArguments {
  final Hash hash;
  final int? difficulty;
  final SendPort sendPort;

  _GeneratePowFunctionArguments(this.hash, this.difficulty, this.sendPort);
}

void _generatePowFunction(_GeneratePowFunctionArguments args) {
  initializePoWLinks();
  final Pointer<Utf8> ret =
      _generatePoWFunction(args.hash.toString().toNativeUtf8(), args.difficulty.toString().toNativeUtf8());

  var utf8 = ret.toDartString();
  args.sendPort.send(utf8);
}

// Returns a hex representation of the nonce.
// Runs single threaded, with native C code.
Future<String> generatePoW(Hash hash, int? difficulty) async {
  if (_generatePoWFunction == null) {
    initializePoWLinks();
  }

  final port = ReceivePort();
  final args = _GeneratePowFunctionArguments(hash, difficulty, port.sendPort);
  Isolate? isolate = await Isolate.spawn<_GeneratePowFunctionArguments>(_generatePowFunction, args,
      onError: port.sendPort, onExit: port.sendPort);
  StreamSubscription? sub;
  // Listening for messages on port
  var completer = Completer<String>();

  sub = port.listen((data) async {
    // Cancel subscription after message is received
    if (data != null) {
      var ansHex = data.toString();
      completer.complete(ansHex);
      await sub?.cancel();
      logger.info('Generated nonce $ansHex for hash ${hash.toString()} with difficulty $difficulty');
      if (isolate != null) {
        isolate!.kill(priority: Isolate.immediate);
        isolate = null;
      }
    }
  });
  return completer.future;
}

String benchmarkPoW(int difficulty) {
  if (_benchmarkFunction == null) {
    initializePoWLinks();
  }

  final ret = _benchmarkFunction(convert.utf8.encode(difficulty.toString()));
  final ans = convert.utf8.decode(ret);
  return ans;
}
