import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ModifierGroupScreen(),
    );
  }
}

class ModifierGroupScreen extends StatefulWidget {
  const ModifierGroupScreen({super.key});

  @override
  _ModifierGroupScreenState createState() => _ModifierGroupScreenState();
}

class _ModifierGroupScreenState extends State<ModifierGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _maxQuantityController = TextEditingController();

  List<dynamic> modifierGroups = [];
  final String baseUrl = 'https://megameal.mooo.com/pos/setting/modifier_group/';
  final int vendorId = 1;

  @override
  void initState() {
    super.initState();
    fetchModifiers();
  }

  // Keeping all the existing fetch, create, update, and delete methods unchanged
  Future<void> fetchModifiers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?vendorId=$vendorId&page=1&page_size=10'));
      if (response.statusCode == 200) {
        setState(() {
          modifierGroups = json.decode(response.body)['results'];
        });
      }
    } catch (error) {
      print('Error fetching modifiers: $error');
    }
  }

  Future<void> createModifier() async {
    final body = {
      "PLU": _skuController.text,
      "name": _nameController.text,
      "modifier_group_description": _descriptionController.text,
      "min": int.tryParse(_minQuantityController.text) ?? 0,
      "max": int.tryParse(_maxQuantityController.text) ?? 0,
      "active": true,
      "vendorId": vendorId,
    };

    try {
      final response = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body)
      );
      if (response.statusCode == 201) {
        fetchModifiers();
      }
    } catch (error) {
      print('Error creating modifier: $error');
    }
  }

  Future<void> updateModifier(int id) async {
    final body = {
      "PLU": _skuController.text,
      "name": _nameController.text,
      "modifier_group_description": _descriptionController.text,
      "min": int.tryParse(_minQuantityController.text) ?? 0,
      "max": int.tryParse(_maxQuantityController.text) ?? 0,
      "active": true,
      "vendorId": vendorId,
    };

    try {
      final response = await http.patch(
          Uri.parse('$baseUrl$id/?vendorId=$vendorId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body)
      );
      if (response.statusCode == 200) {
        fetchModifiers();
      }
    } catch (error) {
      print('Error updating modifier: $error');
    }
  }

  Future<void> deleteModifier(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$id/?vendorId=$vendorId'));
      if (response.statusCode == 204) {
        fetchModifiers();
      }
    } catch (error) {
      print('Error deleting modifier: $error');
    }
  }

  void showForm({Map<String, dynamic>? modifier}) {
    if (modifier != null) {
      _nameController.text = modifier['name'];
      _descriptionController.text = modifier['modifier_group_description'] ?? '';
      _skuController.text = modifier['PLU'];
      _minQuantityController.text = modifier['min'].toString();
      _maxQuantityController.text = modifier['max'].toString();
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _skuController.clear();
      _minQuantityController.clear();
      _maxQuantityController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    modifier != null ? 'Update Modifier' : 'Create Modifier',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person,
                    validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                  ),
                  SizedBox(height: 16),
                  buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.info,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  buildTextField(
                    controller: _skuController,
                    label: 'SKU',
                    icon: Icons.auto_graph,
                    validator: (value) => value!.isEmpty ? 'Enter a SKU' : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: _minQuantityController,
                          label: 'Min Quantity',
                          icon: Icons.remove_circle_outline,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                          controller: _maxQuantityController,
                          label: 'Max Quantity',
                          icon: Icons.add_circle_outline,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        if (modifier != null) {
                          updateModifier(modifier['id']);
                        } else {
                          createModifier();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      modifier != null ? 'Update' : 'Create',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Modifier Groups',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepPurple.withOpacity(0.7),
            elevation: 0,
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: modifierGroups.length,
            itemBuilder: (context, index) {
              final modifier = modifierGroups[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.9),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      modifier['name'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    modifier['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    modifier['modifier_group_description'] ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showForm(modifier: modifier),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteModifier(modifier['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showForm(),
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.add, color: Colors.white),
            elevation: 4,
          ),
        ),
      ),
    );
  }
}