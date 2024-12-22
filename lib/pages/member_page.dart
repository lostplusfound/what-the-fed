import 'package:civic_project/models/bill.dart';
import 'package:civic_project/models/member.dart';
import 'package:civic_project/widgets/ai_chat.dart';
import 'package:civic_project/widgets/bill_tile.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MemberPage extends StatefulWidget {
  final Member _m;

  const MemberPage(this._m, {super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  static const int _pageSize = 10;
  final List<bool> _isPanelExpanded = [false, false, false, false];
  final PagingController<int, Bill> _sponsoredLegislationController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Bill> _cosponsoredLegislationController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _sponsoredLegislationController
        .addPageRequestListener((pageKey) => _fetchSponsoredPage(pageKey));
    _cosponsoredLegislationController
        .addPageRequestListener((pageKey) => _fetchCosponsoredPage(pageKey));
  }

  @override
  void dispose() {
    _sponsoredLegislationController.dispose();
    _cosponsoredLegislationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSponsoredPage(int pageKey) async {
    try {
      final newItems = await widget._m
          .sponsoredLegislation(offset: pageKey, limit: _pageSize * 5);
      // multiply page size by 5 because some legislation are amendments
      // Amenmdents won't be included in the list of bills,
      // so the infinite scroll pagination thinks it's the end of the page
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _sponsoredLegislationController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _sponsoredLegislationController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _sponsoredLegislationController.error = error;
    }
  }

  Future<void> _fetchCosponsoredPage(int pageKey) async {
    try {
      final newItems = await widget._m
          .cosponsoredLegislation(offset: pageKey, limit: _pageSize * 10);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _cosponsoredLegislationController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _cosponsoredLegislationController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _cosponsoredLegislationController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._m.name),
      ),
      body: ListView(
        children: [
          Text(
            widget._m.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            'State: ${widget._m.state}${(widget._m.memberType == 'Representative') ? ' District: ${widget._m.district ?? 'at-large'}' : ''}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            'Chamber: ${widget._m.chamber}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            'Party: ${widget._m.partyName}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            'Current Term: ${widget._m.terms.last.startYear}-${widget._m.terms.last.endYear ?? 'Present'}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) => setState(() {
              _isPanelExpanded[panelIndex] = isExpanded;
            }),
            children: [
              ExpansionPanel(
                  isExpanded: _isPanelExpanded[0],
                  headerBuilder: (context, isExpanded) =>
                      const ListTile(title: Text('Terms')),
                  body: _buildTermsList()),
              ExpansionPanel(
                  isExpanded: _isPanelExpanded[1],
                  headerBuilder: (context, isExpanded) =>
                      const ListTile(title: Text('AI Biography')),
                  body: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: AiChat(
                      initialQuery: 'Give me a biography on ${widget._m.name}',
                    ),
                  )),
              ExpansionPanel(
                  isExpanded: _isPanelExpanded[2],
                  headerBuilder: (context, isExpanded) =>
                      const ListTile(title: Text('Sponsored Legislation')),
                  body: PagedListView<int, Bill>(
                      shrinkWrap: true,
                      pagingController: _sponsoredLegislationController,
                      builderDelegate: PagedChildBuilderDelegate<Bill>(
                          itemBuilder: (context, item, index) =>
                              BillTile(item)))),
              ExpansionPanel(
                  isExpanded: _isPanelExpanded[3],
                  headerBuilder: (context, isExpanded) =>
                      const ListTile(title: Text('Cosponsored Legislation')),
                  body: PagedListView<int, Bill>(
                      shrinkWrap: true,
                      pagingController: _cosponsoredLegislationController,
                      builderDelegate: PagedChildBuilderDelegate<Bill>(
                          itemBuilder: (context, item, index) =>
                              BillTile(item))))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTermsList() {
    return ListView(
      shrinkWrap: true,
      children: widget._m.terms
          .map((term) => Card(child: ListTile(title: Text(term.toString()))))
          .toList(),
    );
  }
}
