import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:flutter/services.dart';

import '../api/auth.dart';

class BaseRepository {
  static BaseRepository? _instance;
  static BaseRepository get instance => _instance ??= BaseRepository();
  late DialogflowGrpcV2Beta1 _dialogflow;
  Stream<StreamingDetectIntentResponse>? responseStream;
  late InputConfigV2beta1 _dfAudioConfig;

  Future<void> ensureInitialize() async {
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/credentials.json')));
    _dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);

    //Instantiate authentication
    BotAuthtentication.initialize();

    var biasList = SpeechContextV2Beta1(
      phrases: [
        'Dialogflow CX',
        'Dialogflow Essentials',
        'Action Builder',
        'HIPAA'
      ],
      boost: 20.0,
    );

    // See: https://cloud.google.com/dialogflow/es/docs/reference/rpc/google.cloud.dialogflow.v2#google.cloud.dialogflow.v2.InputAudioConfig
    _dfAudioConfig = InputConfigV2beta1(
      encoding: 'AUDIO_ENCODING_LINEAR_16',
      languageCode: 'en-US',
      sampleRateHertz: 16000,
      singleUtterance: false,
      speechContexts: [biasList],
    );
  }

  Future<QueryResult> detectTextIntent(String text) async {
    DetectIntentResponse data = await _dialogflow.detectIntent(text, 'en-US');

    return data.queryResult;
  }

  void detectAudioStreamIntent(Stream<List<int>> audioStream,
      ValueChanged<StreamingDetectIntentResponse> onReceive) {
    responseStream ??=
        _dialogflow.streamingDetectIntent(_dfAudioConfig, audioStream);
    responseStream?.listen(onReceive, onError: (e) {
      //print(e);
    }, onDone: () {
      //print('done');
    });
  }
}
