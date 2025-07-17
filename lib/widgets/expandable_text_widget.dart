import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.trimLines = 3,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final textSpan = TextSpan(
        text: widget.text,
        style: GoogleFonts.sen(fontSize: 16, color: Colors.grey[700]),
      );
      final textPainter = TextPainter(
        text: textSpan,
        maxLines: widget.trimLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth);

      final isTextOverflowing = textPainter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(textSpan, maxLines: _isExpanded ? null : widget.trimLines, overflow: TextOverflow.ellipsis),
          if (isTextOverflowing)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'Read less' : 'Read more',
                style: GoogleFonts.sen(
                    color: Colors1.primaryOrange, fontWeight: FontWeight.bold),
              ), // Removed extra padding as it's already handled by Column spacing
            ),
        ],
      );
    });
  }
}