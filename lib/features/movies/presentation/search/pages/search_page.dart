import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/app/navigation/app_navigator.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';
import 'package:movie_search_app/features/movies/presentation/search/widgets/movie_list_section.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/retry_message.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => context.read<SearchCubit>().search(_controller.text);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: width * 0.04),
                decoration: InputDecoration(
                  labelText: 'Digite o título do filme que deseja buscar',
                  labelStyle: TextStyle(fontSize: width * 0.04),
                  suffixIcon: IconButton(
                    tooltip: 'Buscar filmes',
                    icon: Icon(Icons.search, size: width * 0.06),
                    onPressed: _submit,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) => switch (state) {
                    SearchInitial() => const Center(
                      child: Text('Busque um filme pelo título.'),
                    ),
                    SearchLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    SearchEmpty() => const Center(
                      child: Text('Nenhum filme encontrado.'),
                    ),
                    SearchFailure(:final message) => RetryMessage(
                      message: message,
                      onRetry: context.read<SearchCubit>().retry,
                    ),
                    SearchSuccess(:final movies) => ListView.builder(
                      key: const PageStorageKey('search-results'),
                      itemCount: movies.length,
                      itemBuilder: (context, index) => MovieListSection(
                        movie: movies[index],
                        onTap: () => AppNavigator.openMovieDetails(
                          context,
                          movies[index].id,
                        ),
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
