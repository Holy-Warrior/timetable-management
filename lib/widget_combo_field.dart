import 'package:flutter/material.dart';

class ComboboxField extends StatefulWidget {
  final String label;
  final List<String> options;
  final TextEditingController controller;

  const ComboboxField({
    super.key,
    this.label = '',
    required this.options,
    required this.controller,
  });

  @override
  State<ComboboxField> createState() => _ComboboxFieldState();
}

class _ComboboxFieldState extends State<ComboboxField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _dropdownOverlay;
  late FocusNode _focusNode;

  TextEditingController? _activeTextController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _removeDropdown();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeDropdown();
    }
  }

  void _showDropdown() {
    _removeDropdown();
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    FocusScope.of(context).unfocus();

    _dropdownOverlay = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 4.0),
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children:
                        widget.options.map((option) {
                          return ListTile(
                            title: Text(
                              option,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            onTap: () {
                              _activeTextController?.text = option;
                              _activeTextController
                                  ?.selection = TextSelection.fromPosition(
                                TextPosition(offset: option.length),
                              );
                              _removeDropdown();
                            },
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context, rootOverlay: true).insert(_dropdownOverlay!);
  }

  void _removeDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          // Hide suggestions when the field is empty
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return widget.options.where((String option) {
            return option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            );
          });
        },
        onSelected: (String selection) {
          widget.controller.text = selection;
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          _activeTextController = textController;

          // Synchronize text back to widget.controller
          textController.addListener(() {
            widget.controller.text = textController.text;
          });

          return TextFormField(
            controller: textController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: widget.label,
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  if (_dropdownOverlay == null) {
                    _showDropdown();
                  } else {
                    _removeDropdown();
                  }
                },
              ),
            ),
            onTap: () {
              _removeDropdown();
            },
          );
        },
      ),
    );
  }
}
