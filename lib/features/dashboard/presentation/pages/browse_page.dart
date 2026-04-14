import 'package:flutter/material.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/item_card_widget.dart';
import '../widgets/open_item_modal.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  late Future<List<Map<String, dynamic>>> itemsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    itemsFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems({String? query}) async {
    try {
      var queryBuilder = SupabaseService.client.from('items').select();

      // Apply search filter if provided
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'item_name.ilike.%$query%,description.ilike.%$query%',
        );
      }

      // Apply status filter
      if (_selectedFilter != 'All') {
        queryBuilder = queryBuilder.ilike('status', _selectedFilter);
      }

      final orderedQuery = queryBuilder
          .order('updated_at', ascending: false)
          .order('created_at', ascending: false);

      final data = await orderedQuery;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  void _onSearch(String query) {
    setState(() {
      itemsFuture = _fetchItems(query: query);
    });
  }

  void _onFilterChanged(String? newFilter) {
    if (newFilter != null) {
      setState(() {
        _selectedFilter = newFilter;
        itemsFuture = _fetchItems(query: _searchController.text);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Lost Items'),
        backgroundColor: AppColors.headerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fieldShadow,
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search by item name or description...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Filter:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    ...['All', 'Found', 'Claimed']
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (_) => _onFilterChanged(filter),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Items Grid
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return const Center(child: Text('No items found'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemCard(
                        id: item['id']?.toString() ?? '',
                        title: item['item_name'] ?? 'Unknown',
                        description: item['description'] ?? '',
                        category: item['category'] ?? 'General',
                        imageUrl: item['image_url'] ?? '',
                        status: item['status'] ?? 'unclaimed',
                        postedDate: item['date_found'] != null
                            ? DateTime.parse(item['date_found'])
                            : (item['created_at'] != null
                                  ? DateTime.parse(item['created_at'])
                                  : DateTime.now()),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OpenItemModal(
                                id: item['id']?.toString() ?? '',
                                itemName: item['item_name'] ?? 'Unknown',
                                description: item['description'] ?? '',
                                category: item['category'] ?? 'General',
                                imageUrl: item['image_url'] ?? '',
                                status: item['status'] ?? 'found',
                                dateFound: item['date_found'] != null
                                    ? DateTime.parse(item['date_found'])
                                    : (item['created_at'] != null
                                          ? DateTime.parse(item['created_at'])
                                          : DateTime.now()),
                                foundLocationId: item['found_location_id']
                                    ?.toString(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
