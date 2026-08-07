import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/widgets/add_user_page.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'All';

  // Updated Roles: Admin, Seller, Customer
  final List<String> _roles = ['All', 'Admin', 'Seller', 'Customer'];

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Maria Santos',
      'email': 'maria.santos@legitsmoothie.ph',
      'role': 'Admin',
      'status': 'Active',
      'avatar': 'https://i.pravatar.cc/150?img=47',
      'lastActive': 'Just now',
    },
    {
      'name': 'Juan Dela Cruz',
      'email': 'juan.dc@legitsmoothie.ph',
      'role': 'Seller',
      'status': 'Active',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'lastActive': '10m ago',
    },
    {
      'name': 'Angela Reyes',
      'email': 'angela.r@gmail.com',
      'role': 'Customer',
      'status': 'Active',
      'avatar': 'https://i.pravatar.cc/150?img=32',
      'lastActive': '2h ago',
    },
    {
      'name': 'Mark Torralba',
      'email': 'mark.t@gmail.com',
      'role': 'Customer',
      'status': 'Inactive',
      'avatar': 'https://i.pravatar.cc/150?img=60',
      'lastActive': '3 days ago',
    },
    {
      'name': 'Bea Alonzo',
      'email': 'bea.alonzo@legitsmoothie.ph',
      'role': 'Seller',
      'status': 'Active',
      'avatar': 'https://i.pravatar.cc/150?img=45',
      'lastActive': '5m ago',
    },
    {
      'name': 'Carlos Yulo',
      'email': 'carlos.y@gmail.com',
      'role': 'Customer',
      'status': 'Active',
      'avatar': 'https://i.pravatar.cc/150?img=15',
      'lastActive': '1h ago',
    },
    {
      'name': 'Hidilyn Diaz',
      'email': 'hidilyn.d@legitsmoothie.ph',
      'role': 'Admin',
      'status': 'Active',
      'avatar': 'https://i.pravatar.cc/150?img=35',
      'lastActive': 'Just now',
    },
    {
      'name': 'Kobe Paras',
      'email': 'kobe.p@gmail.com',
      'role': 'Customer',
      'status': 'Inactive',
      'avatar': 'https://i.pravatar.cc/150?img=52',
      'lastActive': '1 week ago',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final subTextColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ??
        AppColors.greyText;

    // Filter users based on Search & Role selection
    final filteredUsers = _users.where((user) {
      final matchesSearch =
          user['name'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          user['email'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesRole =
          _selectedRole == 'All' || user['role'] == _selectedRole;
      return matchesSearch && matchesRole;
    }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // 1. Header & Quick Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      (isDarkMode
                                              ? AppColors.cream
                                              : AppColors.bobaBrown)
                                          .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: isDarkMode
                                      ? AppColors.cream
                                      : AppColors.bobaBrown,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'User Management',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage accounts, roles & permissions',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      // Top Action Button
                      Material(
                        color: AppColors.bobaBrown,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddUserPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Users',
                          value: '${_users.length}',
                          icon: Icons.people_alt_outlined,
                          accentColor: AppColors.bobaBrown,
                          theme: theme,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Active Accounts',
                          value:
                              '${_users.where((u) => u['status'] == 'Active').length}',
                          icon: Icons.verified_user_outlined,
                          accentColor: AppColors.success,
                          theme: theme,
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.04),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDarkMode ? 0.25 : 0.03,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: subTextColor,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: subTextColor,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips (All, Admin, Seller, Customer)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _roles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final role = _roles[index];
                        final isSelected = _selectedRole == role;

                        return InkWell(
                          onTap: () => setState(() => _selectedRole = role),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.bobaBrown
                                  : (isDarkMode
                                        ? theme.cardColor
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.bobaBrown
                                    : (isDarkMode
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.black.withOpacity(0.06)),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.bobaBrown.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkMode
                                            ? Colors.white70
                                            : AppColors.darkText),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. User Cards List
          filteredUsers.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No matching users found.',
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(
                        user: user,
                        theme: theme,
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subTextColor: subTextColor,
                      );
                    }, childCount: filteredUsers.length),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // Metric Card Widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required ThemeData theme,
    required bool isDarkMode,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // User Item Card
  Widget _buildUserCard({
    required Map<String, dynamic> user,
    required ThemeData theme,
    required bool isDarkMode,
    required Color textColor,
    required Color subTextColor,
  }) {
    final bool isActive = user['status'] == 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(user['avatar']),
            backgroundColor: AppColors.bobaBrown.withOpacity(0.15),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user['name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildRoleBadge(user['role'], isDarkMode),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user['email'],
                  style: TextStyle(fontSize: 12, color: subTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${user['status']} • ${user['lastActive']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? AppColors.success : subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: subTextColor, size: 20),
            color: theme.cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'status') {
                setState(() {
                  user['status'] = isActive ? 'Inactive' : 'Active';
                });
              } else if (value.startsWith('role_')) {
                final newRole = value.replaceFirst('role_', '');
                setState(() {
                  user['role'] = newRole;
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Assign Role',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'role_Admin',
                child: Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 18,
                      color: AppColors.bobaBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set as Admin',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'role_Seller',
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set as Seller',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'role_Customer',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: AppColors.bobaBrown,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set as Customer',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(
                      isActive
                          ? Icons.block_rounded
                          : Icons.check_circle_outline,
                      size: 18,
                      color: isActive ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'Deactivate' : 'Activate',
                      style: TextStyle(
                        color: isActive ? AppColors.error : AppColors.success,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Role Badge Chip using AppColors
  Widget _buildRoleBadge(String role, bool isDarkMode) {
    Color badgeBg;
    Color badgeText;

    switch (role) {
      case 'Admin':
        badgeBg = AppColors.bobaBrown.withOpacity(isDarkMode ? 0.25 : 0.12);
        badgeText = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
        break;
      case 'Seller':
        badgeBg = AppColors.bobaBrown.withOpacity(isDarkMode ? 0.25 : 0.12);
        badgeText = isDarkMode ? AppColors.cream : AppColors.bobaBrown;

        break;
      case 'Customer':
      default:
        badgeBg = AppColors.cream.withOpacity(isDarkMode ? 0.25 : 0.2);
        badgeText = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeText,
        ),
      ),
    );
  }
}
