import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';

class SubmitReviewBottomSheet extends ConsumerStatefulWidget {
  const SubmitReviewBottomSheet({
    super.key,
    required this.sellerId,
    this.productId,
    required this.onReviewSubmitted,
  });

  final String sellerId;
  final String? productId;
  final VoidCallback onReviewSubmitted;

  @override
  ConsumerState<SubmitReviewBottomSheet> createState() =>
      _SubmitReviewBottomSheetState();
}

class _SubmitReviewBottomSheetState
    extends ConsumerState<SubmitReviewBottomSheet> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(stringsProvider).isNepali
                ? 'कृपया रेटिंग चुनुहोस्'
                : 'Please select a rating',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reviewRepo = ref.read(sellerReviewRepositoryProvider);
      await reviewRepo.submitReview(
        sellerId: widget.sellerId,
        rating: _selectedRating,
        comment: _commentController.text,
        productId: widget.productId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(stringsProvider).isNepali
                  ? 'समीक्षा सफलतापूर्वक जमा भयो'
                  : 'Review submitted successfully',
            ),
          ),
        );
        widget.onReviewSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final nepali = s.isNepali;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nepali ? 'समीक्षा दिनुहोस्' : 'Write a Review',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              nepali ? 'रेटिंग' : 'Rating',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () => setState(() => _selectedRating = index + 1),
                  icon: Icon(
                    Icons.star,
                    color: index < _selectedRating
                        ? Colors.amber
                        : Colors.grey[300],
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nepali ? 'टिप्पणी (वैकल्पिक)' : 'Comment (Optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: nepali
                    ? 'आपको अनुभव साझा गर्नुहोस्...'
                    : 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : Text(nepali ? 'समीक्षा दिनुहोस्' : 'Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
