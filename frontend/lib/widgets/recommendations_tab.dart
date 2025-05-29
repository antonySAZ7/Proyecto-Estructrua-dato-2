import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'loading_widget.dart';
import 'error_widget.dart';
import 'food_card.dart';
import 'animated_search_card.dart';

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({super.key});

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> with TickerProviderStateMixin {
  final TextEditingController _usuarioController = TextEditingController();
  List<String> _recomendaciones = [];
  List<String> _gustos = [];
  String _nota = '';
  bool _isLoading = false;
  String? _error;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _slideController.dispose();
    _usuarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarRecomendaciones() async {
    if (_usuarioController.text.trim().isEmpty) {
      setState(() {
        _error = 'Por favor, ingresa un nombre de usuario';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _recomendaciones = [];
      _gustos = [];
      _nota = '';
    });

    try {
      final data = await ApiService.obtenerRecomendaciones(_usuarioController.text);
      setState(() {
        _recomendaciones = data['recomendaciones'];
        _gustos = data['gustos'];
        _nota = data['nota'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descubre tu próxima\ncomida favorita',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: const Color(0xFF1F2937),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Obtén recomendaciones personalizadas basadas en tus gustos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedSearchCard(
              controller: _usuarioController,
              onSearch: _cargarRecomendaciones,
              isLoading: _isLoading,
              hintText: 'Ingresa tu nombre',
              buttonText: 'Obtener Recomendaciones',
              icon: Icons.auto_awesome,
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Expanded(
                child: LoadingWidget(
                  message: 'Analizando tus preferencias...',
                  icon: Icons.psychology,
                ),
              )
            else if (_error != null)
              Expanded(
                child: CustomErrorWidget(
                  message: _error!,
                  onRetry: _cargarRecomendaciones,
                ),
              )
            else if (_recomendaciones.isNotEmpty || _gustos.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_nota.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.1),
                                const Color(0xFF8B5CF6).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _nota,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_gustos.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              'Tus Gustos',
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
                                '${_gustos.length}',
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _gustos.length,
                          itemBuilder: (context, index) {
                            return FoodCard(
                              title: _gustos[index],
                              subtitle: 'Basado en tus preferencias',
                              icon: Icons.favorite_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFEF4444).withOpacity(0.1),
                                  const Color(0xFFF97316).withOpacity(0.1),
                                ],
                              ),
                              index: index,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        children: [
                          Text(
                            'Recomendaciones',
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
                              '${_recomendaciones.length}',
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recomendaciones.length,
                        itemBuilder: (context, index) {
                          return FoodCard(
                            title: _recomendaciones[index],
                            subtitle: 'Recomendado especialmente para ti',
                            icon: Icons.auto_awesome,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.1),
                                const Color(0xFF8B5CF6).withOpacity(0.1),
                              ],
                            ),
                            index: index,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Comienza tu búsqueda',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu nombre para obtener recomendaciones personalizadas',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}