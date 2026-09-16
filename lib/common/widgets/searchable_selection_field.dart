import 'package:flutter/material.dart';

class SearchableSelectionField<T> extends StatelessWidget {
  final String label;
  final String searchHint;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final ValueChanged<T> onSelected;
  final bool enabled;
  final bool required;

  const SearchableSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    this.searchHint = 'Search',
    this.itemSubtitle,
    this.enabled = true,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        key: ValueKey(value == null ? '$label-empty' : itemLabel(value as T)),
        initialValue: value == null ? '' : itemLabel(value as T),
        readOnly: true,
        enabled: enabled,
        validator: (_) =>
            required && value == null ? 'Please select $label' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Select $label',
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onTap: enabled && items.isNotEmpty ? () => _showPicker(context) : null,
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SearchablePicker<T>(
        title: label,
        searchHint: searchHint,
        items: items,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        selected: value,
      ),
    );

    if (selected != null) onSelected(selected);
  }
}

class _SearchablePicker<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<T> items;
  final String Function(T item) itemLabel;
  final String? Function(T item)? itemSubtitle;
  final T? selected;

  const _SearchablePicker({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.itemLabel,
    required this.itemSubtitle,
    required this.selected,
  });

  @override
  State<_SearchablePicker<T>> createState() => _SearchablePickerState<T>();
}

class _SearchablePickerState<T> extends State<_SearchablePicker<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visibleItems = query.isEmpty
        ? widget.items
        : widget.items
            .where(
                (item) => widget.itemLabel(item).toLowerCase().contains(query))
            .toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              'Select ${widget.title}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visibleItems.isEmpty
                ? const Center(child: Text('No matching options'))
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: visibleItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      final subtitle = widget.itemSubtitle?.call(item);
                      return ListTile(
                        dense: true,
                        title: Text(widget.itemLabel(item)),
                        subtitle: subtitle == null || subtitle.isEmpty
                            ? null
                            : Text(subtitle),
                        trailing: item == widget.selected
                            ? Icon(Icons.check_rounded,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
