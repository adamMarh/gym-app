import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_session.dart';
import '../../providers/class_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/client/class_card.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final all = classProvider.classes;
    final booked = classProvider.bookedClasses;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('CLASSES'),
          bottom: TabBar(
            labelStyle: AppTextStyles.labelSmCaps.copyWith(
              color: AppColors.primary,
            ),
            unselectedLabelStyle: AppTextStyles.labelSmCaps,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: 'ALL CLASSES'),
              Tab(text: 'MY BOOKINGS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Classes
            _ClassList(
              classes: all,
              onBook: (id) => classProvider.bookClass(id),
              onCancel: (id) => classProvider.cancelBooking(id),
            ),
            // My Bookings
            booked.isEmpty
                ? _EmptyBookings()
                : _ClassList(
                    classes: booked,
                    onBook: (_) {},
                    onCancel: (id) => classProvider.cancelBooking(id),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  final List<ClassSession> classes;
  final void Function(String) onBook;
  final void Function(String) onCancel;

  const _ClassList({
    required this.classes,
    required this.onBook,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: classes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (ctx, i) {
        final cls = classes[i];
        return ClassCard(
          session: cls,
          onBook: cls.isBooked || cls.isFull ? null : () => onBook(cls.id),
          onCancel: cls.isBooked ? () => onCancel(cls.id) : null,
        );
      },
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('NO BOOKINGS YET', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 8),
          Text(
            'Browse classes and book a session.',
            style: AppTextStyles.bodyMd,
          ),
        ],
      ),
    );
  }
}
