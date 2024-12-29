import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/review.dart';

class AddReviewDialog extends StatefulWidget {
  final String itemId;

  const AddReviewDialog({Key? key, required this.itemId}) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() => _rating = rating);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final review = Review(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: FirebaseAuth.instance.currentUser!.uid,
              itemId: widget.itemId,
              rating: _rating,
              comment: _commentController.text,
              createdAt: DateTime.now(),
            );

            await FirebaseFirestore.instance
                .collection('reviews')
                .doc(review.id)
                .set(review.toMap());

            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}