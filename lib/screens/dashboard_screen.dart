import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenTab,
  });

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    // PENTING:
    // Dashboard otomatis refresh ketika profil,
    // checklist, kegiatan, bulan, dll berubah.
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        return _buildDashboard(context);
      },
    );
  }

  Widget _buildDashboard(
    BuildContext context,
  ) {
    final store = appStore;

    final user = store.currentUser;

    final monthName =
        DateFormat.MMMM(
      'id_ID',
    ).format(
      DateTime(
        store.year,
        store.month,
      ),
    );

    final now = DateTime.now();

    final selectedDay =
        now.year == store.year &&
                now.month == store.month
            ? now.day
            : 1;

    final todayDone =
        store.activities.where(
      (activity) {
        return store.isChecked(
          activity.id,
          selectedDay,
        );
      },
    ).length;

    // =========================================================
    // FOTO PROFIL
    // =========================================================

    ImageProvider? profilePhoto;

    if (user != null &&
        user.photoBase64.isNotEmpty) {
      try {
        profilePhoto = MemoryImage(
          base64Decode(
            user.photoBase64,
          ),
        );
      } catch (_) {
        profilePhoto = null;
      }
    }

    final displayName =
        user?.name ??
            store.userName;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // =====================================================
        // HEADER PROFIL
        // =====================================================

        Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(
                  0xFF061F49,
                ),
                Color(
                  0xFF0D56B5,
                ),
              ],
            ),

            borderRadius:
                BorderRadius.circular(
              22,
            ),
          ),

          child: Row(
            children: [
              // =================================================
              // FOTO PROFIL
              // =================================================

              Container(
                padding:
                    const EdgeInsets.all(3),

                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),

                child: CircleAvatar(
                  radius: 34,

                  backgroundColor:
                      const Color(
                    0xFFE8F0FF,
                  ),

                  backgroundImage:
                      profilePhoto,

                  child:
                      profilePhoto == null
                          ? Text(
                              displayName
                                      .trim()
                                      .isNotEmpty
                                  ? displayName
                                      .trim()[0]
                                      .toUpperCase()
                                  : 'A',

                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFF0D4EA6,
                                ),
                                fontSize:
                                    28,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            )
                          : null,
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              // =================================================
              // NAMA PENGGUNA
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Halo, $displayName',

                      maxLines: 1,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            22,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Checklist $monthName ${store.year}',

                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize:
                            14,
                      ),
                    ),

                    if (user != null &&
                        user.email
                            .isNotEmpty) ...[
                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        user.email,

                        maxLines: 1,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            const TextStyle(
                          color:
                              Colors.white60,
                          fontSize:
                              12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // =================================================
              // LOGO APP
              // =================================================

              Container(
                width: 58,
                height: 58,

                padding:
                    const EdgeInsets.all(
                  5,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        // =====================================================
        // STATISTIK
        // =====================================================

        LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final width =
                constraints.maxWidth;

            final columns =
                width >= 900
                    ? 4
                    : width >= 500
                        ? 2
                        : 1;

            const gap = 12.0;

            final cardWidth =
                (
                  width -
                      (
                        (columns - 1) *
                            gap
                      )
                ) /
                columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                _statCard(
                  context,
                  width: cardWidth,

                  value:
                      '${store.activities.length}',

                  title:
                      'Kegiatan',

                  subtitle:
                      'Lihat & edit kegiatan',

                  icon:
                      Icons
                          .format_list_bulleted,

                  onTap: () {
                    onOpenTab(2);
                  },
                ),

                _statCard(
                  context,
                  width: cardWidth,

                  value:
                      '${store.daysInMonth}',

                  title:
                      'Hari',

                  subtitle:
                      'Lihat checklist bulanan',

                  icon:
                      Icons
                          .calendar_month_outlined,

                  onTap: () {
                    onOpenTab(1);
                  },
                ),

                _statCard(
                  context,
                  width: cardWidth,

                  value:
                      '$todayDone',

                  title:
                      'Selesai Hari $selectedDay',

                  subtitle:
                      'Buka checklist hari ini',

                  icon:
                      Icons.task_alt,

                  onTap: () {
                    onOpenTab(1);
                  },
                ),

                _statCard(
                  context,
                  width: cardWidth,

                  value:
                      '${(store.progress * 100).round()}%',

                  title:
                      'Progress Bulan',

                  subtitle:
                      'Lihat rekap pekerjaan',

                  icon:
                      Icons.donut_large,

                  onTap: () {
                    onOpenTab(3);
                  },
                ),
              ],
            );
          },
        ),

        const SizedBox(
          height: 20,
        ),

        // =====================================================
        // PROGRESS BULAN
        // =====================================================

        Card(
          clipBehavior:
              Clip.antiAlias,

          child: InkWell(
            onTap: () {
              onOpenTab(3);
            },

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Progress $monthName',

                          style:
                              Theme.of(
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
                      ),

                      const Icon(
                        Icons
                            .chevron_right,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  LinearProgressIndicator(
                    value:
                        store.progress,

                    minHeight:
                        12,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    '${store.totalChecked} dari '
                    '${store.totalPossible} checklist telah terisi.',
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        // =====================================================
        // DOKUMEN AKTIF
        // =====================================================

        Card(
          clipBehavior:
              Clip.antiAlias,

          child: ListTile(
            onTap: () {
              onOpenTab(2);
            },

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal:
                  18,
              vertical:
                  8,
            ),

            leading:
                const CircleAvatar(
              child: Icon(
                Icons
                    .description_outlined,
              ),
            ),

            title:
                const Text(
              'Dokumen Aktif',

              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            subtitle:
                Text(
              '${store.place} • ${store.personInCharge}',
            ),

            trailing:
                const Icon(
              Icons.chevron_right,
            ),
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        // =====================================================
        // PROFIL
        // =====================================================

        Card(
          clipBehavior:
              Clip.antiAlias,

          child: ListTile(
            onTap: () {
              // buka menu Profil
              onOpenTab(4);
            },

            leading:
                CircleAvatar(
              backgroundImage:
                  profilePhoto,

              child:
                  profilePhoto ==
                          null
                      ? const Icon(
                          Icons.person,
                        )
                      : null,
            ),

            title:
                Text(
              displayName,

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            subtitle:
                Text(
              user?.email ??
                  'Atur profil pengguna',
            ),

            trailing:
                const Icon(
              Icons.chevron_right,
            ),
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        // =====================================================
        // DARK MODE
        // =====================================================

        Card(
          child:
              SwitchListTile(
            secondary:
                CircleAvatar(
              child: Icon(
                store.darkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),

            title:
                Text(
              store.darkMode
                  ? 'Mode Gelap Aktif'
                  : 'Mode Terang Aktif',

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            subtitle:
                Text(
              store.darkMode
                  ? 'Matikan untuk kembali ke tampilan terang.'
                  : 'Aktifkan tampilan gelap.',
            ),

            value:
                store.darkMode,

            onChanged:
                (
              value,
            ) {
              store.setDarkMode(
                value,
              );
            },
          ),
        ),

        const SizedBox(
          height: 100,
        ),
      ],
    );
  }

  // ===========================================================
  // KARTU STATISTIK
  // ===========================================================

  Widget _statCard(
    BuildContext context, {
    required double width,
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,

      child: Card(
        margin:
            EdgeInsets.zero,

        clipBehavior:
            Clip.antiAlias,

        child: InkWell(
          onTap:
              onTap,

          child: Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),

            child: Row(
              children: [
                CircleAvatar(
                  radius:
                      25,

                  child:
                      Icon(
                    icon,
                  ),
                ),

                const SizedBox(
                  width:
                      12,
                ),

                Expanded(
                  child:
                      Column(
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
                                      FontWeight.bold,
                                ),
                      ),

                      const SizedBox(
                        height:
                            2,
                      ),

                      Text(
                        title,

                        maxLines:
                            2,

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height:
                            3,
                      ),

                      Text(
                        subtitle,

                        maxLines:
                            2,

                        overflow:
                            TextOverflow
                                .ellipsis,

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

                const SizedBox(
                  width:
                      4,
                ),

                const Icon(
                  Icons
                      .chevron_right,

                  size:
                      20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}