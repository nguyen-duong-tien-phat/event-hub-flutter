import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final List<String> categories;

  const new({super.key, required this.categories});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String selectedCategory = 'My feed';
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: widget.categories.map((cat) {
        bool isSelected = cat == selectedCategory;

        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedCategory = cat;
            });
          },
          selectedColor: context.ink,
          showCheckmark: false,
          label: Text(
            cat,
            style: context.control.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : null,
              color: isSelected ? context.surface : context.ink,
            ),
          ),
          side: BorderSide(color: isSelected ? context.ink : context.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
          backgroundColor: isSelected ? context.ink : context.surface,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          // Drop the invisible 48px tap-target padding so the gaps above
          // and below the row match the design.
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
