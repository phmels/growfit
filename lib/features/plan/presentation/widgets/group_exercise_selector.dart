import 'package:flutter/material.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/plan/data/exercise_catalog.dart';

/// Dropdown para selecionar um grupamento muscular.
/// Inclui opção "+ Personalizado" para digitar um nome livre.
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
    // Se o valor inicial não está no catálogo, é um valor personalizado
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
        title: Text('Novo Grupamento', style: AppTextStyles.title.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.title.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Ex: Cardio, Funcional...',
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
          ),
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
                style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [...ExerciseCatalog.groups, _custom];
    // Se o valor selecionado é personalizado (não está no catálogo), mostra ele
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

/// Dropdown para selecionar um exercício baseado no grupamento selecionado.
/// Inclui opção "+ Personalizado" para digitar um nome livre.
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
  static const _custom = '+ Personalizado';
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(ExerciseDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o grupamento mudou, reseta a seleção
    if (oldWidget.group != widget.group) {
      setState(() => _selected = null);
    }
  }

  List<String> get _exercises {
    if (widget.group == null) return [];
    return ExerciseCatalog.exercisesFor(widget.group!);
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
        title: Text('Novo Exercício', style: AppTextStyles.title.copyWith(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.title.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Ex: Supino com Corrente...',
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
          ),
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
                style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _exercises;
    final items = [...exercises, _custom];
    final isCustomValue =
        _selected != null && !exercises.contains(_selected);
    final isDisabled = widget.group == null;

    return _StyledDropdown<String>(
      value: isCustomValue ? null : _selected,
      hint: isDisabled
          ? 'Selecione um grupamento primeiro'
          : isCustomValue
              ? _selected
              : 'Selecione o exercício',
      items: isDisabled ? [] : items,
      onChanged: isDisabled ? null : _onSelect,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Dropdown estilizado reutilizável
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