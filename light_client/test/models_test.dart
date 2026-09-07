import 'package:flutter_test/flutter_test.dart';
import 'package:gym_gym_app/models/user.dart';
import 'package:gym_gym_app/models/workout.dart';
import 'package:gym_gym_app/models/class_session.dart';
import 'package:gym_gym_app/models/post.dart';
import 'package:gym_gym_app/models/staff_report.dart';

void main() {
  group('User model', () {
    test('isAdmin returns true only for admin role', () {
      final admin = User.mockUsers.firstWhere((u) => u.role == UserRole.admin);
      final client = User.mockUsers.firstWhere((u) => u.role == UserRole.client);
      expect(admin.isAdmin, isTrue);
      expect(client.isAdmin, isFalse);
    });

    test('isStaff returns true for staff and admin', () {
      final admin = User.mockUsers.firstWhere((u) => u.role == UserRole.admin);
      final staff = User.mockUsers.firstWhere((u) => u.role == UserRole.staff);
      final client = User.mockUsers.firstWhere((u) => u.role == UserRole.client);
      expect(admin.isStaff, isTrue);
      expect(staff.isStaff, isTrue);
      expect(client.isStaff, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final user = User.mockUsers.first;
      final updated = user.copyWith(name: 'New Name');
      expect(updated.name, equals('New Name'));
      expect(updated.email, equals(user.email));
      expect(updated.role, equals(user.role));
    });
  });

  group('WorkoutSession model', () {
    test('totalVolume calculates correctly', () {
      const exercise = Exercise(name: 'Squat', sets: 4, reps: 5, weightKg: 100);
      expect(exercise.volume, equals(4 * 5 * 100));
    });

    test('totalSets sums all exercises', () {
      final session = WorkoutSession.mockSessions.first;
      final expected = session.exercises.fold(0, (sum, e) => sum + e.sets);
      expect(session.totalSets, equals(expected));
    });
  });

  group('ClassSession model', () {
    test('spotsLeft = capacity - enrolled', () {
      final cls = ClassSession.mockClasses.first;
      expect(cls.spotsLeft, equals(cls.capacity - cls.enrolled));
    });

    test('isFull when enrolled >= capacity', () {
      final fullClass =
          ClassSession.mockClasses.firstWhere((c) => c.enrolled == c.capacity);
      expect(fullClass.isFull, isTrue);
    });

    test('copyWith updates isBooked and enrolled', () {
      final cls = ClassSession.mockClasses.first;
      final booked = cls.copyWith(isBooked: true, enrolled: cls.enrolled + 1);
      expect(booked.isBooked, isTrue);
      expect(booked.enrolled, equals(cls.enrolled + 1));
    });
  });

  group('Post model', () {
    test('mock posts include a pinned post', () {
      final pinned = Post.mockPosts.where((p) => p.isPinned).toList();
      expect(pinned, isNotEmpty);
    });

    test('likes count is non-negative', () {
      for (final post in Post.mockPosts) {
        expect(post.likes, greaterThanOrEqualTo(0));
      }
    });
  });

  group('StaffReport model', () {
    test('copyWith marks as reviewed', () {
      final report = StaffReport.mockReports.first;
      final reviewed =
          report.copyWith(isReviewed: true, adminNotes: 'Good work');
      expect(reviewed.isReviewed, isTrue);
      expect(reviewed.adminNotes, equals('Good work'));
    });

    test('PunchRecord duration is null when not punched out', () {
      final punch =
          PunchRecord(staffId: 'u2', punchIn: DateTime.now());
      expect(punch.duration, isNull);
      expect(punch.isActive, isTrue);
    });
  });
}
