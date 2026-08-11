import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';

class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key});

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  bool _isTechnicalActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Women With Wheels'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              context.go(AppRoutes.home);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isTechnicalActive = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isTechnicalActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Technical',
                        style: TextStyle(
                          color: _isTechnicalActive ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isTechnicalActive = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isTechnicalActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Self-Empowerment',
                        style: TextStyle(
                          color: !_isTechnicalActive ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF8A6C8C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Module List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildModuleCard(
                  title: 'Learning License',
                  duration: '140 min',
                  status: ModuleStatus.completed,
                ),
                _buildModuleCard(
                  title: 'On-road Module',
                  duration: '120 min',
                  status: ModuleStatus.completed,
                ),
                _buildModuleCard(
                  title: 'Permanent License',
                  duration: '125 min',
                  status: ModuleStatus.active,
                ),
                _buildModuleCard(
                  title: 'Self Drive',
                  duration: '138 min',
                  status: ModuleStatus.locked,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String duration,
    required ModuleStatus status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFECCC), // Light orange bg for icon
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFB74D), width: 2),
          ),
          child: const Icon(
            Icons.article,
            color: Color(0xFFFFB74D),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Duration : $duration',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        trailing: _buildTrailingIcon(status),
        onTap: status == ModuleStatus.active
            ? () {
                context.push(AppRoutes.assessment);
              }
            : null,
      ),
    );
  }

  Widget _buildTrailingIcon(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.completed:
        return const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          radius: 16,
          child: Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
        );
      case ModuleStatus.active:
        return const CircleAvatar(
          backgroundColor: Color(0xFFE1BEE7),
          radius: 16,
          child: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
        );
      case ModuleStatus.locked:
        return const CircleAvatar(
          backgroundColor: Color(0xFFEEEEEE),
          radius: 16,
          child: Icon(Icons.lock, color: Colors.grey, size: 16),
        );
    }
  }
}

enum ModuleStatus { completed, active, locked }
