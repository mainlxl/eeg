import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eeg/core/utils/toast.dart';

Future<bool> checkNetworkConnectivity() async {
  var networkList = (await (Connectivity().checkConnectivity()))
      .where((item) => item != ConnectivityResult.none);
  print("checkNetworkConnectivity : ${networkList}");
  return networkList.isNotEmpty;
}

Future<bool> checkConnectivityAndShowToast() async {
  var connectivity = await checkNetworkConnectivity();
  if (!connectivity) {
    '您的网络开小差了,请确保网络通畅后再试'.toast;
  }
  return connectivity;
}
