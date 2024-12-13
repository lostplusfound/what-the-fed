import 'package:civic_project/models/bill.dart';
import 'package:civic_project/models/bill_action.dart';
import 'package:civic_project/models/text_version.dart';
import 'package:civic_project/widgets/action_tile.dart';
import 'package:civic_project/widgets/ai_chat.dart';
import 'package:civic_project/widgets/member_tile.dart';
import 'package:civic_project/widgets/pdf.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BillPage extends StatefulWidget {
  final Bill _bill;
  const BillPage(this._bill, {super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  static const int _pageSize = 10;
  final List<bool> _isPanelExpanded = [false, false, false, false];
  late final Future<TextVersion> _latestTextVersionFuture;
  final PagingController<int, BillAction> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _latestTextVersionFuture = widget._bill.latestTextVersion;
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await widget._bill.actions(offset: pageKey, limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget._bill.type} ${widget._bill.number}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              widget._bill.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            )),
          ),
          Text(
            'Latest Action',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Card(child: ActionTile(action: widget._bill.latestAction)),
          Text(
            'Sponsor',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          _buildSponsorTile(),
          ExpansionPanelList(
              expansionCallback: (panelIndex, isExpanded) => setState(() {
                    _isPanelExpanded[panelIndex] = isExpanded;
                  }),
              children: [
                ExpansionPanel(
                    isExpanded: _isPanelExpanded[0],
                    headerBuilder: (context, isExpanded) =>
                        const ListTile(title: Text('Cosponsors')),
                    body: Container(child: _buildCosponsorList())),
                ExpansionPanel(
                    isExpanded: _isPanelExpanded[1],
                    headerBuilder: (context, isExpanded) =>
                        const ListTile(title: Text('Actions')),
                    body: PagedListView<int, BillAction>(
                        shrinkWrap: true,
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<BillAction>(
                            itemBuilder: (context, item, index) => Card(
                                  child: ActionTile(action: item),
                                )))),
                ExpansionPanel(
                    isExpanded: _isPanelExpanded[2],
                    headerBuilder: (context, isExpanded) =>
                        const ListTile(title: Text('AI Summary')),
                    body: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: _buildAiTile())),
                ExpansionPanel(
                    isExpanded: _isPanelExpanded[3],
                    headerBuilder: (context, isExpanded) =>
                        const ListTile(title: Text('Full PDF')),
                    body: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: _buildPdfTile())),
              ]),
        ]),
      ),
    );
  }

  Widget _buildAiTile() {
    return FutureBuilder(
      future: _latestTextVersionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: AiChat(
                url: snapshot.data!.pdfUrl,
                initialQuery: 'Summarize this bill',
              ));
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildPdfTile() {
    return FutureBuilder(
        future: _latestTextVersionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Pdf(uri: snapshot.data!.pdfUrl));
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }

  Widget _buildSponsorTile() {
    return FutureBuilder(
        future: widget._bill.sponsor,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            return Card(
              child: MemberTile(snapshot.data!),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }

  Widget _buildCosponsorList() {
    return FutureBuilder(
        future: widget._bill.cosponsors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            return Card(
                child: ListView(
              shrinkWrap: true,
              children:
                  snapshot.data!.map((member) => MemberTile(member)).toList(),
            ));
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }
}
