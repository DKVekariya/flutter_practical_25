import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_practical_25/ui/word_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/dictionary_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _streamController = StreamController<String>.broadcast();
  late DictionaryApiService _apiService;
  List<String> _dictionary = [];
  List<String> _suggestions = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = DictionaryApiService(prefs);
    _dictionary = await _apiService.loadDictionary();
    setState(() {});
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _suggestions = query.isEmpty
          ? []
          : _dictionary
          .where((word) => word.toLowerCase().startsWith(query))
          .take(10)
          .toList();
    });
    // Debounce API call
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _streamController.add(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _streamController.close();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VocabVault',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            if (_suggestions.isNotEmpty) _buildSuggestions(),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<String>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return FutureBuilder(
                      future: _apiService.fetchWord(snapshot.data!),
                      builder: (context, wordSnapshot) {
                        if (wordSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (wordSnapshot.hasError ||
                            !wordSnapshot.hasData ||
                            wordSnapshot.data == null) {
                          return const Center(
                              child: Text(
                                'Word not found or error occurred',
                                style: TextStyle(color: Colors.redAccent),
                              ));
                        }
                        return WordDetails(word: wordSnapshot.data!);
                      },
                    );
                  }
                  return const Center(
                    child: Text(
                      'Search for a word to see details',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for a word...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.teal),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.teal),
          onPressed: () {
            _searchController.clear();
            setState(() => _suggestions = []);
          },
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _suggestions[index],
              style: const TextStyle(color: Colors.teal),
            ),
            onTap: () {
              _searchController.text = _suggestions[index];
              _streamController.add(_suggestions[index]);
              setState(() => _suggestions = []);
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }
}