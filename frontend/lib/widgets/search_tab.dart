import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'loading_widget.dart';
import 'error_widget.dart';
import 'food_card.dart';
import 'animated_search_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with TickerProviderStateMixin {
  late TabController _searchTabController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchTabController = TabController(length: 2, vsync: this);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _searchTabController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _searchTabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.category_rounded, size: 20),
                  text: 'Por Categoría',
                ),
                Tab(
                  icon: Icon(Icons.restaurant_rounded, size: 20),
                  text: 'Ingredientes',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _searchTabController,
              children: const [
                CategorySearchWidget(),
                IngredientsSearchWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySearchWidget extends StatefulWidget {
  const CategorySearchWidget({super.key});

  @override
  State<CategorySearchWidget> createState() => _CategorySearchWidgetState();
}

class _CategorySearchWidgetState extends State<CategorySearchWidget> {
  final TextEditingController _tipoController = TextEditingController();
  List<String> _comidas = [];
  bool _isLoading = false;
  String? _error;

  final List<Map<String, dynamic>> _categoriasSugeridas = [
    {'name': 'Italiana', 'icon': '🍝', 'color': Color(0xFFEF4444)},
    {'name': 'China', 'icon': '🥢', 'color': Color(0xFFF59E0B)},
    {'name': 'Mexicana', 'icon': '🌮', 'color': Color(0xFF10B981)},
    {'name': 'Japonesa', 'icon': '🍣', 'color': Color(0xFF6366F1)},
    {'name': 'India', 'icon': '🍛', 'color': Color(0xFFEC4899)},
    {'name': 'Francesa', 'icon': '🥐', 'color': Color(0xFF8B5CF6)},
  ];

  Future<void> _obtenerPorCategoria(String categoria) async {
    _tipoController.text = categoria;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.obtenerPorCategoria(categoria);
      setState(() {
        _comidas = List<String>.from(data['comidas'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al buscar por categoría';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explora por\ncategorías',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: const Color(0xFF1F2937),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre deliciosos platos de diferentes culturas',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Categorías populares',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categoriasSugeridas.length,
              itemBuilder: (context, index) {
                final categoria = _categoriasSugeridas[index];
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(
                    right: index == _categoriasSugeridas.length - 1 ? 0 : 16,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _obtenerPorCategoria(categoria['name']),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade100,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: categoria['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  categoria['icon'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categoria['name'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSearchCard(
            controller: _tipoController,
            onSearch: () => _obtenerPorCategoria(_tipoController.text),
            isLoading: _isLoading,
            hintText: 'Buscar categoría personalizada',
            buttonText: 'Buscar Comidas',
            icon: Icons.search_rounded,
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(
              child: LoadingWidget(
                message: 'Explorando deliciosas opciones...',
                icon: Icons.restaurant_menu,
              ),
            )
          else if (_error != null)
            Expanded(child: CustomErrorWidget(message: _error!))
          else if (_comidas.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Resultados',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_comidas.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _comidas.length,
                      itemBuilder: (context, index) {
                        return FoodCard(
                          title: _comidas[index],
                          subtitle: 'Categoría: ${_tipoController.text}',
                          icon: Icons.restaurant_rounded,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFEC4899).withOpacity(0.1),
                              const Color(0xFFF97316).withOpacity(0.1),
                            ],
                          ),
                          index: index,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tipoController.dispose();
    super.dispose();
  }
}

class IngredientsSearchWidget extends StatefulWidget {
  const IngredientsSearchWidget({super.key});

  @override
  State<IngredientsSearchWidget> createState() => _IngredientsSearchWidgetState();
}

class _IngredientsSearchWidgetState extends State<IngredientsSearchWidget> {
  final TextEditingController _platoController = TextEditingController();
  List<String> _ingredientes = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _obtenerIngredientes() async {
    if (_platoController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.obtenerIngredientes(_platoController.text);
      setState(() {
        _ingredientes = List<String>.from(data['ingredientes'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al obtener ingredientes';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descubre\ningredientes',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: const Color(0xFF1F2937),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conoce qué ingredientes componen tus platos favoritos',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSearchCard(
            controller: _platoController,
            onSearch: _obtenerIngredientes,
            isLoading: _isLoading,
            hintText: 'Nombre del plato',
            buttonText: 'Ver Ingredientes',
            icon: Icons.eco_rounded,
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(
              child: LoadingWidget(
                message: 'Analizando ingredientes...',
                icon: Icons.eco,
              ),
            )
          else if (_error != null)
            Expanded(child: CustomErrorWidget(message: _error!))
          else if (_ingredientes.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.1),
                          const Color(0xFF059669).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ingredientes de "${_platoController.text}"',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_ingredientes.length} ingredientes encontrados',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _ingredientes.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: Color(0xFF059669),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _ingredientes[index],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _platoController.dispose();
    super.dispose();
  }
}
