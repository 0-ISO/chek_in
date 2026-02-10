import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../utils/number_formatter.dart';
import '../utils/animations.dart';
import '../widgets/statistics_grid.dart';
import '../widgets/compact_statistics.dart';
import './projects/project_form_screen.dart';
import './buildings/building_form_screen.dart';
import './apartments/apartment_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOutBack,
    );
    
    _fabAnimationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final projectProvider = context.read<ProjectProvider>();
    await projectProvider.loadProjects();
    
    setState(() => _isLoading = false);
  }

  Future<void> _animateRefresh() async {
    _fabAnimationController.reset();
    await _fabAnimationController.forward();
  }

  void _animateButtonPress() {
    _fabAnimationController.reset();
    _fabAnimationController.forward();
  }

  void _navigateToAddScreen() {
    switch (_selectedIndex) {
      case 0:
        Navigator.push(
          context,
          CustomPageRoute(
            page: const ProjectFormScreen(),
            routeType: RouteType.slide,
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          CustomPageRoute(
            page: const BuildingFormScreen(),
            routeType: RouteType.slide,
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          CustomPageRoute(
            page: const ApartmentFormScreen(),
            routeType: RouteType.slide,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _animateRefresh();
              _loadData();
            },
            tooltip: 'Обновить данные',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildProjectsTab(projectProvider, authProvider),
          _buildBuildingsTab(projectProvider),
          _buildApartmentsTab(projectProvider),
        ],
      ),
      bottomNavigationBar: AppAnimations.slideInFromBottom(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Проекты',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work),
              label: 'Здания',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment),
              label: 'Квартиры',
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            _animateButtonPress();
            _navigateToAddScreen();
          },
          backgroundColor: const Color(0xFFE5BD77),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProjectsTab(ProjectProvider projectProvider, AuthProvider authProvider) {
    return Container(
      color: const Color(0xFFF5EFE6),
      child: _isLoading
          ? _buildLoadingAnimation()
          : RefreshIndicator(
              onRefresh: () async {
                await _animateRefresh();
                return _loadData();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: AppAnimations.fadeSlideIn(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildWelcomeCard(authProvider),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: AppAnimations.slideInFromTop(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Общая статистика',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: AppAnimations.scaleIn(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: StatisticsGrid(items: _getMainStatistics(projectProvider)),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: AppAnimations.fadeIn(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CompactStatistics(items: _getAdditionalStatistics(projectProvider)),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: AppAnimations.slideInFromBottom(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildProjectsHeader(projectProvider),
                      ),
                    ),
                  ),
                  
                  if (projectProvider.projects.isEmpty)
                    SliverToBoxAdapter(
                      child: AppAnimations.pulse(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: _buildEmptyState(
                            icon: Icons.business,
                            title: 'Нет проектов',
                            description: 'Создайте первый проект для начала работы',
                            buttonText: 'Создать проект',
                            onPressed: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  page: const ProjectFormScreen(),
                                  routeType: RouteType.slide,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final project = projectProvider.projects[index];
                          final projectBuildings = projectProvider.buildings
                              .where((b) => b.projectId == project.id)
                              .toList();
                          
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 12,
                              top: index == 0 ? 0 : 0,
                            ),
                            child: AppAnimations.staggeredCard(
                              index: index,
                              child: _buildProjectCard(project, projectBuildings, projectProvider),
                            ),
                          );
                        },
                        childCount: projectProvider.projects.length,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildBuildingsTab(ProjectProvider projectProvider) {
    return Container(
      color: const Color(0xFFF5EFE6),
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppAnimations.fadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Здания',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Всего зданий: ${projectProvider.buildings.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            if (projectProvider.buildings.isEmpty)
              SliverToBoxAdapter(
                child: AppAnimations.pulse(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildEmptyState(
                      icon: Icons.home_work,
                      title: 'Нет зданий',
                      description: 'Добавьте здание к проекту',
                      buttonText: 'Добавить здание',
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: const BuildingFormScreen(),
                            routeType: RouteType.slide,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final building = projectProvider.buildings[index];
                    final project = building.projectId != null
                        ? projectProvider.getProjectById(building.projectId)
                        : null;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 12,
                        top: index == 0 ? 0 : 0,
                      ),
                      child: AppAnimations.staggeredCard(
                        index: index,
                        child: _buildBuildingCard(building, project, projectProvider),
                      ),
                    );
                  },
                  childCount: projectProvider.buildings.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApartmentsTab(ProjectProvider projectProvider) {
    return Container(
      color: const Color(0xFFF5EFE6),
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppAnimations.fadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Квартиры',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Всего квартир: ${NumberFormatter.formatNumber(projectProvider.apartments.length.toDouble())}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            if (projectProvider.apartments.isEmpty)
              SliverToBoxAdapter(
                child: AppAnimations.pulse(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildEmptyState(
                      icon: Icons.apartment,
                      title: 'Нет квартир',
                      description: 'Добавьте квартиры к зданиям',
                      buttonText: 'Добавить квартиру',
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: const ApartmentFormScreen(),
                            routeType: RouteType.slide,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final apartment = projectProvider.apartments[index];
                    final building = apartment.buildingId != null
                        ? projectProvider.getBuildingById(apartment.buildingId)
                        : null;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 8,
                        top: index == 0 ? 0 : 0,
                      ),
                      child: AppAnimations.staggeredCard(
                        index: index,
                        child: _buildApartmentCard(apartment, building, projectProvider),
                      ),
                    );
                  },
                  childCount: projectProvider.apartments.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return AppAnimations.tiltIn(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF5EFE6),
                const Color(0xFFE5BD77).withOpacity(0.3),
            ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              AppAnimations.pulse(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFCC7952),
                  child: Text(
                    authProvider.currentUser?.displayName.substring(0, 1) ?? 'П',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAnimations.fadeSlideIn(
                      offset: const Offset(30, 0),
                      child: Text(
                        'Добро пожаловать,',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppAnimations.fadeSlideIn(
                      offset: const Offset(30, 0),
                      child: Text(
                        authProvider.currentUser?.displayName ?? 'Пользователь',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppAnimations.scaleIn(
                      child: Chip(
                        label: Text(
                          _getRoleName(authProvider.currentUser?.role ?? UserRole.worker),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsHeader(ProjectProvider projectProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppAnimations.fadeIn(
              child: const Text(
                'Проекты',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                AppAnimations.scaleIn(
                  child: IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: () {},
                  ),
                ),
                AppAnimations.scaleIn(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(
                          page: const ProjectFormScreen(),
                          routeType: RouteType.slide,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Добавить'),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProjectCard(Project project, List<dynamic> projectBuildings, ProjectProvider projectProvider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(
            page: ProjectFormScreen(project: project),
            routeType: RouteType.slide,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAnimations.pulse(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor(project.status),
                  child: Text(
                    project.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppAnimations.fadeIn(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppAnimations.scaleIn(
                          child: Chip(
                            label: Text(
                              _getProjectStatusName(project.status),
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: _getStatusColor(project.status),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    if (project.description != null && project.description!.isNotEmpty)
                      AppAnimations.fadeSlideIn(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            project.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    
                    AppAnimations.fadeIn(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if (project.city != null && project.city!.isNotEmpty)
                            _buildDetailChip(
                              icon: Icons.location_on,
                              text: project.city!,
                            ),
                          
                          if (project.budget != null && project.budget! > 0)
                            _buildDetailChip(
                              icon: Icons.attach_money,
                              text: NumberFormatter.formatCurrency(project.budget!),
                            ),
                          
                          _buildDetailChip(
                            icon: Icons.trending_up,
                            text: '${(project.progress * 100).toStringAsFixed(1)}%',
                          ),
                          
                          _buildDetailChip(
                            icon: Icons.home_work,
                            text: '${projectBuildings.length} зданий',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuildingCard(dynamic building, dynamic project, ProjectProvider projectProvider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(
            page: BuildingFormScreen(
              building: building,
              selectedProject: project,
            ),
            routeType: RouteType.slide,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAnimations.pulse(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE5BD77),
                  child: Icon(
                    Icons.home_work,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppAnimations.fadeIn(
                            child: Text(
                              building.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    AppAnimations.fadeIn(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _buildDetailChip(
                            icon: Icons.stairs,
                            text: 'Этажей: ${building.floors}',
                          ),
                          
                          _buildDetailChip(
                            icon: Icons.door_front_door,
                            text: 'Кв./этаж: ${building.apartmentsPerFloor}',
                          ),
                          
                          if (project != null)
                            _buildDetailChip(
                              icon: Icons.business,
                              text: project.name,
                            ),
                          
                          _buildDetailChip(
                            icon: Icons.calculate,
                            text: 'Всего: ${building.totalApartments} кв.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApartmentCard(dynamic apartment, dynamic building, ProjectProvider projectProvider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CustomPageRoute(
            page: ApartmentFormScreen(
              apartment: apartment,
              building: building,
            ),
            routeType: RouteType.slide,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAnimations.pulse(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2196F3),
                  child: Text(
                    apartment.number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppAnimations.fadeIn(
                            child: Text(
                              'Квартира №${apartment.number}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    AppAnimations.fadeIn(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _buildDetailChip(
                            icon: Icons.stairs,
                            text: 'Этаж: ${apartment.floor}',
                          ),
                          
                          if (building != null)
                            _buildDetailChip(
                              icon: Icons.home_work,
                              text: building.name,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({required IconData icon, required String text}) {
    return AppAnimations.scaleIn(
      beginScale: 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC7952),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppAnimations.pulse(
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE5BD77),
              child: Icon(
                Icons.home_work,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppAnimations.fadeIn(
            child: const Text(
              'Загружаем данные...',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFCC7952),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppAnimations.fadeIn(
            child: SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFCC7952)),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<StatItem> _getMainStatistics(ProjectProvider projectProvider) {
    final stats = projectProvider.getStatistics();
    
    return [
      StatItem.projectCount(projectProvider.projects.length),
      StatItem.buildingCount(projectProvider.buildings.length),
      StatItem.apartmentCount(projectProvider.apartments.length),
      StatItem.budget(stats['totalBudget'] ?? 0),
      StatItem.spent(stats['totalSpent'] ?? 0),
      StatItem.progress(_calculateAverageProgress(projectProvider) / 100),
    ];
  }

  List<StatItem> _getAdditionalStatistics(ProjectProvider projectProvider) {
    if (projectProvider.projects.isEmpty) return [];
    
    final totalFloors = projectProvider.buildings.fold(
      0, (sum, b) => sum + b.floors);
    final avgApartments = _calculateAvgApartmentsPerFloor(projectProvider);
    final activeProjects = projectProvider.getProjectsByStatus(ProjectStatus.inProgress).length;
    final cityCount = _countUniqueCities(projectProvider);
    
    return [
      StatItem(
        title: 'Этажей',
        value: NumberFormatter.compactNumber(totalFloors),
        icon: Icons.stairs,
        color: const Color(0xFF795548),
      ),
      StatItem(
        title: 'Кв./этаж',
        value: avgApartments.toStringAsFixed(1),
        icon: Icons.door_front_door,
        color: const Color(0xFF607D8B),
      ),
      StatItem(
        title: 'Активные',
        value: activeProjects.toString(),
        icon: Icons.play_arrow,
        color: const Color(0xFF4CAF50),
      ),
      StatItem(
        title: 'Городов',
        value: cityCount.toString(),
        icon: Icons.location_city,
        color: const Color(0xFF3F51B5),
      ),
    ];
  }

  double _calculateAverageProgress(ProjectProvider projectProvider) {
    if (projectProvider.projects.isEmpty) return 0;
    
    final totalProgress = projectProvider.projects.fold(
      0.0, (sum, project) => sum + project.progress);
    
    return (totalProgress / projectProvider.projects.length * 100);
  }

  double _calculateAvgApartmentsPerFloor(ProjectProvider projectProvider) {
    if (projectProvider.buildings.isEmpty) return 0;
    
    final totalApartmentsPerFloor = projectProvider.buildings.fold(
      0, (sum, building) => sum + building.apartmentsPerFloor);
    
    return totalApartmentsPerFloor / projectProvider.buildings.length;
  }

  int _countUniqueCities(ProjectProvider projectProvider) {
    final cities = <String>{};
    for (final project in projectProvider.projects) {
      if (project.city != null && project.city!.isNotEmpty) {
        cities.add(project.city!);
      }
    }
    return cities.length;
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Администратор';
      case UserRole.manager:
        return 'Менеджер';
      case UserRole.supervisor:
        return 'Начальник';
      case UserRole.worker:
        return 'Работник';
      case UserRole.viewer:
        return 'Наблюдатель';
    }
  }

  String _getProjectStatusName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Планирование';
      case ProjectStatus.inProgress:
        return 'В работе';
      case ProjectStatus.onHold:
        return 'Приостановлен';
      case ProjectStatus.completed:
        return 'Завершен';
      case ProjectStatus.cancelled:
        return 'Отменен';
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.inProgress:
        return Colors.orange.withOpacity(0.2);
      case ProjectStatus.completed:
        return Colors.green.withOpacity(0.2);
      case ProjectStatus.planning:
        return Colors.blue.withOpacity(0.2);
      case ProjectStatus.onHold:
        return Colors.yellow.withOpacity(0.2);
      case ProjectStatus.cancelled:
        return Colors.red.withOpacity(0.2);
    }
  }
}