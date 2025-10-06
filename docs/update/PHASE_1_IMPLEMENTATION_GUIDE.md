# Phase 1: Core Learning Experience - Implementation Guide

## Progress Status: In Progress ⏳

This document outlines the complete implementation plan for Phase 1 of the Ma'a yegue learner module.

---

## ✅ Completed Work

### 1. Entity Models Created
- ✅ **`user_level_entity.dart`** - Complete user level tracking system
  - 4 levels: Beginner, Intermediate, Advanced, Expert
  - Points system with level-up logic
  - Skill scores tracking
  - Completed lessons tracking
  - Unlocked courses management

- ✅ **`learning_progress_entity.dart`** - Comprehensive progress tracking
  - Total lessons/courses completed
  - Study streaks (current and longest)
  - Skill breakdown (vocabulary, grammar, pronunciation, etc.)
  - Performance metrics (quiz scores, accuracy)
  - Milestones and achievements
  - Study frequency analytics

### 2. Service Layer Started
- ✅ **`level_management_service.dart`** - Level management logic
  - Get/initialize user level
  - Add points with automatic level-up
  - Mark lessons as completed
  - Get recommended lessons based on level
  - Check lesson unlock status (prerequisites)
  - SQLite + Firebase hybrid storage

---

## 🔧 Remaining Implementation Tasks

### Task 1: Database Schema Updates

**File:** `lib/core/database/database_helper.dart`

**Changes Needed:**
1. Update database version from 2 to 3
2. Add user_levels table
3. Add learning_progress table
4. Add lesson_progress table (detailed per-lesson tracking)
5. Add milestones table
6. Add skill_progress table

```sql
-- Add to _onCreate and create migration in _onUpgrade

-- User levels table
CREATE TABLE user_levels (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  language_code TEXT NOT NULL,
  current_level TEXT NOT NULL,
  current_points INTEGER DEFAULT 0,
  points_to_next_level INTEGER NOT NULL,
  completion_percentage REAL DEFAULT 0.0,
  level_achieved_at TEXT NOT NULL,
  last_assessment_date TEXT,
  completed_lessons TEXT, -- Comma-separated IDs
  unlocked_courses TEXT, -- Comma-separated IDs  
  skill_scores TEXT, -- JSON string
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(user_id, language_code)
);

-- Learning progress table
CREATE TABLE learning_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  language_code TEXT NOT NULL,
  total_lessons_completed INTEGER DEFAULT 0,
  total_courses_completed INTEGER DEFAULT 0,
  total_points INTEGER DEFAULT 0,
  total_time_spent_minutes INTEGER DEFAULT 0,
  current_level TEXT NOT NULL,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_study_date TEXT,
  study_dates TEXT, -- JSON array
  recently_completed_lessons TEXT, -- JSON array
  in_progress_lessons TEXT, -- JSON array
  recommended_lessons TEXT, -- JSON array
  unlocked_achievements TEXT, -- JSON array
  average_quiz_score REAL DEFAULT 0.0,
  total_quizzes_taken INTEGER DEFAULT 0,
  total_correct_answers INTEGER DEFAULT 0,
  total_answers INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  last_synced_at TEXT,
  UNIQUE(user_id, language_code)
);

-- Detailed lesson progress table
CREATE TABLE lesson_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  status TEXT NOT NULL, -- 'not_started', 'in_progress', 'completed'
  current_position INTEGER DEFAULT 0,
  total_duration INTEGER DEFAULT 0,
  completed_exercises TEXT, -- JSON array of exercise IDs
  quiz_score INTEGER DEFAULT 0,
  time_spent_seconds INTEGER DEFAULT 0,
  started_at TEXT NOT NULL,
  completed_at TEXT,
  last_accessed_at TEXT NOT NULL,
  attempts INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(user_id, lesson_id)
);

-- Milestones table
CREATE TABLE milestones (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  type TEXT NOT NULL,
  target_value INTEGER NOT NULL,
  current_value INTEGER DEFAULT 0,
  completed_at TEXT,
  reward_description TEXT,
  reward_points INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Skill progress table
CREATE TABLE skill_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  language_code TEXT NOT NULL,
  skill_name TEXT NOT NULL,
  proficiency REAL DEFAULT 0.0,
  lessons_completed INTEGER DEFAULT 0,
  exercises_completed INTEGER DEFAULT 0,
  last_practiced TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE(user_id, language_code, skill_name)
);

-- Create indexes
CREATE INDEX idx_user_levels_user ON user_levels(user_id);
CREATE INDEX idx_learning_progress_user ON learning_progress(user_id);
CREATE INDEX idx_lesson_progress_user ON lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_milestones_user ON milestones(user_id);
CREATE INDEX idx_skill_progress_user ON skill_progress(user_id, language_code);
```

**Priority:** Critical - Required for all other features

---

### Task 2: Complete Progress Tracking Service

**File:** `lib/features/lessons/data/services/progress_tracking_service.dart` (CREATE NEW)

**Purpose:** Track user progress through lessons and courses

```dart
class ProgressTrackingService {
  // Methods to implement:
  
  /// Start a lesson
  Future<void> startLesson(String userId, String lessonId, String courseId);
  
  /// Update lesson progress (e.g., video position)
  Future<void> updateLessonProgress(String userId, String lessonId, int position);
  
  /// Mark exercise as completed
  Future<void> completeExercise(String userId, String lessonId, String exerciseId);
  
  /// Complete a lesson
  Future<void> completeLesson(String userId, String lessonId, int score);
  
  /// Get user's progress for a lesson
  Future<Progress?> getLessonProgress(String userId, String lessonId);
  
  /// Get all in-progress lessons
  Future<List<Progress>> getInProgressLessons(String userId);
  
  /// Update study streak
  Future<void> updateStudyStreak(String userId, String languageCode);
  
  /// Get comprehensive learning progress
  Future<LearningProgressEntity> getLearningProgress(String userId, String languageCode);
  
  /// Update skill proficiency
  Future<void> updateSkillProgress(
    String userId,
    String languageCode,
    String skillName,
    double improvement,
  );
}
```

**Priority:** Critical

---

### Task 3: Implement Assessment/Quiz System

**Files to Create:**
1. `lib/features/assessment/data/services/quiz_service.dart`
2. `lib/features/assessment/presentation/views/quiz_view.dart`
3. `lib/features/assessment/presentation/widgets/question_widget.dart`
4. `lib/features/assessment/presentation/viewmodels/quiz_viewmodel.dart`

**Features:**
- Multiple choice questions
- Fill-in-the-blank
- Audio pronunciation assessment
- Translation exercises
- Immediate feedback
- Score calculation
- Retry mechanism
- Progress saving

**Priority:** High

---

### Task 4: Level Assessment Quiz

**File:** `lib/features/assessment/presentation/views/level_assessment_view.dart`

**Purpose:** Determine user's initial level for a language

**Features:**
- 20-30 questions covering all levels
- Adaptive difficulty (gets harder/easier based on answers)
- Comprehensive scoring
- Skill breakdown (vocabulary, grammar, etc.)
- Recommended level assignment
- Save results to user profile

**Flow:**
1. User selects language to learn
2. System prompts for level assessment
3. User answers questions (15-20 min)
4. System calculates scores
5. System assigns level (Beginner, Intermediate, Advanced, Expert)
6. System unlocks appropriate courses
7. Redirect to dashboard with recommended lessons

**Priority:** High

---

### Task 5: Learner Dashboard

**File:** `lib/features/dashboard/presentation/views/learner_dashboard_view.dart`

**Components to Build:**

1. **Header Section:**
   - Welcome message with name
   - Current level badge
   - Progress to next level (circular progress indicator)

2. **Stats Cards:**
   - Lessons completed today/this week
   - Current streak (with fire icon)
   - Total points
   - Study time this week

3. **Current Learning Path:**
   - Continue where you left off
   - Next recommended lesson
   - Progress bar for current course

4. **Skills Overview:**
   - Radar chart or progress bars for each skill
   - Vocabulary, Grammar, Pronunciation, Listening, Speaking, Reading, Writing

5. **Recent Activity:**
   - Last 5 completed lessons
   - Recent achievements unlocked

6. **Recommended Lessons:**
   - Based on current level
   - Based on weak skills
   - Popular in your level

7. **Achievements & Milestones:**
   - Recent unlocks
   - Progress toward next milestone

**Priority:** Critical

---

### Task 6: Lesson Player/Viewer

**File:** `lib/features/lessons/presentation/views/lesson_player_view.dart`

**Features:**

1. **Content Display:**
   - Video player (with controls, subtitles)
   - Audio player
   - Text content (with formatting)
   - Images/diagrams

2. **Interactive Elements:**
   - Inline exercises
   - Vocabulary highlights (tap to see definition)
   - Pronunciation practice (record and compare)
   - Note-taking area

3. **Navigation:**
   - Previous/Next lesson buttons
   - Progress indicator
   - Table of contents/chapter navigation

4. **Progress Tracking:**
   - Auto-save progress
   - Mark as complete button
   - Time tracking
   - Resume from last position

5. **Offline Support:**
   - Download lesson content
   - Cache video/audio
   - Offline progress tracking (sync later)

**Priority:** Critical

---

### Task 7: Adaptive Content Recommendation Engine

**File:** `lib/features/lessons/data/services/recommendation_service.dart`

**Algorithm:**
```dart
class RecommendationService {
  /// Get personalized lesson recommendations
  Future<List<LessonEntity>> getRecommendations(
    String userId,
    String languageCode, {
    int limit = 10,
  }) async {
    // 1. Get user's level and progress
    // 2. Get weak skills (proficiency < 60%)
    // 3. Find lessons that:
    //    - Match user's level
    //    - Target weak skills
    //    - Are unlocked (prerequisites met)
    //    - Are not completed
    // 4. Sort by:
    //    - Prerequisite chain (basics first)
    //    - Skill importance
    //    - User preferences
    // 5. Return top N lessons
  }
  
  /// Get next lesson in sequence
  Future<LessonEntity?> getNextLesson(
    String userId,
    String currentLessonId,
  );
  
  /// Check if user should be recommended to take assessment
  Future<bool> shouldTakeAssessment(String userId, String languageCode);
}
```

**Priority:** Medium

---

### Task 8: Points & Rewards System

**Points Distribution:**
```dart
class PointsSystem {
  static const Map<String, int> activityPoints = {
    'lesson_completed': 100,
    'quiz_passed': 50,
    'quiz_perfect_score': 100, // 100% accuracy
    'exercise_completed': 20,
    'daily_login': 10,
    'streak_milestone_7': 200, // 7 days streak
    'streak_milestone_30': 1000, // 30 days streak
    'course_completed': 500,
    'level_up': 1000,
    'achievement_unlocked': 150,
    'helping_others': 25, // Future: community feature
  };
  
  /// Award points for activity
  static Future<void> awardPoints(
    String userId,
    String activity,
    {Map<String, dynamic>? metadata}
  );
}
```

**Priority:** Medium

---

### Task 9: Testing & Validation

**Test Cases to Write:**

1. **Unit Tests:**
   - Level up logic
   - Points calculation
   - Streak calculation
   - Recommendation algorithm
   - Progress percentage calculation

2. **Integration Tests:**
   - Complete user journey (register → assess → learn → level up)
   - Offline mode (learn without internet, sync later)
   - Concurrent learning (multiple languages)

3. **Widget Tests:**
   - Dashboard rendering
   - Quiz UI
   - Lesson player controls
   - Progress indicators

**Priority:** High

---

## 📊 Implementation Order (Recommended)

### Week 1: Foundation
1. ✅ Create entity models (DONE)
2. ✅ Create level management service (DONE)
3. Update database schema
4. Create progress tracking service
5. Write unit tests for services

### Week 2: Core Features
1. Build learner dashboard
2. Implement level assessment quiz
3. Create quiz system for lessons
4. Build lesson player/viewer
5. Implement progress tracking in UI

### Week 3: Polish & Integration
1. Build recommendation engine
2. Implement points & rewards
3. Add offline support
4. Write integration tests
5. Bug fixes and optimization

---

## 🎯 Success Criteria

Phase 1 is complete when:

- ✅ User can take level assessment and get assigned appropriate level
- ✅ User can view personalized dashboard with progress stats
- ✅ User can start and complete lessons with progress tracking
- ✅ User can take quizzes and see immediate feedback
- ✅ User earns points and can level up
- ✅ System recommends appropriate next lessons
- ✅ Daily streaks are tracked and rewarded
- ✅ Skills proficiency is tracked and displayed
- ✅ All works offline with proper sync
- ✅ Zero critical bugs
- ✅ Test coverage > 70%

---

## 🚀 Next Steps for Developer

1. **Complete database migration** (Task 1)
   - Add new tables
   - Create migration script
   - Test on clean database

2. **Build progress tracking service** (Task 2)
   - Implement all methods
   - Add error handling
   - Write unit tests

3. **Create learner dashboard** (Task 5)
   - Design UI components
   - Integrate with services
   - Add loading states

4. **Implement quiz system** (Task 3)
   - Build question widgets
   - Add answer validation
   - Implement scoring

5. **Test complete flow**
   - Register new user
   - Take assessment
   - Complete first lesson
   - Verify progress tracking

---

## 📚 Resources

- Flutter Video Player: https://pub.dev/packages/video_player
- Flutter Audio Players: https://pub.dev/packages/audioplayers  
- Chart Library: https://pub.dev/packages/fl_chart
- Offline-first: https://pub.dev/packages/drift
- Testing: https://docs.flutter.dev/testing

---

**Last Updated:** October 6, 2025  
**Status:** Foundation laid, ready for implementation  
**Estimated Completion:** 2-3 weeks with full-time development

