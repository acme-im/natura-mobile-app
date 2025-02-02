import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const double kDefaultHeight = 75.0;
const double kDefaultWidth = 75.0;

const double kDefaultNoImageHeight = 64.0;
const double kDefaultNoImageWidth = 64.0;

Widget imageWidget(final String? url,
    {final double width = kDefaultWidth,
    final double height = kDefaultHeight,
    final double noImageWidth = kDefaultNoImageWidth,
    final double noImageHeight = kDefaultNoImageHeight}) {
  return url != null
      ? CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: width,
          height: height,
          placeholder: (BuildContext context, String url) => Container(
            width: width,
            height: height,
            color: Colors.white,
          ),
          errorWidget: (context, url, dynamic error) => Icon(Icons.error),
        )
      : Image.asset('assets/images/no_image.png', fit: BoxFit.cover, width: noImageWidth, height: noImageHeight);
}
