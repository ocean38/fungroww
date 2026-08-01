import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_with_pagination/api.dart';
import 'package:list_with_pagination/detail_screen.dart';
import 'package:list_with_pagination/earning_model.dart';

class EarningsScreen extends StatefulWidget {
  final String userId;
  final Api api;

  const EarningsScreen({super.key, required this.userId, required this.api});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final List<EarningModel> _earnings = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  bool _isLoadMore = true;

  String? _firstLoadError;
  String? _paginationError;

  StreamSubscription? _walletSubscription;

  @override
  void initState() {
    super.initState();
    _fetchFirstPage();
    _subscribeToWalletUpdates();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _isLoadMore &&
        _paginationError == null &&
        !_isFirstLoad) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchFirstPage() async {
    setState(() {
      _isFirstLoad = true;
      _firstLoadError = null;
      _paginationError = null;
      _currentPage = 0;
    });

    try {
      final data = await widget.api.fetchEarnings(widget.userId);
      if (!mounted) return;
      setState(() {
        _earnings.clear();
        _earnings.addAll(data);
        _isLoadMore = data.isNotEmpty;
        _isFirstLoad = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _firstLoadError = 'Failed to load earnings. Tap to retry.';
        _isFirstLoad = false;
      });
    }
  }

  Future<void> _fetchNextPage() async {
    setState(() {
      _isLoadingMore = true;
      _paginationError = null;
    });

    try {
      final nextPage = _currentPage + 1;
      final data = await widget.api.fetchEarnings(widget.userId, page: nextPage);
      if (!mounted) return;

      setState(() {
        _currentPage = nextPage;
        _earnings.addAll(data);
        _isLoadMore = data.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paginationError = 'Could not load more items.';
        _isLoadingMore = false;
      });
    }
  }

  void _subscribeToWalletUpdates() {
    _walletSubscription = widget.api.walletUpdates(widget.userId).listen((
      update,
    ) {
      if (!mounted) return;
      setState(() {
        _earnings.insert(0, update.toEarning());
      });
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _walletSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: RefreshIndicator(
        onRefresh: _fetchFirstPage,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_firstLoadError != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_firstLoadError!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchFirstPage,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_earnings.isEmpty) {
      return const Center(child: Text('No earnings history yet.'));
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _earnings.length + 1,
      itemBuilder: (context, index) {
        if (index < _earnings.length) {
          final earning = _earnings[index];
          return ListTile(
            title: Text('Earning #${earning.id}'),
            subtitle: Text(earning.formattedAmount),
            onTap: () async {
              try {
                final detail = await widget.api.fetchDetail(earning.id);
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(detail: detail),
                  ),
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not fetch details.')),
                );
              }
            },
          );
        }

        // Bottom Pagination State Handler
        if (_paginationError != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(_paginationError!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _fetchNextPage,
                  child: const Text('Retry Loading Page'),
                ),
              ],
            ),
          );
        }

        if (_isLoadMore) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'End of earnings history',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}