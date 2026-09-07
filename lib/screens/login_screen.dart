import 'package:flutter/material.dart';

import '../app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState
    extends State<LoginScreen> {
  final email =
      TextEditingController();

  final password =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();

    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();

    final error =
        appStore.loginAccount(
      email: email.text,
      password: password.text,
    );

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    // Tidak perlu Navigator manual.
    // AuthGate di main.dart otomatis
    // mendeteksi isLoggedIn = true.
  }

  Future<void> _register() async {
    final registeredEmail =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const RegisterScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (registeredEmail != null) {
      email.text = registeredEmail;
      password.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Akun berhasil dibuat. Masukkan kata sandi lalu tekan Masuk.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 440,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/aiiz_check_logo.png',
                        height: 135,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Masuk ke akun Anda',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 24),

                      TextField(
                        controller: email,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: password,
                        obscureText:
                            obscurePassword,
                        onSubmitted: (_) {
                          _login();
                        },
                        decoration:
                            InputDecoration(
                          labelText:
                              'Kata Sandi',
                          prefixIcon:
                              const Icon(
                            Icons.lock_outline,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotEmailScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Lupa email?',
                            ),
                          ),

                          const Spacer(),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Lupa kata sandi?',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _login,
                          icon:
                              const Icon(Icons.login),
                          label:
                              const Text('Masuk'),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                          ),

                          TextButton(
                            onPressed: _register,
                            child: const Text(
                              'Daftar akun',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// DAFTAR AKUN
// ===========================================================

class RegisterScreen
    extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final name =
      TextEditingController();

  final email =
      TextEditingController();

  final password =
      TextEditingController();

  final confirmPassword =
      TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();

    super.dispose();
  }

  void _register() {
    if (password.text !=
        confirmPassword.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Konfirmasi kata sandi tidak sama.',
          ),
        ),
      );

      return;
    }

    final error =
        appStore.registerAccount(
      name: name.text,
      email: email.text,
      password: password.text,
    );

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    Navigator.pop(
      context,
      email.text
          .trim()
          .toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Daftar Akun'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 460,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: name,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Nama Lengkap',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: email,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: password,
                      obscureText: obscure,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Kata Sandi',
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                          icon: Icon(
                            obscure
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller:
                          confirmPassword,
                      obscureText: obscure,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Ulangi Kata Sandi',
                        prefixIcon: Icon(
                          Icons
                              .lock_reset_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                          FilledButton.icon(
                        onPressed: _register,
                        icon: const Icon(
                          Icons.person_add,
                        ),
                        label: const Text(
                          'Daftar Sekarang',
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Setelah daftar, kembali ke halaman login dan masuk menggunakan email serta kata sandi tersebut.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// LUPA KATA SANDI
// ===========================================================

class ForgotPasswordScreen
    extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen>
      createState() {
    return _ForgotPasswordScreenState();
  }
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final email =
      TextEditingController();

  final newPassword =
      TextEditingController();

  final confirmPassword =
      TextEditingController();

  @override
  void dispose() {
    email.dispose();
    newPassword.dispose();
    confirmPassword.dispose();

    super.dispose();
  }

  void _reset() {
    if (newPassword.text !=
        confirmPassword.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Konfirmasi kata sandi tidak sama.',
          ),
        ),
      );

      return;
    }

    final error =
        appStore.resetPassword(
      email: email.text,
      newPassword: newPassword.text,
    );

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Kata sandi berhasil diubah.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Lupa Kata Sandi'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 460,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 58,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Masukkan email akun lalu buat kata sandi baru.',
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(height: 18),

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

                    const SizedBox(height: 12),

                    TextField(
                      controller: newPassword,
                      obscureText: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Kata Sandi Baru',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller:
                          confirmPassword,
                      obscureText: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Ulangi Kata Sandi Baru',
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _reset,
                        child: const Text(
                          'Reset Kata Sandi',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// LUPA EMAIL
// ===========================================================

class ForgotEmailScreen
    extends StatefulWidget {
  const ForgotEmailScreen({
    super.key,
  });

  @override
  State<ForgotEmailScreen>
      createState() {
    return _ForgotEmailScreenState();
  }
}

class _ForgotEmailScreenState
    extends State<ForgotEmailScreen> {
  final name =
      TextEditingController();

  final password =
      TextEditingController();

  String? result;

  @override
  void dispose() {
    name.dispose();
    password.dispose();

    super.dispose();
  }

  void _findEmail() {
    final found =
        appStore.findEmail(
      name: name.text,
      password: password.text,
    );

    setState(() {
      result = found ??
          'Data akun tidak ditemukan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Lupa Email'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 460,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons
                          .manage_search_outlined,
                      size: 58,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Masukkan nama lengkap dan kata sandi akun.',
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(height: 18),

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

                    const SizedBox(height: 12),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Kata Sandi',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _findEmail,
                        child: const Text(
                          'Cari Email',
                        ),
                      ),
                    ),

                    if (result != null) ...[
                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .primaryContainer,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Text(
                          result!.contains('@')
                              ? 'Email akun Anda:\n$result'
                              : result!,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}