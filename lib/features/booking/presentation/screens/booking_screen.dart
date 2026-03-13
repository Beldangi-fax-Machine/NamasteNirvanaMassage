import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/router_config.dart';
import '../../../../shared/models/service_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ServiceModel? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _availableTimes = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
  ];

  bool get _canBook =>
      _selectedService != null &&
      _selectedDate != null &&
      _selectedTime != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Selection
            _buildSectionTitle(context, 'Select Service'),
            const SizedBox(height: 12),
            _buildServiceSelector(),
            const SizedBox(height: 32),

            // Date Selection
            _buildSectionTitle(context, 'Select Date'),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 32),

            // Time Selection
            _buildSectionTitle(context, 'Select Time'),
            const SizedBox(height: 12),
            _buildTimeSelector(),
            const SizedBox(height: 32),

            // Summary
            if (_canBook) ...[
              _buildSummary(),
              const SizedBox(height: 100),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _canBook
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => context.push('/booking/confirmation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                      'Confirm Booking - ${_selectedService!.formattedPrice}'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildServiceSelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ServiceModel.sampleServices.length,
        itemBuilder: (context, index) {
          final service = ServiceModel.sampleServices[index];
          final isSelected = _selectedService?.id == service.id;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedService = service);
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.spa,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.accent),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.formattedPrice} • ${service.formattedDuration}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i + 1)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate?.day == date.day &&
              _selectedDate?.month == date.month;
          final isWeekend = date.weekday == 6 || date.weekday == 7;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
            },
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white70
                              : isWeekend
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM').format(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isSelected ? Colors.white70 : AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableTimes.map((time) {
        final isSelected = _selectedTime == time;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedTime = time);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Service', _selectedService!.name),
          _buildSummaryRow('Duration', _selectedService!.formattedDuration),
          _buildSummaryRow(
            'Date',
            DateFormat('EEEE, MMMM d').format(_selectedDate!),
          ),
          _buildSummaryRow('Time', _selectedTime!),
          const Divider(height: 32),
          _buildSummaryRow(
            'Total',
            _selectedService!.formattedPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
          ),
        ],
      ),
    );
  }
}
