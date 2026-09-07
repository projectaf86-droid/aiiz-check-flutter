import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // PENTING:
    // Rekap otomatis rebuild ketika:
    // - kegiatan ditambah
    // - kegiatan dihapus
    // - checklist dicentang/dihapus
    // - bulan/tahun berubah
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        return _buildRecap(context);
      },
    );
  }

  Widget _buildRecap(
    BuildContext context,
  ) {
    final store = appStore;

    final monthName = DateFormat.MMMM(
      'id_ID',
    ).format(
      DateTime(
        store.year,
        store.month,
      ),
    );

    final totalActivities =
        store.activities.length;

    final totalPossible =
        totalActivities *
        store.daysInMonth;

    final totalChecked =
        store.totalChecked;

    final overallProgress =
        totalPossible == 0
            ? 0.0
            : totalChecked /
                totalPossible;

    final overallPercent =
        (overallProgress * 100)
            .round();

    return ListView(
      padding: const EdgeInsets.all(
        16,
      ),
      children: [
        // =====================================================
        // HEADER
        // =====================================================

        Text(
          'Rekap $monthName ${store.year}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
        ),

        const SizedBox(height: 5),

        Text(
          '$totalChecked dari '
          '$totalPossible checklist selesai '
          '($overallPercent%).',
        ),

        const SizedBox(height: 18),

        // =====================================================
        // RINGKASAN
        // =====================================================

        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isWide =
                constraints.maxWidth >
                    700;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _summaryCard(
                  context,
                  width: isWide
                      ? (
                              constraints
                                  .maxWidth -
                              24
                            ) /
                            3
                      : constraints
                          .maxWidth,
                  icon: Icons
                      .format_list_bulleted,
                  value:
                      '$totalActivities',
                  title:
                      'Total Kegiatan',
                ),

                _summaryCard(
                  context,
                  width: isWide
                      ? (
                              constraints
                                  .maxWidth -
                              24
                            ) /
                            3
                      : constraints
                          .maxWidth,
                  icon: Icons
                      .check_circle_outline,
                  value:
                      '$totalChecked',
                  title:
                      'Checklist Selesai',
                ),

                _summaryCard(
                  context,
                  width: isWide
                      ? (
                              constraints
                                  .maxWidth -
                              24
                            ) /
                            3
                      : constraints
                          .maxWidth,
                  icon:
                      Icons.donut_large,
                  value:
                      '$overallPercent%',
                  title:
                      'Progress Bulan',
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // =====================================================
        // PROGRESS BULAN
        // =====================================================

        Card(
          child: Padding(
            padding:
                const EdgeInsets.all(
              18,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Progress $monthName',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                ),

                const SizedBox(
                  height: 12,
                ),

                LinearProgressIndicator(
                  value:
                      overallProgress,
                  minHeight: 12,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  '$overallPercent% pekerjaan '
                  'bulan ini telah tercatat.',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // =====================================================
        // REKAP PER TANGGAL
        // =====================================================

        Text(
          'Rekap Per Tanggal',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
        ),

        const SizedBox(height: 10),

        ...List.generate(
          store.daysInMonth,
          (index) {
            final day =
                index + 1;

            var completed =
                0;

            // PENTING:
            // hitung berdasarkan activities TERKINI.
            //
            // Kalau dari 16 kegiatan dihapus 1,
            // denominator langsung menjadi 15.
            for (final activity
                in store.activities) {
              if (store.isChecked(
                activity.id,
                day,
              )) {
                completed++;
              }
            }

            final progress =
                totalActivities == 0
                    ? 0.0
                    : completed /
                        totalActivities;

            final percent =
                (progress * 100)
                    .round();

            return Card(
              margin:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child: Padding(
                padding:
                    const EdgeInsets
                        .all(
                  14,
                ),
                child: Row(
                  children: [
                    // ===============================
                    // NOMOR TANGGAL
                    // ===============================

                    CircleAvatar(
                      radius: 29,
                      child: Text(
                        '$day',
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    // ===============================
                    // DETAIL
                    // ===============================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tanggal $day $monthName',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),

                              Text(
                                '$completed/'
                                '$totalActivities',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          LinearProgressIndicator(
                            value:
                                progress,
                            minHeight:
                                9,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(
                            '$percent% selesai',
                            style:
                                Theme.of(
                              context,
                            )
                                    .textTheme
                                    .bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required double width,
    required IconData icon,
    required String value,
    required String title,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                child: Icon(icon),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      value,
                      style:
                          Theme.of(
                        context,
                      )
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                    ),

                    Text(title),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}