import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_flutter_advanced_nhom_4/models/project.dart';

void main() {
  group('Project Model Tests', () {
    test('Project creation with required fields', () {
      final now = DateTime.now();
      final project = Project(
        id: 'test-id',
        title: 'Test Project',
        description: 'Test Description',
        createdAt: now,
        updatedAt: now,
        ownerId: 'owner-id',
        memberIds: ['owner-id'],
        startDate: now,
      );

      expect(project.id, 'test-id');
      expect(project.title, 'Test Project');
      expect(project.description, 'Test Description');
      expect(project.ownerId, 'owner-id');
      expect(project.memberIds, ['owner-id']);
      expect(project.startDate, now);
    });

    test('Project copyWith creates new instance with updated fields', () {
      final now = DateTime.now();
      final original = Project(
        id: 'test-id',
        title: 'Original Title',
        description: 'Original Description',
        createdAt: now,
        updatedAt: now,
        ownerId: 'owner-id',
        memberIds: ['owner-id'],
        startDate: now,
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Updated Title');
      expect(updated.description, 'Updated Description');
      expect(updated.ownerId, original.ownerId);
      expect(updated.memberIds, original.memberIds);
      expect(updated.startDate, original.startDate);
    });
  });
}
