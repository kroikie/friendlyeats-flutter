import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliver_fab/sliver_fab.dart';

import './empty_list.dart';
import './model/data.dart' as data;
import './model/restaurant.dart';
import './model/review.dart';
import './restaurant_app_bar.dart';
import './restaurant_review.dart';
import './restaurant_review_dialog.dart';

class FriendlyEatsRestaurantPage extends StatefulWidget {
  static const route = '/restaurant';

  final String _restaurantId;

  FriendlyEatsRestaurantPage({Key key, @required String restaurantId})
      : _restaurantId = restaurantId,
        super(key: key);

  @override
  _FriendlyEatsRestaurantPageState createState() =>
      _FriendlyEatsRestaurantPageState(restaurantId: _restaurantId);
}

class _FriendlyEatsRestaurantPageState
    extends State<FriendlyEatsRestaurantPage> {
  _FriendlyEatsRestaurantPageState({@required String restaurantId}) {
    FirebaseAuth.instance.signInAnonymously().then((AuthResult auth) {
      _currentRestaurantSubscription =
          data.getRestaurant(restaurantId).listen((DocumentSnapshot snap) {
        _currentReviewSubscription?.cancel();
        setState(() {
          _restaurant = Restaurant.fromSnapshot(snap);
          // Initialize the reviews snapshot...
          _currentReviewSubscription = _restaurant.reference
              .collection('ratings')
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((QuerySnapshot reviewSnap) {
            setState(() {
              _isLoading = false;
              _reviews = reviewSnap.documents.map((DocumentSnapshot doc) {
                return Review.fromSnapshot(doc);
              }).toList();
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _currentRestaurantSubscription?.cancel();
    _currentReviewSubscription?.cancel();
    super.dispose();
  }

  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot> _currentRestaurantSubscription;
  StreamSubscription<QuerySnapshot> _currentReviewSubscription;

  Restaurant _restaurant;
  List<Review> _reviews = <Review>[];

  Future<void> _addReview(String restaurantId, Review newReview) async {
    String userId = await FirebaseAuth.instance
        .currentUser()
        .then((FirebaseUser user) => user.uid);
    String userName = 'Anonymous (${kIsWeb ? "Web" : "Mobile"})';

    return data.addReview(
        restaurantId: restaurantId,
        userId: userId,
        userName: userName,
        review: newReview);
  }

  void _onCreateReviewPressed(BuildContext context) async {
    Review newReview = await showDialog<Review>(
        context: context, builder: (_) => RestaurantReviewDialog());
    if (newReview != null) {
      // Save the review
      return _addReview(_restaurant.id, newReview);
    }
  }

  void _onAddRandomReviewsPressed() async {
    // Await adding a random number of random reviews
    int numReviews = Random().nextInt(5) + 5;
    for (int i = 0; i < numReviews; i++) {
      await _addReview(_restaurant.id, Review.random());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            body: Builder(
              builder: (context) => SliverFab(
                floatingWidget: FloatingActionButton(
                  tooltip: 'Add a review',
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.add),
                  onPressed: () => _onCreateReviewPressed(context),
                ),
                floatingPosition: FloatingPosition(right: 16),
                expandedHeight: RestaurantAppBar.kAppBarHeight,
                slivers: <Widget>[
                  RestaurantAppBar(
                    restaurant: _restaurant,
                    onClosePressed: () => Navigator.pop(context),
                  ),
                  _reviews.isNotEmpty
                      ? SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(_reviews
                                .map((Review review) =>
                                    RestaurantReview(review: review))
                                .toList()),
                          ),
                        )
                      : SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyListView(
                            child: Text('${_restaurant.name} has no reviews.'),
                            onPressed: _onAddRandomReviewsPressed,
                          ),
                        ),
                ],
              ),
            ),
          );
  }
}

class FriendlyEatsRestaurantPageArguments {
  final String id;

  FriendlyEatsRestaurantPageArguments({@required this.id});
}
