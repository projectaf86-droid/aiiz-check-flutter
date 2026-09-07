import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../app_state.dart';
import '../models.dart';

class ExportService {
  // ============================================================
  // NAMA BULAN
  // ============================================================

  static String monthName(int month) {
    return DateFormat.MMMM('id_ID').format(
      DateTime(2000, month),
    );
  }

  // ============================================================
  // FORMAT KERTAS
  // ============================================================

  static PdfPageFormat pageFormatFor(
    ExportOptions options,
  ) {
    late PdfPageFormat base;

    switch (options.paper) {
      case PaperKind.a4:
        base = PdfPageFormat.a4;
        break;

      case PaperKind.a5:
        base = PdfPageFormat.a5;
        break;

      case PaperKind.letter:
        base = PdfPageFormat.letter;
        break;

      case PaperKind.legal:
        base = PdfPageFormat.legal;
        break;

      case PaperKind.f4:
        base = PdfPageFormat(
          210 * PdfPageFormat.mm,
          330 * PdfPageFormat.mm,
        );
        break;
    }

    return options.landscape
        ? base.landscape
        : base;
  }

  // ============================================================
  // LABEL KERTAS
  // ============================================================

  static String paperLabel(
    PaperKind kind,
  ) {
    switch (kind) {
      case PaperKind.a4:
        return 'A4 (210 × 297 mm)';

      case PaperKind.a5:
        return 'A5 (148 × 210 mm)';

      case PaperKind.letter:
        return 'Letter';

      case PaperKind.legal:
        return 'Legal';

      case PaperKind.f4:
        return 'F4 / Folio (210 × 330 mm)';
    }
  }

  // ============================================================
  // BUILD PDF
  // ============================================================

  static Future<Uint8List> buildPdf(
    ExportOptions options,
  ) async {
    final store = appStore;

    final pdf = pw.Document();

    final pageFormat = pageFormatFor(
      options,
    );

    final margin =
        options.marginMm *
        PdfPageFormat.mm;

    // ==========================================================
    // LOGO
    // ==========================================================

    pw.MemoryImage? logo;

    if (options.showLogo) {
      try {
        final data = await rootBundle.load(
          'assets/images/app_icon.png',
        );

        logo = pw.MemoryImage(
          data.buffer.asUint8List(),
        );
      } catch (_) {
        logo = null;
      }
    }

    // ==========================================================
    // UKURAN OTOMATIS
    // ==========================================================

    final activityCount =
        store.activities.length;

    double rowHeight;
    double activityFontSize;

    if (activityCount <= 16) {
      rowHeight = 20;
      activityFontSize = 6.5;
    } else if (activityCount <= 20) {
      rowHeight = 18;
      activityFontSize = 6.1;
    } else if (activityCount <= 24) {
      rowHeight = 15.5;
      activityFontSize = 5.7;
    } else if (activityCount <= 30) {
      rowHeight = 13;
      activityFontSize = 5.2;
    } else {
      rowHeight = 11.5;
      activityFontSize = 4.8;
    }

    // ==========================================================
    // HITUNG LEBAR KOLOM
    // ==========================================================

    final availableWidth =
        pageFormat.width -
        (margin * 2);

    const numberColumnWidth = 20.0;

    final activityColumnWidth =
        options.landscape
            ? 150.0
            : 85.0;

    final remainingWidth =
        availableWidth -
        numberColumnWidth -
        activityColumnWidth;

    final dayColumnWidth =
        remainingWidth /
        store.daysInMonth;

    // ==========================================================
    // STYLE
    // ==========================================================

    final titleStyle = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    );

    final monthStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
    );

    final subtitleStyle = pw.TextStyle(
      fontSize: 7,
      fontStyle: pw.FontStyle.italic,
    );

    final headerStyle = pw.TextStyle(
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final activityStyle = pw.TextStyle(
      fontSize: activityFontSize,
    );

    final numberStyle = pw.TextStyle(
      fontSize: 6,
      fontWeight: pw.FontWeight.bold,
    );

    // ==========================================================
    // HEADER CELL
    // ==========================================================

    pw.Widget headerCell(
      String text,
    ) {
      return pw.Container(
        height: 19,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 1,
          vertical: 1,
        ),
        child: pw.Text(
          text,
          style: headerStyle,
          textAlign: pw.TextAlign.center,
          maxLines: 1,
        ),
      );
    }

    // ==========================================================
    // CELL NOMOR
    // ==========================================================

    pw.Widget numberCell(
      String text,
    ) {
      return pw.Container(
        height: rowHeight,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(
          1,
        ),
        child: pw.Text(
          text,
          style: numberStyle,
          textAlign: pw.TextAlign.center,
        ),
      );
    }

    // ==========================================================
    // CELL KEGIATAN
    // ==========================================================

    pw.Widget activityCell(
      String text,
    ) {
      return pw.Container(
        height: rowHeight,
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 3,
          vertical: 1,
        ),
        child: pw.Text(
          text,
          style: activityStyle,
          maxLines: 2,
        ),
      );
    }

    // ==========================================================
    // CELL CHECKLIST
    // ==========================================================

    pw.Widget checkCell(
      bool checked,
    ) {
      return pw.Container(
        height: rowHeight,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(
          1,
        ),
        child: checked
            ? pw.Text(
                'V',
                style: numberStyle,
                textAlign: pw.TextAlign.center,
              )
            : null,
      );
    }

    // ==========================================================
    // BUAT ROW TABLE
    // ==========================================================

    final rows = <pw.TableRow>[];

    // HEADER
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          color: PdfColors.blueGrey900,
        ),
        children: [
          headerCell(
            'No',
          ),
          headerCell(
            'Kegiatan',
          ),
          ...List.generate(
            store.daysInMonth,
            (index) {
              return headerCell(
                '${index + 1}',
              );
            },
          ),
        ],
      ),
    );

    // DATA
    for (
      var index = 0;
      index < store.activities.length;
      index++
    ) {
      final activity =
          store.activities[index];

      rows.add(
        pw.TableRow(
          children: [
            numberCell(
              '${index + 1}',
            ),
            activityCell(
              activity.name,
            ),
            ...List.generate(
              store.daysInMonth,
              (dayIndex) {
                final checked =
                    options.includeChecks &&
                    store.isChecked(
                      activity.id,
                      dayIndex + 1,
                    );

                return checkCell(
                  checked,
                );
              },
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // COLUMN WIDTH
    // ==========================================================

    final columnWidths =
        <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(
        numberColumnWidth,
      ),
      1: pw.FixedColumnWidth(
        activityColumnWidth,
      ),
      for (
        var index = 0;
        index < store.daysInMonth;
        index++
      )
        index + 2: pw.FixedColumnWidth(
          dayColumnWidth,
        ),
    };

    // ==========================================================
    // PDF PAGE
    // ==========================================================

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(
          margin,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.stretch,
            children: [
              // =================================================
              // HEADER DOKUMEN
              // =================================================

              pw.Row(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.center,
                children: [
                  if (logo != null) ...[
                    pw.Container(
                      width: 38,
                      height: 38,
                      alignment:
                          pw.Alignment.center,
                      padding:
                          const pw.EdgeInsets.all(
                        2,
                      ),
                      child: pw.Image(
                        logo,
                        width: 34,
                        height: 34,
                      ),
                    ),
                    pw.SizedBox(
                      width: 8,
                    ),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          store.documentTitle,
                          textAlign:
                              pw.TextAlign.center,
                          style: titleStyle,
                        ),
                        pw.SizedBox(
                          height: 2,
                        ),
                        pw.Text(
                          '${monthName(store.month)} ${store.year}',
                          textAlign:
                              pw.TextAlign.center,
                          style: monthStyle,
                        ),
                        pw.Text(
                          'Lembar Kontrol Pekerjaan Harian',
                          textAlign:
                              pw.TextAlign.center,
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  if (logo != null)
                    pw.SizedBox(
                      width: 46,
                    ),
                ],
              ),

              pw.SizedBox(
                height: 7,
              ),

              // =================================================
              // INFORMASI TEMPAT
              // =================================================

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey700,
                  width: 0.6,
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(
                    1,
                  ),
                  1: pw.FlexColumnWidth(
                    1,
                  ),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        height: 26,
                        alignment:
                            pw.Alignment.centerLeft,
                        padding:
                            const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        child: pw.Text(
                          'Tempat / Bagian: ${store.place}',
                          style: pw.TextStyle(
                            fontSize: 7.2,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        height: 26,
                        alignment:
                            pw.Alignment.centerLeft,
                        padding:
                            const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        child: pw.Text(
                          'Penanggung Jawab: ${store.personInCharge}',
                          style: pw.TextStyle(
                            fontSize: 7.2,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(
                height: 6,
              ),

              // =================================================
              // TABLE CHECKLIST
              // =================================================

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey600,
                  width: 0.45,
                ),
                defaultVerticalAlignment:
                    pw.TableCellVerticalAlignment.middle,
                columnWidths: columnWidths,
                children: rows,
              ),

              // =================================================
              // CATATAN
              // =================================================

              if (options.showNote) ...[
                pw.SizedBox(
                  height: 6,
                ),
                pw.Text(
                  'Catatan: Beri tanda V pada tanggal setelah pekerjaan selesai. '
                  'Kotak kosong berarti pekerjaan belum dikerjakan atau belum dicatat.',
                  style: pw.TextStyle(
                    fontSize: 6.4,
                  ),
                ),
              ],

              // =================================================
              // TANDA TANGAN
              // =================================================

              if (options.showSignature) ...[
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceAround,
                  children: [
                    _signature(
                      'Petugas',
                    ),
                    _signature(
                      'Penanggung Jawab',
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // SIGNATURE
  // ============================================================

  static pw.Widget _signature(
    String title,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          '$title,',
          style: pw.TextStyle(
            fontSize: 6.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(
          height: 26,
        ),
        pw.Text(
          '(....................................)',
          style: pw.TextStyle(
            fontSize: 6.2,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE PDF
  // ============================================================

  static Future<String?> savePdf(
    ExportOptions options,
  ) async {
    final bytes =
        await buildPdf(
      options,
    );

    // WEB
    if (kIsWeb) {
      return FileSaver.instance.saveFile(
        name: _fileName(
          'Checklist',
        ),
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
    }

    // ANDROID / WINDOWS
    // Membuka pilihan lokasi penyimpanan.
    return FileSaver.instance.saveAs(
      name: _fileName(
        'Checklist',
      ),
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  // ============================================================
  // PRINT
  // ============================================================

  static Future<void> printPdf(
    ExportOptions options,
  ) async {
    final bytes =
        await buildPdf(
      options,
    );

    await Printing.layoutPdf(
      format: pageFormatFor(
        options,
      ),
      onLayout: (_) async {
        return bytes;
      },
      name:
          '${_fileName('Checklist')}.pdf',
    );
  }

  // ============================================================
  // SAVE EXCEL
  // ============================================================

  static Future<String?> saveExcel({
    bool includeChecks = true,
  }) async {
    final bytes =
        buildExcel(
      includeChecks:
          includeChecks,
    );

    // WEB
    if (kIsWeb) {
      return FileSaver.instance.saveFile(
        name: _fileName(
          'Checklist',
        ),
        bytes: bytes,
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }

    // ANDROID / WINDOWS
    return FileSaver.instance.saveAs(
      name: _fileName(
        'Checklist',
      ),
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  // ============================================================
  // BUILD EXCEL
  // ============================================================

  static Uint8List buildExcel({
    bool includeChecks = true,
  }) {
    final store =
        appStore;

    final excel =
        Excel.createExcel();

    final sheet =
        excel['Checklist'];

    // Hapus Sheet1 default
    if (
      excel.tables.containsKey(
        'Sheet1',
      ) &&
      excel.tables.length > 1
    ) {
      excel.delete(
        'Sheet1',
      );
    }

    // ==========================================================
    // HEADER
    // ==========================================================

    sheet.appendRow(
      [
        TextCellValue(
          store.documentTitle,
        ),
      ],
    );

    sheet.appendRow(
      [
        TextCellValue(
          '${monthName(store.month)} ${store.year}',
        ),
      ],
    );

    sheet.appendRow(
      [
        TextCellValue(
          'Tempat / Bagian',
        ),
        TextCellValue(
          store.place,
        ),
      ],
    );

    sheet.appendRow(
      [
        TextCellValue(
          'Penanggung Jawab',
        ),
        TextCellValue(
          store.personInCharge,
        ),
      ],
    );

    sheet.appendRow(
      [],
    );

    // ==========================================================
    // HEADER TABLE
    // ==========================================================

    sheet.appendRow(
      [
        TextCellValue(
          'No',
        ),
        TextCellValue(
          'Kegiatan',
        ),
        ...List.generate(
          store.daysInMonth,
          (index) {
            return TextCellValue(
              '${index + 1}',
            );
          },
        ),
      ],
    );

    // ==========================================================
    // DATA
    // ==========================================================

    for (
      var index = 0;
      index < store.activities.length;
      index++
    ) {
      final activity =
          store.activities[index];

      sheet.appendRow(
        [
          IntCellValue(
            index + 1,
          ),
          TextCellValue(
            activity.name,
          ),
          ...List.generate(
            store.daysInMonth,
            (dayIndex) {
              final checked =
                  includeChecks &&
                  store.isChecked(
                    activity.id,
                    dayIndex + 1,
                  );

              return TextCellValue(
                checked
                    ? 'V'
                    : '',
              );
            },
          ),
        ],
      );
    }

    // ==========================================================
    // COLUMN WIDTH EXCEL
    // ==========================================================

    sheet.setColumnWidth(
      0,
      5,
    );

    sheet.setColumnWidth(
      1,
      42,
    );

    for (
      var index = 2;
      index < store.daysInMonth + 2;
      index++
    ) {
      sheet.setColumnWidth(
        index,
        4.5,
      );
    }

    // ==========================================================
    // STYLE HEADER EXCEL
    // ==========================================================

    final headerStyle =
        CellStyle(
      bold: true,
      horizontalAlign:
          HorizontalAlign.Center,
      verticalAlign:
          VerticalAlign.Center,
      backgroundColorHex:
          ExcelColor.fromHexString(
        '#D9EAF7',
      ),
      textWrapping:
          TextWrapping.WrapText,
    );

    for (
      var column = 0;
      column < store.daysInMonth + 2;
      column++
    ) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: column,
              rowIndex: 5,
            ),
          )
          .cellStyle = headerStyle;
    }

    // ==========================================================
    // ENCODE
    // ==========================================================

    final encoded =
        excel.encode();

    if (encoded == null) {
      throw StateError(
        'Gagal membuat file Excel.',
      );
    }

    return Uint8List.fromList(
      encoded,
    );
  }

  // ============================================================
  // FILE NAME
  // ============================================================

  static String _fileName(
    String prefix,
  ) {
    final store =
        appStore;

    final month =
        monthName(
      store.month,
    ).replaceAll(
      ' ',
      '_',
    );

    return '${prefix}_${month}_${store.year}';
  }
}