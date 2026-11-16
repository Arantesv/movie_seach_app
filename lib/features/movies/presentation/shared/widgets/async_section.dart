import 'package:flutter/material.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/retry_message.dart';

class AsyncSection<T> extends StatelessWidget {
  const AsyncSection({
    super.key,
    required this.state,
    required this.onRetry,
    required this.builder,
  });

  final LoadState<T> state;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => switch (state) {
    LoadInitial<T>() || LoadInProgress<T>() => const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    ),
    LoadFailure<T>(:final message) => RetryMessage(
      message: message,
      onRetry: onRetry,
    ),
    LoadSuccess<T>(:final data) => builder(data),
  };
}
