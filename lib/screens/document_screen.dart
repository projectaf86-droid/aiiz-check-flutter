import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';
import 'export_screen.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({
    super.key,
  });

  @override
  State<DocumentScreen> createState() {
    return _DocumentScreenState();
  }
}

class _DocumentScreenState extends State<DocumentScreen> {
  late final TextEditingController titleController;
  late final TextEditingController placeController;
  late final TextEditingController picController;

  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: appStore.documentTitle,
    );

    placeController = TextEditingController(
      text: appStore.place,
    );

    picController = TextEditingController(
      text: appStore.personInCharge,
    );

    selectedMonth = appStore.month;
    selectedYear = appStore.year;

    appStore.addListener(_refresh);
  }

  @override
  void dispose() {
    appStore.removeListener(_refresh);

    titleController.dispose();
    placeController.dispose();
    picController.dispose();

    super.dispose();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // =====================================================
        // JUDUL
        // =====================================================

        Text(
          'Buat / Edit Dokumen',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Ubah bulan, tahun, tempat, penanggung jawab, dan daftar kegiatan langsung dari aplikasi.',
        ),

        const SizedBox(height: 18),

        // =====================================================
        // NAMA DOKUMEN
        // =====================================================

        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Nama Dokumen',
            prefixIcon: Icon(
              Icons.description_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // =====================================================
        // TEMPAT
        // =====================================================

        TextField(
          controller: placeController,
          decoration: const InputDecoration(
            labelText: 'Tempat / Bagian',
            prefixIcon: Icon(
              Icons.business_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // =====================================================
        // PENANGGUNG JAWAB
        // =====================================================

        TextField(
          controller: picController,
          decoration: const InputDecoration(
            labelText: 'Penanggung Jawab',
            prefixIcon: Icon(
              Icons.person_outline,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // =====================================================
        // BULAN & TAHUN
        // =====================================================

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Bulan',
                  prefixIcon: Icon(
                    Icons.calendar_month_outlined,
                  ),
                ),
                items: List.generate(
                  12,
                  (index) {
                    final month = index + 1;

                    return DropdownMenuItem<int>(
                      value: month,
                      child: Text(
                        DateFormat.MMMM(
                          'id_ID',
                        ).format(
                          DateTime(
                            2026,
                            month,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedMonth = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Tahun',
                  prefixIcon: Icon(
                    Icons.event_outlined,
                  ),
                ),
                items: List.generate(
                  12,
                  (index) => 2024 + index,
                ).map(
                  (year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(
                        '$year',
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // =====================================================
        // SIMPAN PENGATURAN
        // =====================================================

        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: _saveDocumentSettings,
            icon: const Icon(
              Icons.save_outlined,
            ),
            label: const Text(
              'Simpan Pengaturan Dokumen',
            ),
          ),
        ),

        const SizedBox(height: 26),

        // =====================================================
        // HEADER DAFTAR KEGIATAN
        // =====================================================

        Row(
          children: [
            Expanded(
              child: Text(
                'Daftar Kegiatan (${appStore.activities.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            FilledButton.tonalIcon(
              onPressed: () {
                _activityDialog(
                  context,
                );
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Tambah',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =====================================================
        // DAFTAR KEGIATAN
        // =====================================================

        ReorderableListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              appStore.activities.length,
          onReorder: (
            oldIndex,
            newIndex,
          ) {
            appStore.moveActivity(
              oldIndex,
              newIndex,
            );
          },
          itemBuilder: (
            context,
            index,
          ) {
            final activity =
                appStore.activities[index];

            return Card(
              key: ValueKey(
                activity.id,
              ),
              margin: const EdgeInsets.only(
                bottom: 8,
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),

                leading: CircleAvatar(
                  child: Text(
                    '${index + 1}',
                  ),
                ),

                title: Text(
                  activity.name,
                ),

                trailing: Wrap(
                  spacing: 2,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    // ==========================================
                    // EDIT
                    // ==========================================

                    IconButton(
                      tooltip: 'Edit kegiatan',
                      onPressed: () {
                        _activityDialog(
                          context,
                          id: activity.id,
                          initial:
                              activity.name,
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                    ),

                    // ==========================================
                    // HAPUS
                    // ==========================================

                    IconButton(
                      tooltip: 'Hapus kegiatan',
                      onPressed: () {
                        _deleteActivity(
                          context,
                          activity.id,
                          activity.name,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),

                    // ==========================================
                    // DRAG
                    // ==========================================

                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(
                          8,
                        ),
                        child: Icon(
                          Icons.drag_handle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // =====================================================
        // PREVIEW EXPORT PRINT
        // =====================================================

        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ExportScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.print_outlined,
            ),
            label: const Text(
              'Preview, Export & Print',
            ),
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  // ============================================================
  // SIMPAN DOKUMEN
  // ============================================================

  void _saveDocumentSettings() {
    appStore.updateDocument(
      title: titleController.text,
      newPlace: placeController.text,
      pic: picController.text,
      newMonth: selectedMonth,
      newYear: selectedYear,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Pengaturan dokumen berhasil disimpan.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // DIALOG TAMBAH / EDIT KEGIATAN
  //
  // Tidak memakai TextEditingController.
  // Jadi aman dari error:
  // "TextEditingController was used after being disposed."
  // ============================================================

  Future<void> _activityDialog(
    BuildContext context, {
    String? id,
    String initial = '',
  }) async {
    String activityName = initial;

    final value =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: Text(
            id == null
                ? 'Tambah Kegiatan'
                : 'Edit Kegiatan',
          ),

          content: TextFormField(
            initialValue: initial,
            autofocus: true,
            textCapitalization:
                TextCapitalization.sentences,

            decoration:
                const InputDecoration(
              labelText: 'Nama Kegiatan',
              hintText:
                  'Contoh: Membersihkan lantai',
              prefixIcon: Icon(
                Icons
                    .cleaning_services_outlined,
              ),
            ),

            onChanged: (text) {
              activityName = text;
            },

            onFieldSubmitted: (text) {
              final result =
                  text.trim();

              if (result.isEmpty) {
                return;
              }

              Navigator.of(
                dialogContext,
              ).pop(
                result,
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'Batal',
              ),
            ),

            FilledButton.icon(
              onPressed: () {
                final result =
                    activityName.trim();

                if (result.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Nama kegiatan tidak boleh kosong.',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(
                  result,
                );
              },
              icon: const Icon(
                Icons.save_outlined,
              ),
              label: const Text(
                'Simpan',
              ),
            ),
          ],
        );
      },
    );

    if (value == null ||
        value.trim().isEmpty) {
      return;
    }

    // Tunggu dialog selesai dilepas dari widget tree.
    await Future<void>.delayed(
      const Duration(
        milliseconds: 120,
      ),
    );

    if (!mounted) {
      return;
    }

    if (id == null) {
      // ========================================================
      // TAMBAH
      // ========================================================

      appStore.addActivity(
        value,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Kegiatan "$value" berhasil ditambahkan.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } else {
      // ========================================================
      // EDIT
      // ========================================================

      appStore.editActivity(
        id,
        value,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Kegiatan berhasil diperbarui.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ============================================================
  // HAPUS KEGIATAN
  // ============================================================

  Future<void> _deleteActivity(
    BuildContext context,
    String id,
    String name,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Hapus Kegiatan?',
          ),

          content: Text(
            'Kegiatan "$name" akan dihapus.\n\n'
            'Semua tanda centang yang berkaitan dengan kegiatan ini juga akan dihapus.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: const Text(
                'Batal',
              ),
            ),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              icon: const Icon(
                Icons.delete_outline,
              ),
              label: const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    await Future<void>.delayed(
      const Duration(
        milliseconds: 120,
      ),
    );

    if (!mounted) {
      return;
    }

    appStore.removeActivity(
      id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Kegiatan berhasil dihapus.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }
}