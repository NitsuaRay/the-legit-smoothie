import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';

class OrderStatusDate extends StatefulWidget {
  final String orderId;
  final String currentStatus;
  final DateTime fallbackDate;

  const OrderStatusDate({
    super.key,
    required this.orderId,
    required this.currentStatus,
    required this.fallbackDate,
  });

  @override
  State<OrderStatusDate> createState() => _OrderStatusDateState();
}

class _OrderStatusDateState extends State<OrderStatusDate> {
  DateTime? _statusDate;

  late Stream<List<Map<String, dynamic>>> _historyStream;

  @override
  void initState() {
    super.initState();

    _createHistoryStream();
    _loadStatusDate();
  }

  void _createHistoryStream() {
    _historyStream = supabase
        .from('order_status_history')
        .stream(primaryKey: ['id'])
        .eq('order_id', widget.orderId)
        .order('created_at', ascending: true);
  }

  @override
  void didUpdateWidget(covariant OrderStatusDate oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If this widget is reused for a different order,
    // rebuild the realtime history stream.
    if (oldWidget.orderId != widget.orderId) {
      _statusDate = null;
      _createHistoryStream();
      _loadStatusDate();
      return;
    }

    // If the current order changes status,
    // fetch the timestamp belonging to that new status.
    if (oldWidget.currentStatus != widget.currentStatus) {
      _statusDate = null;
      _loadStatusDate();
    }
  }

  Future<void> _loadStatusDate() async {
    try {
      final response = await supabase
          .from('order_status_history')
          .select('status, created_at')
          .eq('order_id', widget.orderId)
          .eq(
            'status',
            widget.currentStatus.trim().toLowerCase(),
          )
          .order(
            'created_at',
            ascending: false,
          )
          .limit(1);

      if (!mounted) return;

      if (response.isNotEmpty) {
        final dynamic value = response.first['created_at'];

        if (value == null) return;

        final DateTime parsedDate =
            DateTime.parse(value.toString()).toLocal();

        if (_statusDate != parsedDate) {
          setState(() {
            _statusDate = parsedDate;
          });
        }
      }
    } catch (e) {
      debugPrint(
        'Failed to load status date for '
        '${widget.orderId}: $e',
      );
    }
  }

  void _updateFromRealtime(
    List<Map<String, dynamic>> rows,
  ) {
    Map<String, dynamic>? matchingRow;

    final String currentStatus =
        widget.currentStatus.trim().toLowerCase();

    // Search from newest to oldest.
    for (int i = rows.length - 1; i >= 0; i--) {
      final String historyStatus =
          (rows[i]['status'] ?? '')
              .toString()
              .trim()
              .toLowerCase();

      if (historyStatus == currentStatus) {
        matchingRow = rows[i];
        break;
      }
    }

    if (matchingRow == null) return;

    final dynamic value = matchingRow['created_at'];

    if (value == null) return;

    try {
      final DateTime newDate =
          DateTime.parse(value.toString()).toLocal();

      if (_statusDate != newDate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          setState(() {
            _statusDate = newDate;
          });
        });
      }
    } catch (e) {
      debugPrint(
        'Failed to parse realtime status date: $e',
      );
    }
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    int hour = date.hour;

    final String minute =
        date.minute.toString().padLeft(2, '0');

    final String period =
        hour >= 12 ? 'PM' : 'AM';

    hour %= 12;

    if (hour == 0) {
      hour = 12;
    }

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year} • '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          _updateFromRealtime(snapshot.data!);
        }

        final DateTime displayDate =
            _statusDate ?? widget.fallbackDate;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 11,
              color: AppColors.textSecondary.withValues(
                alpha: 0.55,
              ),
            ),

            const SizedBox(width: 5),

            Flexible(
              child: Text(
                _formatDateTime(displayDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color:
                      AppColors.textSecondary.withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}