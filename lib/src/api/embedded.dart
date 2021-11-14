import 'package:znn_sdk_dart/src/client/client.dart';

import 'embedded/accelerator.dart';
import 'embedded/pillar.dart';
import 'embedded/plasma.dart';
import 'embedded/sentinel.dart';
import 'embedded/stake.dart';
import 'embedded/swap.dart';
import 'embedded/token.dart';

class EmbeddedApi {
  late Client client;

  late PillarApi pillar;
  late PlasmaApi plasma;
  late SentinelApi sentinel;
  late StakeApi stake;
  late SwapApi swap;
  late TokenApi token;
  late AcceleratorApi accelerator;

  void setClient(Client client) {
    this.client = client;
    pillar.setClient(client);
    plasma.setClient(client);
    sentinel.setClient(client);
    stake.setClient(client);
    swap.setClient(client);
    token.setClient(client);
    accelerator.setClient(client);
  }

  EmbeddedApi() {
    pillar = PillarApi();
    plasma = PlasmaApi();
    sentinel = SentinelApi();
    stake = StakeApi();
    swap = SwapApi();
    token = TokenApi();
    accelerator = AcceleratorApi();
  }
}
