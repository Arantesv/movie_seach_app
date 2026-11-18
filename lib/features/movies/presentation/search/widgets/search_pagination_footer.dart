import 'package:flutter/material.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/retry_message.dart';

class SearchPaginationFooter extends StatelessWidget {
  const SearchPaginationFooter({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final NextPageState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
    NextPageIdle() => const SizedBox.shrink(),
    NextPageLoading() => const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    ),
    NextPageFailure(:final message) => RetryMessage(
      message: 'Não foi possível carregar mais filmes.\n$message',
      onRetry: onRetry,
    ),
  };
}
