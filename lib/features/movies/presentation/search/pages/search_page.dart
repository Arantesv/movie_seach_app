import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/app/navigation/app_navigator.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';
import 'package:movie_search_app/features/movies/presentation/search/widgets/movie_list_section.dart';
import 'package:movie_search_app/features/movies/presentation/search/widgets/search_pagination_footer.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/retry_message.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController(keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNeeded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleLoadCheck();
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _scheduleLoadCheck();
  }

  void _scheduleLoadCheck() {
    final cubit = context.read<SearchCubit>();
    final generation = cubit.generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || cubit.isClosed || cubit.generation != generation) return;
      _loadMoreIfNeeded();
    });
  }

  void _loadMoreIfNeeded() {
    if (!mounted ||
        !widget.isActive ||
        ModalRoute.of(context)?.isCurrent == false ||
        !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.hasContentDimensions && position.extentAfter <= 300) {
      context.read<SearchCubit>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<SearchCubit>().search(_controller.text);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

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
                child: BlocConsumer<SearchCubit, SearchState>(
                  listener: (context, state) {
                    if (state is SearchSuccess) _scheduleLoadCheck();
                  },
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
                    SearchSuccess(:final movies) =>
                      NotificationListener<ScrollMetricsNotification>(
                        onNotification: (_) {
                          _scheduleLoadCheck();
                          return false;
                        },
                        child: ListView.builder(
                          key: ValueKey(
                            'search-results-${context.read<SearchCubit>().generation}',
                          ),
                          controller: _scrollController,
                          itemCount:
                              movies.length + (state.hasNextPage ? 1 : 0),
                          itemBuilder: (context, index) =>
                              index == movies.length
                              ? SearchPaginationFooter(
                                  state: state.nextPage,
                                  onRetry: context
                                      .read<SearchCubit>()
                                      .retryNextPage,
                                )
                              : MovieListSection(
                                  key: ValueKey(movies[index].id),
                                  movie: movies[index],
                                  onTap: () => AppNavigator.openMovieDetails(
                                    context,
                                    movies[index].id,
                                  ),
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
