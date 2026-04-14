import 'package:flutter/material.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';

class OpenItemModal extends StatefulWidget {
  final String id;
  final String itemName;
  final String description;
  final String category;
  final String imageUrl;
  final String status;
  final DateTime dateFound;
  final String? foundLocationId;

  const OpenItemModal({
    super.key,
    required this.id,
    required this.itemName,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.status,
    required this.dateFound,
    this.foundLocationId,
  });

  @override
  State<OpenItemModal> createState() => _OpenItemModalState();
}

class _OpenItemModalState extends State<OpenItemModal> {
  bool _isSubmittingClaim = false;
  late final Future<String> _foundLocationFuture;

  @override
  void initState() {
    super.initState();
    _foundLocationFuture = _fetchFoundLocationName();
  }

  Future<String> _fetchFoundLocationName() async {
    final locationId = widget.foundLocationId;
    if (locationId == null || locationId.isEmpty) {
      return 'Not specified';
    }

    try {
      final data = await SupabaseService.client
          .from('locations')
          .select('name')
          .eq('id', locationId)
          .maybeSingle();

      final locationName = data?['name']?.toString().trim();
      if (locationName == null || locationName.isEmpty) {
        return 'Not specified';
      }

      return locationName;
    } catch (_) {
      return 'Not specified';
    }
  }

  Future<void> _submitClaim() async {
    setState(() => _isSubmittingClaim = true);

    try {
      // TODO: Submit claim to backend
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claim submitted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmittingClaim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: AppColors.headerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Item Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[200],
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 64),
                    ),
            ),
            // Item Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.itemName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Category Section
                  _buildDetailSection(
                    icon: Icons.local_offer,
                    label: 'Category',
                    value: widget.category,
                  ),
                  const SizedBox(height: 24),
                  // Location Found Section
                  _buildDetailSection(
                    icon: Icons.location_on,
                    label: 'Location Found',
                    value: '',
                    valueBuilder: () => _foundLocationFuture,
                  ),
                  const SizedBox(height: 24),
                  // Date Found Section
                  _buildDetailSection(
                    icon: Icons.calendar_today,
                    label: 'Date Found',
                    value: _formatDate(widget.dateFound),
                  ),
                  const SizedBox(height: 40),
                  // Submit Claim Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmittingClaim ? null : _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isSubmittingClaim
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Claim for This Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String value,
    Future<String> Function()? valueBuilder,
  }) {
    final valueWidget = valueBuilder == null
        ? Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          )
        : FutureBuilder<String>(
            future: valueBuilder(),
            builder: (context, snapshot) {
              final resolvedValue = snapshot.data ?? 'Not specified';
              return Text(
                resolvedValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              );
            },
          );

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.headerBlue, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget,
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey[300], thickness: 1),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'claimed':
        return Colors.green;
      case 'found':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
