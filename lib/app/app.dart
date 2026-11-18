import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/app/theme/app_theme.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/pages/search_page.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';
import 'package:movie_search_app/features/movies/presentation/home/pages/home_page.dart';
import 'package:movie_search_app/features/movies/presentation/home/cubit/home_cubit.dart';

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Movie Search App',
    theme: AppTheme.darkTheme,
    home: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              HomeCubit(context.read<MoviesRepository>())..load(),
        ),
        BlocProvider(
          create: (context) => SearchCubit(context.read<MoviesRepository>()),
        ),
      ],
      child: const MainPage(),
    ),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomePage(),
          SearchPage(isActive: _selectedIndex == 1),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedFontSize: width * 0.04,
        unselectedFontSize: width * 0.037,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: width * 0.05),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: width * 0.05),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }
}
