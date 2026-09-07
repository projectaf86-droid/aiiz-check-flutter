import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool monthly = false;
  int selectedDay = 1;

  @override
  void initState() {
    super.initState();

    // Dengarkan setiap perubahan dari AppStore.
    // Termasuk ketika checklist dicentang / dibatalkan.
    appStore.addListener(_refresh);
  }

  @override
  void dispose() {
    appStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = appStore;

    // Kalau ganti bulan dan jumlah harinya lebih sedikit,
    // tanggal yang dipilih dikembalikan ke tanggal 1.
    if (selectedDay > store.daysInMonth) {
      selectedDay = 1;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: false,
                icon: Icon(
                  Icons.today_outlined,
                ),
                label: Text('Per Hari'),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(
                  Icons.grid_on_outlined,
                ),
                label: Text('Bulanan'),
              ),
            ],
            selected: {
              monthly,
            },
            onSelectionChanged: (value) {
              setState(() {
                monthly = value.first;
              });
            },
          ),
        ),

        Expanded(
          child: monthly
              ? _MonthlyTable(
                  store: store,
                )
              : _DailyChecklist(
                  store: store,
                  selectedDay: selectedDay,
                  onDayChanged: (day) {
                    setState(() {
                      selectedDay = day;
                    });
                  },
                ),
        ),
      ],
    );
  }
}

// ============================================================
// CHECKLIST PER HARI
// ============================================================

class _DailyChecklist extends StatelessWidget {
  const _DailyChecklist({
    required this.store,
    required this.selectedDay,
    required this.onDayChanged,
  });

  final AppStore store;
  final int selectedDay;
  final ValueChanged<int> onDayChanged;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat.MMMM(
      'id_ID',
    ).format(
      DateTime(
        store.year,
        store.month,
      ),
    );

    final checkedCount = store.activities.where(
      (activity) {
        return store.isChecked(
          activity.id,
          selectedDay,
        );
      },
    ).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // =====================================================
        // HEADER
        // =====================================================

        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment:
              WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Checklist $month ${store.year}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$checkedCount dari '
                  '${store.activities.length} '
                  'kegiatan selesai',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),

            DropdownButton<int>(
              value: selectedDay,
              items: List.generate(
                store.daysInMonth,
                (index) {
                  final day = index + 1;

                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text(
                      'Tanggal $day',
                    ),
                  );
                },
              ),
              onChanged: (value) {
                if (value != null) {
                  onDayChanged(value);
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 14),

        // =====================================================
        // DAFTAR KEGIATAN
        // =====================================================

        ...store.activities.map(
          (activity) {
            final checked =
                store.isChecked(
              activity.id,
              selectedDay,
            );

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              clipBehavior: Clip.antiAlias,
              child: CheckboxListTile(
                value: checked,

                // INI BAGIAN PENTING
                // Bisa centang dan bisa hapus centang.
                onChanged: (value) {
                  store.setCheck(
                    activity.id,
                    selectedDay,
                    value ?? false,
                  );
                },

                title: Text(
                  activity.name,
                  style: TextStyle(
                    fontWeight: checked
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),

                secondary: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  child: checked
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey(
                            'checked',
                          ),
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons
                              .radio_button_unchecked,
                          key: ValueKey(
                            'unchecked',
                          ),
                        ),
                ),

                activeColor:
                    const Color(0xFF0A376F),

                controlAffinity:
                    ListTileControlAffinity
                        .trailing,

                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ============================================================
// CHECKLIST BULANAN
// ============================================================

class _MonthlyTable extends StatelessWidget {
  const _MonthlyTable({
    required this.store,
  });

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat.MMMM(
      'id_ID',
    ).format(
      DateTime(
        store.year,
        store.month,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              right: 4,
              bottom: 10,
            ),
            child: Text(
              'Checklist Bulanan '
              '$month ${store.year}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(
                        const Color(
                          0xFF0A376F,
                        ),
                      ),

                      headingTextStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),

                      dataRowMinHeight: 42,
                      dataRowMaxHeight: 62,

                      columns: [
                        const DataColumn(
                          label: Text('No'),
                        ),
                        const DataColumn(
                          label: SizedBox(
                            width: 230,
                            child: Text(
                              'Kegiatan',
                            ),
                          ),
                        ),

                        ...List.generate(
                          store.daysInMonth,
                          (index) {
                            return DataColumn(
                              label: Text(
                                '${index + 1}',
                              ),
                            );
                          },
                        ),
                      ],

                      rows: List.generate(
                        store.activities.length,
                        (index) {
                          final activity =
                              store.activities[
                                  index];

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${index + 1}',
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 230,
                                  child: Text(
                                    activity.name,
                                  ),
                                ),
                              ),

                              ...List.generate(
                                store.daysInMonth,
                                (dayIndex) {
                                  final day =
                                      dayIndex + 1;

                                  final checked =
                                      store.isChecked(
                                    activity.id,
                                    day,
                                  );

                                  return DataCell(
                                    SizedBox(
                                      width: 32,
                                      child:
                                          Checkbox(
                                        value:
                                            checked,
                                        activeColor:
                                            const Color(
                                          0xFF0A376F,
                                        ),

                                        // Bisa ON / OFF
                                        onChanged:
                                            (value) {
                                          store
                                              .setCheck(
                                            activity
                                                .id,
                                            day,
                                            value ??
                                                false,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}