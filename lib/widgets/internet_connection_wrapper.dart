import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';


class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;

  const InternetConnectionWrapper({
    super.key,
    required this.child,
  });

  @override
  State<InternetConnectionWrapper> createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState
    extends State<InternetConnectionWrapper> {
  StreamSubscription<InternetStatus>? _subscription;

  bool _hasInternet = true;
  bool _checking = true;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();

    _subscription =
        InternetConnection().onStatusChange.listen((status) {
      if (!mounted) return;

      setState(() {
        _hasInternet = status == InternetStatus.connected;
        _checking = false;
      });
    });
  }

  Future<void> _checkInitialConnection() async {
    final bool connected =
        await InternetConnection().hasInternetAccess;

    if (!mounted) return;

    setState(() {
      _hasInternet = connected;
      _checking = false;
    });
  }

  Future<void> _retry() async {
    setState(() {
      _checking = true;
    });

    final bool connected =
        await InternetConnection().hasInternetAccess;

    if (!mounted) return;

    setState(() {
      _hasInternet = connected;
      _checking = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (!_hasInternet)
          Positioned.fill(
            child: _NoInternetOverlay(
              checking: _checking,
              onRetry: _retry,
            ),
          ),
      ],
    );
  }
}

class _NoInternetOverlay extends StatelessWidget {
  final bool checking;
  final VoidCallback onRetry;

  const _NoInternetOverlay({
    required this.checking,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.border.withValues(
                    alpha: 0.30,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.10,
                    ),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==============================================
                  // ICON
                  // ==============================================

                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 28,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================================
                  // LABEL
                  // ==============================================

                  Text(
                    'CONNECTION LOST',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.62,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'You’re offline',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'The Legit Smoothie needs an internet connection '
                    'to load products, promotions, orders and your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================================
                  // INFORMATION
                  // ==============================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: AppColors.border.withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Text(
                            'Check your Wi-Fi or mobile data, '
                            'then try connecting again.',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.72),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==============================================
                  // RETRY
                  // ==============================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: checking ? null : onRetry,
                      style: FilledButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.textPrimary.withValues(
                          alpha: 0.55,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      child: checking
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 17,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Try again',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  Text(
                    'We’ll also reconnect automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}