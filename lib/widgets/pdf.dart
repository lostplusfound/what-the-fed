import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class Pdf extends StatefulWidget {
  final Uri uri;

  Pdf({super.key, required this.uri});

  @override
  State<Pdf> createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  final PdfViewerController controller = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () => controller.zoomUp(),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () => controller.zoomDown(),
            ),
            IconButton(
              icon: const Icon(Icons.navigate_before_rounded),
              onPressed: () => controller.goToPage(
                  pageNumber: max((controller.pageNumber ?? 1) - 1, 1)),
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next_rounded),
              onPressed: () => controller.goToPage(
                  pageNumber: min(
                      (controller.pageNumber ?? 1) + 1, controller.pageCount)),
            ),
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: () => controller.goToPage(pageNumber: 1),
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: () =>
                  controller.goToPage(pageNumber: controller.pageCount),
            ),
          ],
        ),
        body: PdfViewer.uri(
          widget.uri,
          controller: controller,
          params: PdfViewerParams(
              enableTextSelection: true,
              loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
                return Center(
                  child: CircularProgressIndicator(
                    value: totalBytes != null
                        ? bytesDownloaded / totalBytes
                        : null,
                  ),
                );
              }),
        ));
  }
}
