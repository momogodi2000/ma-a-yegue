/// Academic calendar and term management service
/// Addresses CRITICAL_ANALYSIS requirement for academic year structure

import '../models/educational_models.dart';

/// Academic calendar manager
class AcademicCalendarService {
  /// Generate standard Cameroon academic terms
  static List<AcademicTerm> generateCameroonTerms(String academicYear) {
    final startYear = int.parse(academicYear.split('-')[0]);

    return [
      AcademicTerm(
        id: '${academicYear}_term1',
        name: '1er Trimestre',
        termNumber: 1,
        academicYear: academicYear,
        startDate: DateTime(startYear, 9, 1), // September 1
        endDate: DateTime(startYear, 12, 15), // December 15
        isActive: _isCurrentTerm(
          DateTime(startYear, 9, 1),
          DateTime(startYear, 12, 15),
        ),
      ),
      AcademicTerm(
        id: '${academicYear}_term2',
        name: '2ème Trimestre',
        termNumber: 2,
        academicYear: academicYear,
        startDate: DateTime(startYear + 1, 1, 5), // January 5
        endDate: DateTime(startYear + 1, 4, 5), // April 5
        isActive: _isCurrentTerm(
          DateTime(startYear + 1, 1, 5),
          DateTime(startYear + 1, 4, 5),
        ),
      ),
      AcademicTerm(
        id: '${academicYear}_term3',
        name: '3ème Trimestre',
        termNumber: 3,
        academicYear: academicYear,
        startDate: DateTime(startYear + 1, 4, 15), // April 15
        endDate: DateTime(startYear + 1, 7, 10), // July 10
        isActive: _isCurrentTerm(
          DateTime(startYear + 1, 4, 15),
          DateTime(startYear + 1, 7, 10),
        ),
      ),
    ];
  }

  static bool _isCurrentTerm(DateTime start, DateTime end) {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Get current academic year
  static String getCurrentAcademicYear() {
    final now = DateTime.now();
    if (now.month >= 9) {
      return '${now.year}-${now.year + 1}';
    } else {
      return '${now.year - 1}-${now.year}';
    }
  }

  /// Get current term
  static AcademicTerm? getCurrentTerm() {
    final academicYear = getCurrentAcademicYear();
    final terms = generateCameroonTerms(academicYear);
    return terms.firstWhere((term) => term.isActive, orElse: () => terms.first);
  }

  /// Get all holidays for Cameroon academic year
  static List<AcademicHoliday> getCameroonHolidays(String academicYear) {
    final startYear = int.parse(academicYear.split('-')[0]);

    return [
      // National holidays
      AcademicHoliday(
        name: 'Nouvel An',
        startDate: DateTime(startYear + 1, 1, 1),
        endDate: DateTime(startYear + 1, 1, 1),
        type: HolidayType.national,
      ),
      AcademicHoliday(
        name: 'Fête de la Jeunesse',
        startDate: DateTime(startYear + 1, 2, 11),
        endDate: DateTime(startYear + 1, 2, 11),
        type: HolidayType.national,
      ),
      AcademicHoliday(
        name: 'Fête du Travail',
        startDate: DateTime(startYear + 1, 5, 1),
        endDate: DateTime(startYear + 1, 5, 1),
        type: HolidayType.national,
      ),
      AcademicHoliday(
        name: 'Fête Nationale',
        startDate: DateTime(startYear + 1, 5, 20),
        endDate: DateTime(startYear + 1, 5, 20),
        type: HolidayType.national,
      ),

      // School breaks
      AcademicHoliday(
        name: 'Vacances de Noël',
        startDate: DateTime(startYear, 12, 16),
        endDate: DateTime(startYear + 1, 1, 4),
        type: HolidayType.schoolBreak,
      ),
      AcademicHoliday(
        name: 'Vacances de Pâques',
        startDate: DateTime(startYear + 1, 4, 6),
        endDate: DateTime(startYear + 1, 4, 14),
        type: HolidayType.schoolBreak,
      ),
      AcademicHoliday(
        name: 'Grandes Vacances',
        startDate: DateTime(startYear + 1, 7, 11),
        endDate: DateTime(startYear + 1, 8, 31),
        type: HolidayType.summerBreak,
      ),
    ];
  }

  /// Check if date is a school day
  static bool isSchoolDay(DateTime date) {
    // Weekend check
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }

    // Holiday check
    final academicYear = getCurrentAcademicYear();
    final holidays = getCameroonHolidays(academicYear);

    for (final holiday in holidays) {
      if (date.isAfter(holiday.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(holiday.endDate.add(const Duration(days: 1)))) {
        return false;
      }
    }

    return true;
  }

  /// Get number of school days in a term
  static int getSchoolDaysInTerm(AcademicTerm term) {
    int count = 0;
    DateTime current = term.startDate;

    while (current.isBefore(term.endDate) ||
        current.isAtSameMomentAs(term.endDate)) {
      if (isSchoolDay(current)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  /// Get academic events/milestones
  static List<AcademicEvent> getAcademicEvents(String academicYear) {
    final startYear = int.parse(academicYear.split('-')[0]);

    return [
      AcademicEvent(
        name: 'Rentrée Scolaire',
        date: DateTime(startYear, 9, 1),
        type: EventType.schoolStart,
        description: 'Début de l\'année scolaire $academicYear',
      ),
      AcademicEvent(
        name: 'Conseil de Classe 1er Trimestre',
        date: DateTime(startYear, 12, 10),
        type: EventType.facultyMeeting,
        description: 'Conseils de classe du premier trimestre',
      ),
      AcademicEvent(
        name: 'Remise des Bulletins T1',
        date: DateTime(startYear, 12, 15),
        type: EventType.reportCards,
        description: 'Distribution des bulletins du 1er trimestre',
      ),
      AcademicEvent(
        name: 'Conseil de Classe 2ème Trimestre',
        date: DateTime(startYear + 1, 4, 1),
        type: EventType.facultyMeeting,
        description: 'Conseils de classe du deuxième trimestre',
      ),
      AcademicEvent(
        name: 'Remise des Bulletins T2',
        date: DateTime(startYear + 1, 4, 5),
        type: EventType.reportCards,
        description: 'Distribution des bulletins du 2ème trimestre',
      ),
      AcademicEvent(
        name: 'Examens Finaux',
        date: DateTime(startYear + 1, 6, 15),
        type: EventType.exams,
        description: 'Début des examens de fin d\'année',
      ),
      AcademicEvent(
        name: 'Conseil de Classe 3ème Trimestre',
        date: DateTime(startYear + 1, 7, 5),
        type: EventType.facultyMeeting,
        description: 'Conseils de classe finaux',
      ),
      AcademicEvent(
        name: 'Remise des Bulletins Annuels',
        date: DateTime(startYear + 1, 7, 10),
        type: EventType.reportCards,
        description: 'Distribution des bulletins annuels',
      ),
    ];
  }

  /// Calculate academic progress percentage
  static double getTermProgress(AcademicTerm term) {
    final now = DateTime.now();
    if (now.isBefore(term.startDate)) return 0.0;
    if (now.isAfter(term.endDate)) return 100.0;

    final totalDays = term.endDate.difference(term.startDate).inDays;
    final elapsedDays = now.difference(term.startDate).inDays;

    return (elapsedDays / totalDays * 100).clamp(0.0, 100.0);
  }

  /// Get next important date
  static AcademicEvent? getNextEvent() {
    final academicYear = getCurrentAcademicYear();
    final events = getAcademicEvents(academicYear);
    final now = DateTime.now();

    final futureEvents = events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return futureEvents.isNotEmpty ? futureEvents.first : null;
  }
}

/// Academic holiday
class AcademicHoliday {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final HolidayType type;

  const AcademicHoliday({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toJson() => {
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'type': type.name,
  };
}

enum HolidayType {
  national('Jour Férié'),
  schoolBreak('Vacances Scolaires'),
  summerBreak('Grandes Vacances');

  const HolidayType(this.displayName);
  final String displayName;
}

/// Academic event/milestone
class AcademicEvent {
  final String name;
  final DateTime date;
  final EventType type;
  final String description;

  const AcademicEvent({
    required this.name,
    required this.date,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'type': type.name,
    'description': description,
  };
}

enum EventType {
  schoolStart('Rentrée'),
  schoolEnd('Fin d\'Année'),
  exams('Examens'),
  reportCards('Bulletins'),
  facultyMeeting('Conseil de Classe'),
  parentMeeting('Réunion Parents'),
  other('Autre');

  const EventType(this.displayName);
  final String displayName;
}
