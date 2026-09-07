import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController email;

  @override
  void initState() {
    super.initState();

    final user = appStore.currentUser;

    name = TextEditingController(
      text: user?.name ?? appStore.userName,
    );

    email = TextEditingController(
      text: user?.email ?? '',
    );

    appStore.addListener(_refresh);
  }

  @override
  void dispose() {
    appStore.removeListener(_refresh);

    name.dispose();
    email.dispose();

    super.dispose();
  }

  void _refresh() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _pickPhoto() async {
    try {
      final picked =
          await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 900,
        maxHeight: 900,
      );

      if (picked == null) {
        return;
      }

      final bytes =
          await picked.readAsBytes();

      appStore.updateProfilePhoto(
        base64Encode(bytes),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih foto: $e',
          ),
        ),
      );
    }
  }

  void _saveProfile() {
    final error =
        appStore.updateCurrentProfile(
      name: name.text,
      email: email.text,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          error ??
              'Profil berhasil diperbarui.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = appStore.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Silakan login terlebih dahulu.',
        ),
      );
    }

    ImageProvider? photo;

    if (user.photoBase64.isNotEmpty) {
      try {
        photo = MemoryImage(
          base64Decode(
            user.photoBase64,
          ),
        );
      } catch (_) {
        photo = null;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 62,
                    backgroundImage: photo,
                    child: photo == null
                        ? const Icon(
                            Icons.person,
                            size: 64,
                          )
                        : null,
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child:
                        IconButton.filled(
                      tooltip:
                          'Ganti foto profil',
                      onPressed: _pickPhoto,
                      icon: const Icon(
                        Icons.camera_alt,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                user.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 3),

              Text(user.email),

              if (photo != null)
                TextButton.icon(
                  onPressed:
                      appStore
                          .removeProfilePhoto,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text(
                    'Hapus Foto',
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Nama Lengkap',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: email,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child:
                      FilledButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'Simpan Profil',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: Icon(
                  appStore.darkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: const Text(
                  'Mode Gelap',
                ),
                subtitle: const Text(
                  'Ubah tampilan aplikasi.',
                ),
                value:
                    appStore.darkMode,
                onChanged:
                    appStore.setDarkMode,
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.password_outlined,
                ),
                title: const Text(
                  'Ubah Kata Sandi',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap:
                    _changePassword,
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.business_outlined,
                ),
                title: const Text(
                  'Tempat / Bagian',
                ),
                subtitle:
                    Text(appStore.place),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        OutlinedButton.icon(
          onPressed: () {
            _resetChecklist(context);
          },
          icon: const Icon(
            Icons.restart_alt,
          ),
          label: const Text(
            'Kosongkan Checklist Bulan Aktif',
          ),
        ),

        const SizedBox(height: 10),

        FilledButton.tonalIcon(
          onPressed: appStore.logout,
          icon: const Icon(
            Icons.logout,
          ),
          label: const Text(
            'Keluar dari Akun',
          ),
        ),

        const SizedBox(height: 90),
      ],
    );
  }

  Future<void> _changePassword() async {
    final oldPassword =
        TextEditingController();

    final newPassword =
        TextEditingController();

    final confirm =
        TextEditingController();

    final ok =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Ubah Kata Sandi'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassword,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Kata Sandi Lama',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: newPassword,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Kata Sandi Baru',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: confirm,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Ulangi Kata Sandi Baru',
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Batal'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (ok != true) {
      oldPassword.dispose();
      newPassword.dispose();
      confirm.dispose();

      return;
    }

    if (newPassword.text !=
        confirm.text) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Konfirmasi kata sandi tidak sama.',
            ),
          ),
        );
      }
    } else {
      final error =
          appStore.changeCurrentPassword(
        oldPassword:
            oldPassword.text,
        newPassword:
            newPassword.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  'Kata sandi berhasil diubah.',
            ),
          ),
        );
      }
    }

    oldPassword.dispose();
    newPassword.dispose();
    confirm.dispose();
  }

  Future<void> _resetChecklist(
    BuildContext context,
  ) async {
    final ok =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Kosongkan Checklist?',
          ),
          content: const Text(
            'Semua tanda centang pada bulan aktif akan dihapus.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Batal'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Kosongkan',
              ),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      appStore.resetCurrentMonth();
    }
  }
}