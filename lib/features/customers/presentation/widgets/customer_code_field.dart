import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/customers_cubit.dart';
import '../../cubit/customers_state.dart';

class CustomerCodeField extends StatefulWidget {
  const CustomerCodeField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<CustomerCodeField> createState() => _CustomerCodeFieldState();
}

class _CustomerCodeFieldState extends State<CustomerCodeField> {
  bool _isCodeGenerated = false;

  void _generateCode() {
    context.read<CustomersCubit>().generateCustomerCode();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomersCubit, CustomersState>(
      listener: (context, state) {
        if (state is CustomerCodeGenerated) {
          setState(() {
            widget.controller.text = state.code;
            _isCodeGenerated = true;
          });
        }
      },
      child: Column(
        children: [
          TextField(
            controller: widget.controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'رمز العميل',
              hintText: 'سيتم إنشاء الرمز تلقائياً',
              prefixIcon: const Icon(Icons.tag),
              suffixIcon: _isCodeGenerated
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _generateCode,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.autorenew, size: 18),
                SizedBox(width: 8),
                Text('إنشاء رمز العميل'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
