import 'package:list_with_pagination/earning_model.dart';

abstract class Api {
  Future<List<EarningModel>> fetchEarnings(String userId, {int page = 0});
  Stream walletUpdates(String userId);
  Future fetchDetail(String id);
}