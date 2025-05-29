import 'package:flutter/material.dart';

class AnimatedSearchCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool isLoading;
  final String hintText;
  final String buttonText;
  final IconData icon;

  const AnimatedSearchCard({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.isLoading,
    required this.hintText,
    required this.buttonText,
    required this.icon,
  });

  @override
  State<AnimatedSearchCard> createState() => _AnimatedSearchCardState();
}

class _AnimatedSearchCardState extends State<AnimatedSearchCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _isFocused 
                    ? const Color(0xFF6366F1).withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                  blurRadius: _isFocused ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _isFocused 
                  ? const Color(0xFF6366F1).withOpacity(0.3)
                  : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isFocused = hasFocus;
                    });
                    if (hasFocus) {
                      _scaleController.forward();
                    } else {
                      _scaleController.reverse();
                    }
                  },
                  child: TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      labelText: widget.hintText,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: const Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    onSubmitted: (_) => widget.onSearch(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : widget.onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: widget.isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Buscando...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(widget.icon, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                widget.buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
      },
    );
  }
}
