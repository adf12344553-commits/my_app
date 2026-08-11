// lib/profile_screen.dart – FULL (Dark color picker)
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'auth_provider.dart';
import 'theme_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Color _selectedColor = Colors.amber.shade900;
  bool _isLoading = false;
  String? _logoUrl;
  Uint8List? _logoBytes;

  // 🔥 Dark colors for picker
  final List<Color> _darkColors = [
    Colors.amber.shade900,
    Colors.blue.shade900,
    Colors.red.shade900,
    Colors.green.shade900,
    Colors.purple.shade900,
    Colors.teal.shade900,
    Colors.orange.shade900,
    Colors.pink.shade900,
    Colors.indigo.shade900,
    Colors.brown.shade900,
    Colors.deepOrange.shade900,
    Colors.cyan.shade900,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = context.read<AppState>().settings;
    if (settings != null) {
      _businessNameController.text = settings.businessName;
      _ownerNameController.text = settings.ownerName;
      _phoneController.text = settings.phone;
      _upiController.text = settings.upiId;
      _addressController.text = settings.address;
      _logoUrl = settings.logoUrl;
      _selectedColor = ThemeService.getPrimaryColor(context.read<AppState>());
    }
  }

  Future<void> _uploadLogo() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    await for (var event in input.onChange) {
      final files = input.files;
      if (files == null || files.isEmpty) return;

      final file = files.first;
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      await for (var _ in reader.onLoad) {
        final result = reader.result as String?;
        if (result != null) {
          setState(() {
            _logoUrl = result;
          });
        }
        break;
      }
      break;
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    final appState = context.read<AppState>();
    final auth = context.read<AuthProvider>();

    final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';

    final newSettings = BusinessSettings(
      id: appState.settings?.id ?? '',
      userId: auth.user!.id,
      businessName: _businessNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      upiId: _upiController.text.trim(),
      address: _addressController.text.trim(),
      logoUrl: _logoUrl ?? '',
      primaryColor: colorHex,
    );
    await appState.updateSettings(newSettings);
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Settings saved! Theme updated!'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appState = context.watch<AppState>();
    final primaryColor = ThemeService.getPrimaryColor(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Branding',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _uploadLogo,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                          image: _logoUrl != null && _logoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_logoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _logoUrl == null || _logoUrl!.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 40, color: Colors.grey[600]),
                                  const SizedBox(height: 4),
                                  Text('Upload Logo',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600])),
                                ],
                              )
                            : null,
                      ),
                    ),
                    if (_logoUrl != null && _logoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text('Logo uploaded',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green[700])),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.clear,
                                  size: 16, color: Colors.red[400]),
                              onPressed: () {
                                setState(() {
                                  _logoUrl = null;
                                  _logoBytes = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // 🔥 Dark Color Picker
                    const Text('Primary Color (Dark / Bold)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _darkColors.map((color) {
                        return _colorChip(color);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text('Business Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _upiController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID (e.g., business@upi)',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _saveSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('SAVE SETTINGS',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('Account',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(auth.user?.email ?? ''),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Name'),
                      subtitle: Text(auth.userName ?? ''),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _colorChip(Color color) {
    final isSelected = color.value == _selectedColor.value;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
