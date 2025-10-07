import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/teacher_viewmodel.dart';

/// Teacher Dashboard View
class TeacherDashboardView extends StatefulWidget {
  final String teacherId;

  const TeacherDashboardView({super.key, required this.teacherId});

  @override
  State<TeacherDashboardView> createState() => _TeacherDashboardViewState();
}

class _TeacherDashboardViewState extends State<TeacherDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadTeacherData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTeacherData() {
    final viewModel = Provider.of<TeacherViewModel>(context, listen: false);
    viewModel.loadTeacherProfile(widget.teacherId);
    viewModel.loadTeacherCourses(widget.teacherId);
    viewModel.loadTeacherStudents(widget.teacherId);
    viewModel.loadTeacherAnalytics(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Enseignant'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Vue d\'ensemble'),
            Tab(icon: Icon(Icons.school), text: 'Cours'),
            Tab(icon: Icon(Icons.people), text: 'Étudiants'),
            Tab(icon: Icon(Icons.assignment), text: 'Devoirs'),
            Tab(icon: Icon(Icons.grade), text: 'Notes'),
            Tab(icon: Icon(Icons.analytics), text: 'Analyses'),
          ],
        ),
      ),
      body: Consumer<TeacherViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${viewModel.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTeacherData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildCoursesTab(viewModel),
              _buildStudentsTab(viewModel),
              _buildAssignmentsTab(viewModel),
              _buildGradesTab(viewModel),
              _buildAnalyticsTab(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(TeacherViewModel viewModel) {
    final teacher = viewModel.teacherProfile;
    final analytics = viewModel.analytics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teacher Profile Card
          if (teacher != null) _buildTeacherProfileCard(teacher),
          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStatsCard(viewModel),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivityCard(viewModel),
          const SizedBox(height: 24),

          // Analytics Summary
          if (analytics != null) _buildAnalyticsSummaryCard(analytics),
        ],
      ),
    );
  }

  Widget _buildTeacherProfileCard(TeacherEntity teacher) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 40, color: Colors.blue[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue, ${teacher.name}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    teacher.bio,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.rating.toStringAsFixed(1)}/5.0',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(TeacherViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques rapides',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.school,
                  'Cours',
                  '${viewModel.courses.length}',
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.people,
                  'Étudiants',
                  '${viewModel.students.length}',
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.assignment,
                  'Devoirs',
                  '${viewModel.assignments.length}',
                  Colors.orange,
                ),
                _buildStatItem(
                  Icons.grade,
                  'Notes',
                  '${viewModel.grades.length}',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRecentActivityCard(TeacherViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité récente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (viewModel.courses.isEmpty)
              const Text('Aucune activité récente')
            else
              ...viewModel.courses
                  .take(3)
                  .map(
                    (course) => ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(course.title),
                      subtitle: Text(
                        'Créé le ${_formatDate(course.createdAt)}',
                      ),
                      trailing: Text(
                        course.status.name,
                        style: TextStyle(
                          color: _getStatusColor(course.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummaryCard(TeacherAnalyticsEntity analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé des analyses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnalyticsItem(
                  'Taux de réussite',
                  '${(analytics.completionRate * 100).toStringAsFixed(1)}%',
                  Colors.green,
                ),
                _buildAnalyticsItem(
                  'Temps moyen',
                  '${analytics.averageTimeSpent.toStringAsFixed(1)}h',
                  Colors.blue,
                ),
                _buildAnalyticsItem(
                  'Satisfaction',
                  '${(analytics.studentSatisfaction * 100).toStringAsFixed(1)}%',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCoursesTab(TeacherViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes cours (${viewModel.courses.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateCourseDialog(viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau cours'),
              ),
            ],
          ),
        ),
        Expanded(
          child: viewModel.courses.isEmpty
              ? const Center(child: Text('Aucun cours créé'))
              : ListView.builder(
                  itemCount: viewModel.courses.length,
                  itemBuilder: (context, index) {
                    final course = viewModel.courses[index];
                    return _buildCourseCard(course, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(CourseEntity course, TeacherViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(course.status),
          child: Icon(Icons.school, color: Colors.white),
        ),
        title: Text(course.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Statut: ${course.status.name}'),
                const SizedBox(width: 16),
                Text('${course.lessonCount} leçons'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCourseAction(value, course, viewModel),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Voir')),
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
        onTap: () => _viewCourse(course, viewModel),
      ),
    );
  }

  Widget _buildStudentsTab(TeacherViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes étudiants (${viewModel.students.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: viewModel.students.isEmpty
              ? const Center(child: Text('Aucun étudiant'))
              : ListView.builder(
                  itemCount: viewModel.students.length,
                  itemBuilder: (context, index) {
                    final student = viewModel.students[index];
                    return _buildStudentCard(student, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(StudentEntity student, TeacherViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.person, color: Colors.blue[600]),
        ),
        title: Text(student.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.email),
            const SizedBox(height: 4),
            Text('Niveau: ${student.currentLevel}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleStudentAction(value, student, viewModel),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Voir profil')),
            const PopupMenuItem(value: 'progress', child: Text('Progrès')),
            const PopupMenuItem(
              value: 'message',
              child: Text('Envoyer message'),
            ),
          ],
        ),
        onTap: () => _viewStudent(student, viewModel),
      ),
    );
  }

  Widget _buildAssignmentsTab(TeacherViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Devoirs (${viewModel.assignments.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateAssignmentDialog(viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau devoir'),
              ),
            ],
          ),
        ),
        Expanded(
          child: viewModel.assignments.isEmpty
              ? const Center(child: Text('Aucun devoir créé'))
              : ListView.builder(
                  itemCount: viewModel.assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = viewModel.assignments[index];
                    return _buildAssignmentCard(assignment, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(
    AssignmentEntity assignment,
    TeacherViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: assignment.isPublished
              ? Colors.green
              : Colors.orange,
          child: Icon(Icons.assignment, color: Colors.white),
        ),
        title: Text(assignment.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Échéance: ${_formatDate(assignment.dueDate)}'),
                const SizedBox(width: 16),
                Text('${assignment.submissionCount} soumissions'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleAssignmentAction(value, assignment, viewModel),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Voir')),
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(
              value: 'submissions',
              child: Text('Soumissions'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
        onTap: () => _viewAssignment(assignment, viewModel),
      ),
    );
  }

  Widget _buildGradesTab(TeacherViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Notes (${viewModel.grades.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: viewModel.grades.isEmpty
              ? const Center(child: Text('Aucune note'))
              : ListView.builder(
                  itemCount: viewModel.grades.length,
                  itemBuilder: (context, index) {
                    final grade = viewModel.grades[index];
                    return _buildGradeCard(grade, viewModel);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGradeCard(GradeEntity grade, TeacherViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(grade.score),
          child: Text(
            '${grade.score}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(grade.assignmentTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Étudiant: ${grade.studentId}'),
            const SizedBox(height: 4),
            Text('Date: ${_formatDate(grade.gradedAt)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editGrade(grade, viewModel),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(TeacherViewModel viewModel) {
    final analytics = viewModel.analytics;

    if (analytics == null) {
      return const Center(child: Text('Aucune donnée d\'analyse disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Metrics
          _buildPerformanceMetricsCard(analytics),
          const SizedBox(height: 24),

          // Student Progress
          _buildStudentProgressCard(analytics),
          const SizedBox(height: 24),

          // Course Analytics
          _buildCourseAnalyticsCard(analytics),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsCard(TeacherAnalyticsEntity analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques de performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  'Taux de réussite',
                  '${(analytics.completionRate * 100).toStringAsFixed(1)}%',
                  Colors.green,
                ),
                _buildMetricItem(
                  'Temps moyen',
                  '${analytics.averageTimeSpent.toStringAsFixed(1)}h',
                  Colors.blue,
                ),
                _buildMetricItem(
                  'Satisfaction',
                  '${(analytics.studentSatisfaction * 100).toStringAsFixed(1)}%',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudentProgressCard(TeacherAnalyticsEntity analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progrès des étudiants',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem(
                  'Complétés',
                  '${analytics.totalCompletedLessons}',
                  Colors.green,
                ),
                _buildProgressItem(
                  'En cours',
                  '${analytics.totalInProgressLessons}',
                  Colors.blue,
                ),
                _buildProgressItem(
                  'Non commencés',
                  '${analytics.totalNotStartedLessons}',
                  Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCourseAnalyticsCard(TeacherAnalyticsEntity analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyses des cours',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCourseItem(
                  'Cours actifs',
                  '${analytics.totalActiveCourses}',
                  Colors.green,
                ),
                _buildCourseItem(
                  'Cours en attente',
                  '${analytics.totalPendingCourses}',
                  Colors.orange,
                ),
                _buildCourseItem(
                  'Cours archivés',
                  '${analytics.totalArchivedCourses}',
                  Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.draft:
        return Colors.grey;
      case CourseStatus.published:
        return Colors.green;
      case CourseStatus.archived:
        return Colors.red;
      case CourseStatus.suspended:
        return Colors.orange;
    }
  }

  Color _getGradeColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  // Action handlers
  void _handleCourseAction(
    String action,
    CourseEntity course,
    TeacherViewModel viewModel,
  ) {
    switch (action) {
      case 'view':
        _viewCourse(course, viewModel);
        break;
      case 'edit':
        _editCourse(course, viewModel);
        break;
      case 'delete':
        _deleteCourse(course, viewModel);
        break;
    }
  }

  void _handleStudentAction(
    String action,
    StudentEntity student,
    TeacherViewModel viewModel,
  ) {
    switch (action) {
      case 'view':
        _viewStudent(student, viewModel);
        break;
      case 'progress':
        _viewStudentProgress(student, viewModel);
        break;
      case 'message':
        _sendMessageToStudent(student, viewModel);
        break;
    }
  }

  void _handleAssignmentAction(
    String action,
    AssignmentEntity assignment,
    TeacherViewModel viewModel,
  ) {
    switch (action) {
      case 'view':
        _viewAssignment(assignment, viewModel);
        break;
      case 'edit':
        _editAssignment(assignment, viewModel);
        break;
      case 'submissions':
        _viewSubmissions(assignment, viewModel);
        break;
      case 'delete':
        _deleteAssignment(assignment, viewModel);
        break;
    }
  }

  // Navigation and dialog methods
  void _viewCourse(CourseEntity course, TeacherViewModel viewModel) {
    // TODO: Navigate to course details
  }

  void _editCourse(CourseEntity course, TeacherViewModel viewModel) {
    // TODO: Navigate to course edit
  }

  void _deleteCourse(CourseEntity course, TeacherViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le cours'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteCourse(course.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _viewStudent(StudentEntity student, TeacherViewModel viewModel) {
    // TODO: Navigate to student details
  }

  void _viewStudentProgress(StudentEntity student, TeacherViewModel viewModel) {
    // TODO: Navigate to student progress
  }

  void _sendMessageToStudent(
    StudentEntity student,
    TeacherViewModel viewModel,
  ) {
    // TODO: Navigate to message compose
  }

  void _viewAssignment(
    AssignmentEntity assignment,
    TeacherViewModel viewModel,
  ) {
    // TODO: Navigate to assignment details
  }

  void _editAssignment(
    AssignmentEntity assignment,
    TeacherViewModel viewModel,
  ) {
    // TODO: Navigate to assignment edit
  }

  void _viewSubmissions(
    AssignmentEntity assignment,
    TeacherViewModel viewModel,
  ) {
    // TODO: Navigate to submissions list
  }

  void _deleteAssignment(
    AssignmentEntity assignment,
    TeacherViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le devoir'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${assignment.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteAssignment(assignment.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _editGrade(GradeEntity grade, TeacherViewModel viewModel) {
    // TODO: Navigate to grade edit
  }

  void _showCreateCourseDialog(TeacherViewModel viewModel) {
    // TODO: Show create course dialog
  }

  void _showCreateAssignmentDialog(TeacherViewModel viewModel) {
    // TODO: Show create assignment dialog
  }
}
