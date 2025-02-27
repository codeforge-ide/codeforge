import 'package:flutter/material.dart';

enum SearchMode { files, text }

class SearchPanel extends StatefulWidget {
  final SearchMode mode;

  const SearchPanel({super.key, required this.mode});

  @override
  SearchPanelState createState() => SearchPanelState();
}

class SearchPanelState extends State<SearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _useRegex = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.abc,
                          size: 18,
                          color: _caseSensitive ? Colors.blue : null,
                        ),
                        onPressed: () =>
                            setState(() => _caseSensitive = !_caseSensitive),
                        tooltip: 'Match Case',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.wrap_text,
                          size: 18,
                          color: _wholeWord ? Colors.blue : null,
                        ),
                        onPressed: () =>
                            setState(() => _wholeWord = !_wholeWord),
                        tooltip: 'Match Whole Word',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.code,
                          size: 18,
                          color: _useRegex ? Colors.blue : null,
                        ),
                        onPressed: () => setState(() => _useRegex = !_useRegex),
                        tooltip: 'Use Regular Expression',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _replaceController,
                decoration: const InputDecoration(
                  hintText: 'Replace',
                  prefixIcon: Icon(Icons.find_replace, size: 18),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 0, // Replace with actual search results
            itemBuilder: (context, index) {
              return const ListTile(
                title: Text('No results found'),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
