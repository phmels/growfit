import 'package:flutter/material.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/plan/data/exercise_catalog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GROUP DROPDOWN — mantém dropdown simples (poucos itens)
// ─────────────────────────────────────────────────────────────────────────────

class GroupDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const GroupDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<GroupDropdown> createState() => _GroupDropdownState();
}

class _GroupDropdownState extends State<GroupDropdown> {
  static const _custom = '+ Personalizado';
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  void _onSelect(String? value) {
    if (value == _custom) {
      _showCustomDialog();
      return;
    }
    if (value != null) {
      setState(() => _selected = value);
      widget.onChanged(value);
    }
  }

  void _showCustomDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Novo Grupamento',
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.title.copyWith(fontSize: 14),
          decoration: _inputDecoration('Ex: Cardio, Funcional...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.subtitle),
          ),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context);
              setState(() => _selected = v);
              widget.onChanged(v);
            },
            child: Text('Confirmar',
                style:
                    AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [...ExerciseCatalog.groups, _custom];
    final isCustomValue =
        _selected != null && !ExerciseCatalog.groups.contains(_selected);

    return _StyledDropdown<String>(
      value: isCustomValue ? null : _selected,
      hint: isCustomValue ? _selected : 'Selecione o grupamento',
      items: items,
      onChanged: _onSelect,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE DROPDOWN — abre bottom sheet com busca
// ─────────────────────────────────────────────────────────────────────────────

class ExerciseDropdown extends StatefulWidget {
  final String? group;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const ExerciseDropdown({
    super.key,
    required this.group,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<ExerciseDropdown> createState() => _ExerciseDropdownState();
}

class _ExerciseDropdownState extends State<ExerciseDropdown> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(ExerciseDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      setState(() => _selected = null);
    }
  }

  List<String> get _exercises {
    if (widget.group == null) return [];
    return ExerciseCatalog.exercisesFor(widget.group!);
  }

  void _openBottomSheet() {
    if (widget.group == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ExerciseSearchSheet(
        exercises: _exercises,
        onSelected: (value) {
          setState(() => _selected = value);
          widget.onChanged(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.group == null;

    return GestureDetector(
      onTap: isDisabled ? null : _openBottomSheet,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? AppColors.border.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isDisabled
                    ? 'Selecione um grupamento primeiro'
                    : (_selected?.isNotEmpty == true
                        ? _selected!
                        : 'Selecione o exercício'),
                style: (_selected?.isNotEmpty == true && !isDisabled)
                    ? AppTextStyles.title.copyWith(fontSize: 13)
                    : AppTextStyles.subtitle.copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDisabled ? AppColors.muted : AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET COM BUSCA
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseSearchSheet extends StatefulWidget {
  final List<String> exercises;
  final ValueChanged<String> onSelected;

  const _ExerciseSearchSheet({
    required this.exercises,
    required this.onSelected,
  });

  @override
  State<_ExerciseSearchSheet> createState() => _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends State<_ExerciseSearchSheet> {
  final _searchController = TextEditingController();
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = [...widget.exercises];
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.exercises
          .where((e) => e.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectCustom() {
    final controller = TextEditingController();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Novo Exercício',
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.title.copyWith(fontSize: 14),
          decoration: _inputDecoration('Ex: Supino com Corrente...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: AppTextStyles.subtitle),
          ),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context);
              widget.onSelected(v);
            },
            child: Text('Confirmar',
                style:
                    AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Título ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selecionar Exercício',
                    style: AppTextStyles.title.copyWith(fontSize: 16)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      color: AppColors.muted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // ── Campo de busca ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTextStyles.title.copyWith(fontSize: 14),
              decoration: _inputDecoration('Buscar exercício...').copyWith(
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.muted, size: 18),
              ),
            ),
          ),
          // ── Lista ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._filtered.map(
                  (ex) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 2),
                    title: Text(ex,
                        style: AppTextStyles.title.copyWith(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.muted, size: 18),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelected(ex);
                    },
                  ),
                ),
                // ── Botão personalizado ──
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 2),
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add,
                        color: AppColors.primary, size: 16),
                  ),
                  title: Text('+ Personalizado',
                      style: AppTextStyles.title.copyWith(
                          fontSize: 14, color: AppColors.primary)),
                  onTap: _selectCustom,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.subtitle,
    filled: true,
    fillColor: AppColors.bg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STYLED DROPDOWN — usado apenas pelo GroupDropdown
// ─────────────────────────────────────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<T> items;
  final ValueChanged<T?>? onChanged;

  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onChanged == null
              ? AppColors.border.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: AppTextStyles.title.copyWith(fontSize: 13),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: onChanged == null ? AppColors.muted : AppColors.primary,
            size: 20,
          ),
          hint: Text(
            hint ?? '',
            style: AppTextStyles.subtitle.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          onChanged: onChanged,
          items: items.map((item) {
            final label = item.toString();
            final isAction = label == '+ Personalizado';
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                label,
                style: isAction
                    ? AppTextStyles.subtitle.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      )
                    : AppTextStyles.title.copyWith(fontSize: 13),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}