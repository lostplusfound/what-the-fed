import 'package:civic_project/models/bill.dart';
import 'package:civic_project/widgets/bill_tile.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:civic_project/services/congress_api_service.dart';

class LegislationPage extends StatefulWidget {
  const LegislationPage({super.key});

  @override
  State<LegislationPage> createState() => _LegislationPageState();
}

class _LegislationPageState extends State<LegislationPage> {
  static const _pageSize = 10;
  final PagingController<int, Bill> _pagingController =
      PagingController(firstPageKey: 0);
  final _congressController = TextEditingController();
  final _typeController = TextEditingController();
  final _numController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _congressController.dispose();
    _typeController.dispose();
    _numController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    List<Bill> newItems = [];
    if (_searching) {
      newItems = [
        await CongressApiService.fetchBillByCongressTypeAndNumber(
            int.tryParse(_congressController.text) ??
                CongressApiService.currentCongress(),
            _typeController.text.replaceAll(RegExp(r'[^a-zA-Z]'), ''),
            _numController.text)
      ];
    } else {
      newItems = await CongressApiService.fetchBills(
          limit: _pageSize, offset: pageKey);
    }
    bool isLastPage = newItems.length < _pageSize;
    if (isLastPage) {
      _pagingController.appendLastPage(newItems);
    } else {
      final nextPageKey = pageKey + newItems.length;
      _pagingController.appendPage(newItems, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(4.0), child: Text('Search:')),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _congressController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Congress (optional)'),
              )),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: TextField(
                controller: _typeController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Type (required)'),
              )),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: TextField(
                controller: _numController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Number (required)'),
              )),
              const SizedBox(
                width: 8.0,
              ),
              (_searching)
                  ? IconButton(
                      onPressed: _toggleSearch,
                      icon: const Icon(Icons.cancel_outlined))
                  : IconButton(
                      onPressed: _toggleSearch, icon: const Icon(Icons.search)),
            ],
          ),
        ),
        Expanded(
          child: PagedListView<int, Bill>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Bill>(
                  itemBuilder: (context, item, index) => BillTile(item))),
        )
      ],
    );
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
    });
    _pagingController.refresh();
  }
}
