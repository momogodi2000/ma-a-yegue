import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/user_role_service_hybrid.dart';
import '../../../../core/database/unified_database_service.dart';

/// Admin User Management View
class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  Map<String, int> _roleStats = {};
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoleStatistics();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final userRoleService = context.read<UserRoleService>();

      List<Map<String, dynamic>> users;
      if (_selectedRoleFilter == 'all') {
        // Load users by getting all roles
        final db = UnifiedDatabaseService.instance;
        users = await db.getAllUsers();
      } else {
        users = await userRoleService.getUsersByRole(_selectedRoleFilter);
      }

      setState(() => _users = users);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRoleStatistics() async {
    try {
      final userRoleService = context.read<UserRoleService>();
      final stats = await userRoleService.getRoleStatistics();
      setState(() => _roleStats = stats);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading role statistics: $e');
      }
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      final userRoleService = context.read<UserRoleService>();
      await userRoleService.updateUserRole(userId, newRole);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle mis à jour avec succès')),
        );
        _loadUsers(); // Refresh the list
        _loadRoleStatistics(); // Refresh stats
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadUsers();
              _loadRoleStatistics();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Role Statistics Cards
          _buildRoleStatistics(),

          // Filter Dropdown
          _buildFilterDropdown(),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? const Center(child: Text('Aucun utilisateur trouvé'))
                : _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new user functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonctionnalité à venir: Ajouter un utilisateur'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoleStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('Admins', _roleStats['admin'] ?? 0, Colors.red),
          _buildStatCard(
            'Enseignants',
            _roleStats['teacher'] ?? 0,
            Colors.blue,
          ),
          _buildStatCard(
            'Apprenants',
            _roleStats['learner'] ?? 0,
            Colors.green,
          ),
          _buildStatCard('Total', _roleStats['total'] ?? 0, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Filtrer par rôle:'),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedRoleFilter,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous les rôles')),
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Administrateurs'),
                ),
                DropdownMenuItem(value: 'teacher', child: Text('Enseignants')),
                DropdownMenuItem(value: 'learner', child: Text('Apprenants')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRoleFilter = value);
                  _loadUsers();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['uid'] as String;
    final email = user['email'] as String? ?? 'N/A';
    final displayName = user['displayName'] as String? ?? 'Utilisateur anonyme';
    final role = user['role'] as String? ?? 'learner';
    final isActive = user['isActive'] as bool? ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role),
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(role),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRoleColor(role),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleUserAction(userId, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'promote_teacher',
              child: Text('Promouvoir enseignant'),
            ),
            const PopupMenuItem(
              value: 'promote_admin',
              child: Text('Promouvoir administrateur'),
            ),
            const PopupMenuItem(
              value: 'demote_learner',
              child: Text('Rétrograder apprenant'),
            ),
            const PopupMenuItem(
              value: 'toggle_status',
              child: Text('Activer/Désactiver'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(String userId, String action) async {
    switch (action) {
      case 'promote_teacher':
        await _updateUserRole(userId, 'teacher');
        break;
      case 'promote_admin':
        await _updateUserRole(userId, 'admin');
        break;
      case 'demote_learner':
        await _updateUserRole(userId, 'learner');
        break;
      case 'toggle_status':
        // TODO: Implement user activation/deactivation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fonctionnalité à venir: Activation/Désactivation'),
          ),
        );
        break;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'teacher':
      case 'instructor':
        return Colors.blue;
      case 'learner':
      case 'student':
      default:
        return Colors.green;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'teacher':
      case 'instructor':
        return 'Enseignant';
      case 'learner':
      case 'student':
      default:
        return 'Apprenant';
    }
  }
}
