import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cached network image widget with loading and error states
class CachedImage extends StatelessWidget {
  const CachedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    super.key,
  });
  
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(theme),
      errorWidget: (context, url, error) => errorWidget ?? _defaultError(theme),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
    
    if (borderRadius != null && shape == BoxShape.rectangle) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    } else if (shape == BoxShape.circle) {
      image = ClipOval(child: image);
    }
    
    return image;
  }
  
  Widget _defaultPlaceholder(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceVariant,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
  
  Widget _defaultError(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.errorContainer.withOpacity(0.3),
      child: Icon(
        Icons.broken_image_outlined,
        color: theme.colorScheme.error.withOpacity(0.5),
        size: 32,
      ),
    );
  }
}

/// Circular cached avatar image
class CachedAvatar extends StatelessWidget {
  const CachedAvatar({
    required this.imageUrl,
    this.radius = 24,
    this.placeholder,
    this.errorWidget,
    super.key,
  });
  
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceVariant,
        child: Icon(
          Icons.person,
          size: radius,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => placeholder ?? CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceVariant,
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
        child: Icon(
          Icons.person,
          size: radius,
          color: theme.colorScheme.error.withOpacity(0.5),
        ),
      ),
    );
  }
}
