import 'package:list_with_pagination/api.dart';
import 'package:list_with_pagination/earning_model.dart';

class ProjectsApi implements Api {
  @override
  Future<List<EarningModel>> fetchEarnings(
    String userId, {
    int page = 0,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (page > 4) return [];

    const pageSize = 20;
    final startIndex = page * pageSize;

    return List.generate(pageSize, (i) {
      final index = startIndex + i + 1;
      return EarningModel(
        id: '$index',
        amount: index * 150,
        formattedAmount: '₹${index * 150}',
      );
    });
  }

  @override
  Stream walletUpdates(String userId) {
    return const Stream.empty();
  }

  @override
  Future fetchDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'Details for Earning #$id';
  }
}
