import 'package:znn_sdk_dart/src/embedded/embedded.dart';
import 'package:znn_sdk_dart/src/client/client.dart';
import 'package:znn_sdk_dart/src/model/model.dart';

class PlasmaApi {
  late Client client;

  void setClient(Client client) {
    this.client = client;
  }

  Future<PlasmaInfo> get(Address address) async {
    var response =
        await client.sendRequest('embedded.plasma.get', [address.toString()]);
    return PlasmaInfo.fromJson(response!);
  }

  Future<FusionEntryList> getEntriesByAddress(Address address,
      {int pageIndex = 0, int pageSize = rpcMaxPageSize}) async {
    var response = await client.sendRequest(
        'embedded.plasma.getEntriesByAddress',
        [address.toString(), pageIndex, pageSize]);
    return FusionEntryList.fromJson(response!);
  }

  Future<int> getRequiredFusionAmount(int requiredPlasma) async {
    return await client.sendRequest(
        'embedded.plasma.getRequiredFusionAmount', [requiredPlasma]);
  }

  int getPlasmaByQsr(double qsrAmount) {
    for (var i = 1; i <= 120; i++) {
      if (qsrAmount < plasmaRequiredQsr[i]) {
        return minPlasmaAmount * (i - 1);
      }
    }
    return minPlasmaAmount * 120;
  }

  Future<GetRequiredResponse> getRequiredPoWForAccountBlock(
      GetRequiredParam powParam) async {
    var response = await client.sendRequest(
        'embedded.plasma.getRequiredPoWForAccountBlock', [powParam.toJson()]);
    return GetRequiredResponse.fromJson(response);
  }

  AccountBlockTemplate fuse(Address beneficiary, int amount) {
    return AccountBlockTemplate.callContract(plasmaAddress, qsrZts, amount,
        Definitions.plasma.encodeFunction('Fuse', [beneficiary]));
  }

  AccountBlockTemplate cancel(Hash id) {
    return AccountBlockTemplate.callContract(plasmaAddress, znnZts, 0,
        Definitions.plasma.encodeFunction('CancelFuse', [id.getBytes()]));
  }
}

const plasmaRequiredQsr = [
  0,
  10,
  20,
  30,
  40,
  50,
  60,
  70,
  80,
  90,
  100,
  110,
  120,
  130,
  140,
  150,
  160,
  170,
  180,
  190,
  200,
  210,
  220,
  230,
  240,
  250,
  260,
  270,
  280,
  290,
  300,
  310,
  320,
  330,
  340,
  350,
  360,
  370,
  381,
  391,
  401,
  411,
  421,
  431,
  441,
  451,
  461,
  471,
  482,
  492,
  502,
  512,
  522,
  532,
  542,
  553,
  563,
  573,
  583,
  593,
  604,
  614,
  624,
  634,
  644,
  655,
  665,
  675,
  685,
  696,
  706,
  716,
  726,
  737,
  747,
  757,
  768,
  778,
  788,
  799,
  809,
  819,
  830,
  840,
  851,
  861,
  871,
  882,
  892,
  903,
  913,
  924,
  934,
  945,
  955,
  966,
  976,
  987,
  997,
  1008,
  1018,
  1029,
  1040,
  1050,
  1061,
  1071,
  1082,
  1093,
  1103,
  1114,
  1125,
  1136,
  1146,
  1157,
  1168,
  1178,
  1189,
  1200,
  1211,
  1222,
  1233
];
