import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class Prac9 extends StatefulWidget {
  const Prac9({super.key});

  @override
  State<Prac9> createState() => _Prac9State();
}

class _Prac9State extends State<Prac9> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController(); // signup only

  bool _loading = false;
  String? _error;
  Session? _session;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Read current session and listen for changes
    _session = Supabase.instance.client.auth.currentSession;
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await Supabase.instance.client.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        data: {
          'username': _username.text.trim(),
        }, // store username in user metadata
      );
      // If email confirmation is enabled, session can be null until confirmed
      if (resp.session == null) {
        setState(() {
          _error = 'Check your email to confirm your account.';
        });
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = _session != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prac9 - Supabase Auth'),
        actions: [
          IconButton(
            tooltip: 'Test Network',
            onPressed: _checkConnectivity,
            icon: const Icon(Icons.wifi_tethering),
          ),
          if (loggedIn)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loggedIn ? _buildHome() : _buildAuthTabs(),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkConnectivity() async {
    const healthUrl =
        'https://pzwbevmapgmsagtdnxnm.supabase.co/auth/v1/health';
    try {
      final resp = await http
          .get(Uri.parse(healthUrl))
          .timeout(const Duration(seconds: 6));
      _showSnack('Health ${resp.statusCode}');
    } on SocketException catch (e) {
      _showSnack('SocketException: ${e.message}');
    } on TimeoutException {
      _showSnack('Timeout connecting to Supabase');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Widget _buildAuthTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TabBar(tabs: [Tab(text: 'Login'), Tab(text: 'Sign Up')]),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _buildLoginForm(),
                _buildSignupForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _username,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: _loading ? null : _signup,
            child: _loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.userMetadata?['username'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome, ${username ?? user?.email ?? 'user'}'),
        const SizedBox(height: 8),
        if (user?.email != null) Text('Email: ${user!.email!}'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}






