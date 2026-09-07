import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models.dart';
import '../services/export_service.dart';

class ExportScreen
    extends StatefulWidget {
  const ExportScreen({
    super.key,
  });

  @override
  State<ExportScreen>
      createState() =>
          _ExportScreenState();
}

class _ExportScreenState
    extends State<ExportScreen> {
  final ExportOptions options =
      ExportOptions();

  final TransformationController
      transformationController =
      TransformationController();

  Future<Uint8List>? previewFuture;

  bool busy = false;

  double zoom = 1.0;

  @override
  void initState() {
    super.initState();

    previewFuture =
        _buildPreview();
  }

  @override
  void dispose() {
    transformationController
        .dispose();

    super.dispose();
  }

  // ============================================================
  // BUAT PREVIEW HD
  // ============================================================

  Future<Uint8List>
      _buildPreview() async {
    final pdfBytes =
        await ExportService
            .buildPdf(
      options,
    );

    final raster =
        await Printing.raster(
      pdfBytes,

      // DPI tinggi supaya tulisan preview lebih tajam.
      dpi: 220,

      pages: const [
        0,
      ],
    ).first;

    return raster.toPng();
  }

  // ============================================================
  // REFRESH PREVIEW
  // ============================================================

  void _refreshPreview() {
    _resetZoom();

    setState(() {
      previewFuture =
          _buildPreview();
    });
  }

  // ============================================================
  // ZOOM
  // ============================================================

  void _setZoom(
    double newZoom,
  ) {
    final value =
        newZoom.clamp(
      0.5,
      4.0,
    );

    setState(() {
      zoom =
          value.toDouble();
    });

    transformationController.value =
        Matrix4.diagonal3Values(
      zoom,
      zoom,
      1,
    );
  }

  void _zoomIn() {
    _setZoom(
      zoom + 0.25,
    );
  }

  void _zoomOut() {
    _setZoom(
      zoom - 0.25,
    );
  }

  void _resetZoom() {
    zoom = 1.0;

    transformationController.value =
        Matrix4.identity();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Export & Print',
        ),
      ),

      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final desktop =
              constraints.maxWidth >=
                  1000;

          if (desktop) {
            return Padding(
              padding:
                  const EdgeInsets.all(
                12,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  SizedBox(
                    width:
                        380,
                    child:
                        _settingsPanel(),
                  ),

                  const SizedBox(
                    width:
                        12,
                  ),

                  Expanded(
                    child:
                        _previewPanel(),
                  ),
                ],
              ),
            );
          }

          // ====================================================
          // ANDROID / MOBILE
          // ====================================================

          return ListView(
            padding:
                const EdgeInsets.all(
              12,
            ),
            children: [
              _settingsPanel(),

              const SizedBox(
                height: 12,
              ),

              SizedBox(
                height: 650,
                child:
                    _previewPanel(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // PANEL SETTINGS
  // ============================================================

  Widget _settingsPanel() {
    return Card(
      margin:
          EdgeInsets.zero,

      clipBehavior:
          Clip.antiAlias,

      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          18,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,

          children: [
            Text(
              'Pengaturan Kertas',

              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =================================================
            // KERTAS
            // =================================================

            DropdownButtonFormField<
                PaperKind>(
              value:
                  options.paper,

              isExpanded:
                  true,

              decoration:
                  const InputDecoration(
                labelText:
                    'Ukuran Kertas',

                prefixIcon:
                    Icon(
                  Icons
                      .description_outlined,
                ),
              ),

              items:
                  PaperKind.values
                      .map(
                (
                  paper,
                ) {
                  return DropdownMenuItem<
                      PaperKind>(
                    value:
                        paper,

                    child:
                        Text(
                      ExportService
                          .paperLabel(
                        paper,
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          if (value ==
                              null) {
                            return;
                          }

                          options.paper =
                              value;

                          _refreshPreview();
                        },
            ),

            const SizedBox(
              height: 16,
            ),

            // =================================================
            // ORIENTASI
            // =================================================

            const Text(
              'Orientasi Kertas',

              style:
                  TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            SegmentedButton<bool>(
              segments:
                  const [
                ButtonSegment<
                    bool>(
                  value:
                      true,

                  icon:
                      Icon(
                    Icons
                        .stay_current_landscape,
                  ),

                  label:
                      Text(
                    'Landscape',
                  ),
                ),

                ButtonSegment<
                    bool>(
                  value:
                      false,

                  icon:
                      Icon(
                    Icons
                        .stay_current_portrait,
                  ),

                  label:
                      Text(
                    'Portrait',
                  ),
                ),
              ],

              selected:
                  {
                options
                    .landscape,
              },

              onSelectionChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          options.landscape =
                              value.first;

                          _refreshPreview();
                        },
            ),

            const SizedBox(
              height: 18,
            ),

            // =================================================
            // MARGIN
            // =================================================

            Text(
              'Margin: '
              '${options.marginMm.round()} mm',
            ),

            Slider(
              value:
                  options.marginMm,

              min:
                  4,

              max:
                  20,

              divisions:
                  16,

              label:
                  '${options.marginMm.round()} mm',

              onChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          setState(
                            () {
                              options.marginMm =
                                  value;
                            },
                          );
                        },

              // Jangan render PDF tiap slider bergerak.
              onChangeEnd:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          options.marginMm =
                              value;

                          _refreshPreview();
                        },
            ),

            const Divider(
              height:
                  28,
            ),

            // =================================================
            // LOGO
            // =================================================

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,

              secondary:
                  const Icon(
                Icons
                    .image_outlined,
              ),

              title:
                  const Text(
                'Tampilkan Logo',
              ),

              value:
                  options.showLogo,

              onChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          options.showLogo =
                              value;

                          _refreshPreview();
                        },
            ),

            // =================================================
            // SIGNATURE
            // =================================================

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,

              secondary:
                  const Icon(
                Icons
                    .draw_outlined,
              ),

              title:
                  const Text(
                'Tampilkan Tanda Tangan',
              ),

              value:
                  options
                      .showSignature,

              onChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          options.showSignature =
                              value;

                          _refreshPreview();
                        },
            ),

            // =================================================
            // CATATAN
            // =================================================

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,

              secondary:
                  const Icon(
                Icons
                    .notes_outlined,
              ),

              title:
                  const Text(
                'Tampilkan Catatan',
              ),

              value:
                  options.showNote,

              onChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          options.showNote =
                              value;

                          _refreshPreview();
                        },
            ),

            // =================================================
            // CHECKLIST
            // =================================================

            SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,

              secondary:
                  const Icon(
                Icons
                    .check_box_outlined,
              ),

              title:
                  const Text(
                'Sertakan checklist yang sudah dicentang',
              ),

              subtitle:
                  const Text(
                'Matikan untuk membuat mentahan kosong.',
              ),

              value:
                  options
                      .includeChecks,

              onChanged:
                  busy
                      ? null
                      : (
                          value,
                        ) {
                          options.includeChecks =
                              value;

                          _refreshPreview();
                        },
            ),

            const Divider(
              height:
                  28,
            ),

            // =================================================
            // PDF
            // =================================================

            SizedBox(
              height:
                  48,

              child:
                  FilledButton.icon(
                onPressed:
                    busy
                        ? null
                        : _savePdf,

                icon:
                    const Icon(
                  Icons
                      .picture_as_pdf_outlined,
                ),

                label:
                    const Text(
                  'Simpan PDF',
                ),
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            // =================================================
            // EXCEL
            // =================================================

            SizedBox(
              height:
                  48,

              child:
                  FilledButton
                      .tonalIcon(
                onPressed:
                    busy
                        ? null
                        : _saveExcel,

                icon:
                    const Icon(
                  Icons
                      .table_view_outlined,
                ),

                label:
                    const Text(
                  'Export Excel',
                ),
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            // =================================================
            // PRINT
            // =================================================

            SizedBox(
              height:
                  48,

              child:
                  OutlinedButton.icon(
                onPressed:
                    busy
                        ? null
                        : _print,

                icon:
                    const Icon(
                  Icons
                      .print_outlined,
                ),

                label:
                    const Text(
                  'Print Langsung',
                ),
              ),
            ),

            if (busy) ...[
              const SizedBox(
                height:
                    14,
              ),

              const LinearProgressIndicator(),
            ],

            const SizedBox(
              height:
                  14,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _previewPanel() {
    return Card(
      margin:
          EdgeInsets.zero,

      clipBehavior:
          Clip.antiAlias,

      child: Column(
        children: [
          // ====================================================
          // TOOLBAR ZOOM
          // ====================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            child: Row(
              children: [
                const Icon(
                  Icons
                      .preview_outlined,
                ),

                const SizedBox(
                  width:
                      8,
                ),

                const Expanded(
                  child: Text(
                    'Preview Dokumen',

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                // ==============================================
                // ZOOM OUT
                // ==============================================

                IconButton(
                  tooltip:
                      'Zoom Out',

                  onPressed:
                      zoom >
                              0.5
                          ? _zoomOut
                          : null,

                  icon:
                      const Icon(
                    Icons
                        .zoom_out,
                  ),
                ),

                // ==============================================
                // PERCENT
                // ==============================================

                Container(
                  constraints:
                      const BoxConstraints(
                    minWidth:
                        58,
                  ),

                  alignment:
                      Alignment.center,

                  child: Text(
                    '${(zoom * 100).round()}%',

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                // ==============================================
                // ZOOM IN
                // ==============================================

                IconButton(
                  tooltip:
                      'Zoom In',

                  onPressed:
                      zoom <
                              4
                          ? _zoomIn
                          : null,

                  icon:
                      const Icon(
                    Icons
                        .zoom_in,
                  ),
                ),

                // ==============================================
                // RESET
                // ==============================================

                IconButton(
                  tooltip:
                      'Reset Zoom',

                  onPressed:
                      () {
                        setState(
                          () {
                            _resetZoom();
                          },
                        );
                      },

                  icon:
                      const Icon(
                    Icons
                        .center_focus_strong,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height:
                1,
          ),

          // ====================================================
          // AREA PREVIEW
          // ====================================================

          Expanded(
            child:
                Container(
              color:
                  Theme.of(
                context,
              )
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(
                        0.4,
                      ),

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child:
                  FutureBuilder<
                      Uint8List>(
                future:
                    previewFuture,

                builder:
                    (
                  context,
                  snapshot,
                ) {
                  if (snapshot
                          .connectionState !=
                      ConnectionState
                          .done) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot
                          .hasError ||
                      snapshot.data ==
                          null) {
                    return Center(
                      child:
                          Text(
                        'Gagal membuat preview.\n'
                        '${snapshot.error ?? ''}',
                        textAlign:
                            TextAlign.center,
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      return ClipRect(
                        child:
                            InteractiveViewer(
                          transformationController:
                              transformationController,

                          minScale:
                              0.5,

                          maxScale:
                              4,

                          boundaryMargin:
                              const EdgeInsets
                                  .all(
                            300,
                          ),

                          panEnabled:
                              true,

                          scaleEnabled:
                              true,

                          onInteractionEnd:
                              (_) {
                            final current =
                                transformationController
                                    .value
                                    .getMaxScaleOnAxis();

                            setState(
                              () {
                                zoom =
                                    current.clamp(
                                  0.5,
                                  4.0,
                                );
                              },
                            );
                          },

                          child:
                              Center(
                            child:
                                Image.memory(
                              snapshot.data!,

                              width:
                                  constraints
                                          .maxWidth *
                                      0.94,

                              fit:
                                  BoxFit
                                      .contain,

                              filterQuality:
                                  FilterQuality
                                      .high,

                              gaplessPlayback:
                                  true,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ====================================================
          // INFO
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  12,
              vertical:
                  7,
            ),

            child:
                Row(
              children: [
                const Icon(
                  Icons
                      .info_outline,
                  size:
                      16,
                ),

                const SizedBox(
                  width:
                      6,
                ),

                Expanded(
                  child:
                      Text(
                    'Gunakan tombol + / - atau pinch dua jari untuk memperbesar preview.',
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE PDF
  // ============================================================

  Future<void> _savePdf() async {
    setState(() {
      busy =
          true;
    });

    try {
      final result =
          await ExportService
              .savePdf(
        options,
      );

      if (!mounted) {
        return;
      }

      _message(
        result ==
                    null ||
                result.isEmpty
            ? 'PDF berhasil dibuat.'
            : 'PDF berhasil dibuat: $result',
      );
    } catch (e) {
      if (mounted) {
        _message(
          'Gagal membuat PDF: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy =
              false;
        });
      }
    }
  }

  // ============================================================
  // SAVE EXCEL
  // ============================================================

  Future<void> _saveExcel() async {
    setState(() {
      busy =
          true;
    });

    try {
      final result =
          await ExportService
              .saveExcel(
        includeChecks:
            options
                .includeChecks,
      );

      if (!mounted) {
        return;
      }

      _message(
        result ==
                    null ||
                result.isEmpty
            ? 'Excel berhasil dibuat.'
            : 'Excel berhasil dibuat: $result',
      );
    } catch (e) {
      if (mounted) {
        _message(
          'Gagal membuat Excel: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy =
              false;
        });
      }
    }
  }

  // ============================================================
  // PRINT
  // ============================================================

  Future<void> _print() async {
    setState(() {
      busy =
          true;
    });

    try {
      await ExportService
          .printPdf(
        options,
      );
    } catch (e) {
      if (mounted) {
        _message(
          'Gagal membuka printer: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy =
              false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(
    String value,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(
            value,
          ),

          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );
  }
}