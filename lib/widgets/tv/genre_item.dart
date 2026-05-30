import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class GenreItem extends StatefulWidget {
  final String title;
  final int count;
  final bool isActive;
  final VoidCallback onPressed;

  const GenreItem({
    super.key,
    required this.title,
    required this.count,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<GenreItem> createState() => _GenreItemState();
}

class _GenreItemState extends State<GenreItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() => _isFocused = focused);
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _isFocused
                ? Constants.focusedColor
                : (widget.isActive ? const Color(0xFF2a0a0a) : const Color(0xFF131313)),
            borderRadius: BorderRadius.circular(8),
            border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.isActive ? Constants.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: _isFocused
                          ? Colors.white
                          : (widget.isActive ? Colors.white : Colors.grey[500]),
                      fontWeight: _isFocused || widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isFocused ? Colors.white : const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: TextStyle(
                      color: _isFocused ? Constants.primaryColor : Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}