import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import '../../utils/constants.dart';

class ChannelItem extends StatefulWidget {
  final Channel channel;
  final bool isPlaying;
  final bool isLast;
  final bool isPreviewing;
  final VoidCallback onPressed;
  final Function(Channel)? onFocus;

  const ChannelItem({
    super.key,
    required this.channel,
    required this.isPlaying,
    required this.isLast,
    this.isPreviewing = false,
    required this.onPressed,
    this.onFocus,
  });

  @override
  State<ChannelItem> createState() => _ChannelItemState();
}

class _ChannelItemState extends State<ChannelItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isPreviewing
        ? Constants.previewColor
        : (widget.isPlaying && !_isFocused)
            ? Constants.activeColor
            : _isFocused
                ? Constants.focusedColor
                : Constants.sidebarColor;

    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
        if (focused && widget.onFocus != null) {
          widget.onFocus!(widget.channel);
        }
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _isFocused || widget.isPreviewing ? 8 : 4,
            vertical: _isFocused || widget.isPreviewing ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: _isFocused || widget.isPreviewing
                ? [
                    BoxShadow(
                      color: widget.isPreviewing ? Constants.previewColor : Constants.focusedColor,
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              if (!_isFocused && (widget.isPlaying || widget.isPreviewing))
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: widget.isPreviewing ? Constants.previewBorderColor : Constants.primaryColor,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Constants.sidebarLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.tv,
                            size: _isFocused || widget.isPreviewing ? 28 : 24,
                            color: _isFocused || widget.isPreviewing ? Colors.white : Colors.grey,
                          ),
                        ),
                        if (widget.isPreviewing && !_isFocused)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Constants.previewColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_upward, size: 10, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.channel.name,
                            style: TextStyle(
                              color: widget.isPlaying
                                  ? Constants.primaryColor
                                  : (_isFocused || widget.isPreviewing ? Colors.white : Colors.grey[500]),
                              fontWeight: _isFocused || widget.isPlaying ? FontWeight.w600 : FontWeight.w500,
                              fontSize: _isFocused || widget.isPreviewing ? 14 : 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (widget.channel.isHd)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: _isFocused ? Colors.white : const Color(0xFF1a3a5c),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'HD',
                                    style: TextStyle(
                                      color: _isFocused ? Constants.primaryColor : const Color(0xFF4fc3f7),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (widget.isLast && !widget.isPlaying) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: _isFocused ? const Color(0xFFf9a825) : const Color(0xFFf9a825).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.access_time, size: 10, color: _isFocused ? Colors.white : const Color(0xFFf9a825)),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Last',
                                        style: TextStyle(
                                          color: _isFocused ? Colors.white : const Color(0xFFf9a825),
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.isPlaying)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isFocused ? Colors.white : Constants.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, size: 10, color: _isFocused ? Constants.primaryColor : Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              'NOW',
                              style: TextStyle(
                                color: _isFocused ? Constants.primaryColor : Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}