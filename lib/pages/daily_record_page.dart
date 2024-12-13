import 'package:civic_project/models/congressional_record.dart';
import 'package:civic_project/services/congress_api_service.dart';
import 'package:civic_project/widgets/congressional_record_tile.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DailyRecordPage extends StatefulWidget {
  const DailyRecordPage({super.key});

  @override
  State<DailyRecordPage> createState() => _DailyRecordPageState();
}

class _DailyRecordPageState extends State<DailyRecordPage> {
  static const _pageSize = 10;
  final PagingController<int, CongressionalRecord> _pagingController =
      PagingController(firstPageKey: 0);
  final _yearController = TextEditingController();
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  bool _filtering = false;
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    List<CongressionalRecord> newItems;
    if (_filtering) {
      final int? y = int.tryParse(_yearController.text);
      final int? m = int.tryParse(_monthController.text);
      final int? d = int.tryParse(_dayController.text);
      newItems = await CongressApiService.fetchCongressionalRecordsByDate(
          limit: _pageSize, offset: pageKey, year: y, month: m, day: d);
    } else {
      newItems = await CongressApiService.fetchLatestCongressionalRecords(
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
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Text('Filters:'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _yearController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Year (required)'),
              )),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: TextField(
                controller: _monthController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Month (optional)'),
              )),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                  child: TextField(
                controller: _dayController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Day (optional)'),
              )),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(4.0),
            child: (_filtering)
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _filtering = false;
                      });
                      _pagingController.refresh();
                    },
                    child: const Text('Reset'))
                : TextButton(
                    onPressed: () {
                      setState(() {
                        _filtering = true;
                      });
                      _pagingController.refresh();
                    },
                    child: const Text('Apply'))),
        Expanded(
          child: PagedListView<int, CongressionalRecord>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<CongressionalRecord>(
                  itemBuilder: (context, item, index) =>
                      CongressionalRecordTile(record: item))),
        )
      ],
    );
  }
}
