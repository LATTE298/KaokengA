import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef EmptyPredicate<T> = bool Function(T data);

class ChildAsyncView<T> extends StatelessWidget {
  const ChildAsyncView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget? empty;
  final EmptyPredicate<T>? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading:
          () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (e, st) => error?.call(e, st) ?? const SizedBox.shrink(),
      data: (resolved) {
        if (isEmpty?.call(resolved) ?? false) {
          return empty ?? const SizedBox.shrink();
        }
        return data(resolved);
      },
    );
  }
}
