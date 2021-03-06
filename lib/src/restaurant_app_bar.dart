import 'package:flutter/material.dart';

import './model/restaurant.dart';
import './restaurant_star_rating.dart';

class RestaurantAppBar extends StatelessWidget {
  static final double kAppBarHeight = 160;

  RestaurantAppBar({
    this.restaurant,
    Function onClosePressed,
  }) : _onPressed = onClosePressed;

  final Restaurant restaurant;

  final Function _onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: _onPressed,
        icon: Icon(Icons.close),
        iconSize: 32,
      ),
      expandedHeight: kAppBarHeight,
      forceElevated: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Wrap(
          children: <Widget>[
            Text(
              restaurant.name,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 80,
                  alignment: Alignment.bottomLeft,
                  child: StarRating(
                    rating: restaurant.avgRating,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(
                    List.filled(restaurant.price, "\$").join(),
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.caption.fontSize),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                '${restaurant.category} ● ${restaurant.city}',
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.caption.fontSize),
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              restaurant.photo,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'assets/shadow.png',
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
