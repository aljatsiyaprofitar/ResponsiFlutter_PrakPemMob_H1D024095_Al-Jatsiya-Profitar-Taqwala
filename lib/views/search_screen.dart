import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../models/location_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              _buildTabBar(),
              Expanded(child: _buildTabView(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Pilih Lokasi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final searchVM = context.read<SearchViewModel>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Cari nama kota...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    searchVM.clearSearch();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {});
          searchVM.searchLocations(value);
          if (value.isNotEmpty) {
            _tabController.animateTo(0);
          }
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      tabs: const [
        Tab(text: 'Hasil Pencarian'),
        Tab(text: 'Favorit'),
      ],
    );
  }

  Widget _buildTabView(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSearchResults(context),
        _buildFavorites(context),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, vm, _) {
        switch (vm.state) {
          case SearchState.idle:
            return _buildEmptySearchHint();
          case SearchState.loading:
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          case SearchState.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      vm.errorMessage,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          case SearchState.success:
            if (vm.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off,
                        color: Colors.white54, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Kota "${vm.query}" tidak ditemukan',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: vm.results.length,
              itemBuilder: (_, index) =>
                  _buildLocationTile(context, vm.results[index]),
            );
        }
      },
    );
  }

  Widget _buildFavorites(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, weatherVM, _) {
        if (weatherVM.favorites.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      color: Colors.white54, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada lokasi favorit',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan ♡ di halaman utama\nuntuk menyimpan lokasi',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: weatherVM.favorites.length,
          itemBuilder: (_, index) {
            final loc = weatherVM.favorites[index];
            return _buildLocationTile(
              context,
              loc,
              onDelete: () => weatherVM.removeFavorite(loc.id),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    LocationModel location, {
    VoidCallback? onDelete,
  }) {
    final weatherVM = context.read<WeatherViewModel>();
    final isSelected = weatherVM.selectedLocation?.id == location.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white54 : Colors.white12,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white24,
          child: Text(
            location.name.isNotEmpty
                ? location.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          location.displayName.replaceFirst('${location.name}, ', ''),
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                onPressed: onDelete,
              )
            : isSelected
                ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                : null,
        onTap: () async {
          await weatherVM.selectLocation(location);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildEmptySearchHint() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: Colors.white54, size: 56),
          SizedBox(height: 16),
          Text(
            'Ketik nama kota untuk mencari',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Contoh: Jakarta, Bandung, Surabaya',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
