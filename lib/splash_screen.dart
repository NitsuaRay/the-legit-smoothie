import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:the_legit_smoothie/core/services/push_notification_service.dart';
import 'package:the_legit_smoothie/features/orders/screens/order_tracking_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_order_detail_screen.dart';
import 'package:the_legit_smoothie/widgets/app_update_dialog.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/models/app_update_info.dart';
import 'core/services/app_update_service.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/services/auth_service.dart';

import 'widgets/main_navigation_screen.dart';
import 'widgets/seller_main_navigation_screen.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  final AppUpdateService _appUpdateService = AppUpdateService();

  // ============================================================
  // STARTUP / UPDATE STATE
  // ============================================================

  bool _startupHandled = false;

  bool _updateDialogVisible = false;

  bool _isDownloadingUpdate = false;

  double? _downloadProgress;

  // ============================================================
  // ANIMATION CONTROLLERS
  // ============================================================

  late final AnimationController _introController;

  late final AnimationController _pulseController;

  // ============================================================
  // ANIMATIONS
  // ============================================================

  late final Animation<double> _logoFade;

  late final Animation<double> _logoScale;

  late final Animation<Offset> _logoSlide;

  late final Animation<double> _textFade;

  late final Animation<Offset> _textSlide;

  late final Animation<double> _loaderFade;

  late final Animation<double> _pulseAnimation;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // MAIN INTRO ANIMATION
    // ==========================================================

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _textFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.35, 0.90, curve: Curves.easeOutCubic),
          ),
        );

    _loaderFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    // ==========================================================
    // SUBTLE LOGO PULSE
    // ==========================================================

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.025).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ==========================================================
    // START ANIMATIONS
    // ==========================================================

    _introController.forward();

    _pulseController.repeat(reverse: true);

    // ==========================================================
    // START APP INITIALIZATION
    // ==========================================================

    _handleStartup();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _introController.dispose();

    _pulseController.dispose();

    super.dispose();
  }

  // ============================================================
  // STARTUP FLOW
  // ============================================================

  Future<void> _handleStartup() async {
    // Prevent startup from accidentally running twice.
    if (_startupHandled) {
      return;
    }

    _startupHandled = true;

    // Give the splash animation enough time to play.
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    // ==========================================================
    // CHECK FOR APP UPDATE
    // ==========================================================

    try {
      final AppUpdateInfo? updateInfo = await _appUpdateService
          .checkForUpdate();

      if (!mounted) return;

      // ========================================================
      // UPDATE AVAILABLE
      // ========================================================

      if (updateInfo != null && updateInfo.hasUpdate) {
        await _showUpdateDialog(updateInfo);

        return;
      }
    } catch (error) {
      // An update-check failure should NOT prevent
      // the user from entering the application.
      debugPrint('Splash update check failed: $error');
    }

    if (!mounted) return;

    // ==========================================================
    // NO UPDATE → CONTINUE AUTH
    // ==========================================================

    await _checkAuth();
  }

  // ============================================================
  // UPDATE DIALOG
  // ============================================================

  Future<void> _showUpdateDialog(AppUpdateInfo updateInfo) async {
    if (!mounted || _updateDialogVisible) {
      return;
    }

    _updateDialogVisible = true;

    await showDialog<void>(
      context: context,

      // Required update cannot be dismissed
      // by tapping outside the dialog.
      barrierDismissible: !updateInfo.isRequired,

      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppUpdateDialog(
              updateInfo: updateInfo,

              isUpdating: _isDownloadingUpdate,

              downloadProgress: _downloadProgress,

              // ================================================
              // UPDATE NOW
              // ================================================
              onUpdate: () {
                if (_isDownloadingUpdate) {
                  return;
                }

                _startUpdateDownload(updateInfo, setDialogState);
              },

              // ================================================
              // MAYBE LATER
              // ================================================
              onLater: updateInfo.isRequired
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
            );
          },
        );
      },
    );

    _updateDialogVisible = false;

    if (!mounted) return;

    // ==========================================================
    // REQUIRED UPDATE
    // ==========================================================

    // Never continue into the application if
    // the installed build is below the required build.
    if (updateInfo.isRequired) {
      return;
    }

    // ==========================================================
    // OPTIONAL UPDATE
    // ==========================================================

    // User selected "Maybe Later" or otherwise
    // dismissed an optional update.
    await _checkAuth();
  }

  // ============================================================
  // OTA DOWNLOAD / INSTALL
  // ============================================================

  void _startUpdateDownload(
    AppUpdateInfo updateInfo,
    StateSetter setDialogState,
  ) {
    if (_isDownloadingUpdate) {
      return;
    }

    setDialogState(() {
      _isDownloadingUpdate = true;

      _downloadProgress = null;
    });

    try {
      _appUpdateService
          .installUpdate(updateInfo)
          .listen(
            (OtaEvent event) {
              if (!mounted) {
                return;
              }

              switch (event.status) {
                // ==============================================
                // DOWNLOADING
                // ==============================================

                case OtaStatus.DOWNLOADING:
                  final double? percentage = double.tryParse(event.value ?? '');

                  setDialogState(() {
                    if (percentage == null) {
                      _downloadProgress = null;
                    } else {
                      _downloadProgress = (percentage / 100).clamp(0.0, 1.0);
                    }
                  });

                  break;

                // ==============================================
                // INSTALLING
                // ==============================================

                case OtaStatus.INSTALLING:
                  setDialogState(() {
                    _downloadProgress = 1.0;
                  });

                  break;

                // ==============================================
                // ERRORS
                // ==============================================

                case OtaStatus.ALREADY_RUNNING_ERROR:
                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                case OtaStatus.INTERNAL_ERROR:
                case OtaStatus.DOWNLOAD_ERROR:
                case OtaStatus.CHECKSUM_ERROR:
                  setDialogState(() {
                    _isDownloadingUpdate = false;

                    _downloadProgress = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_otaErrorMessage(event.status))),
                  );

                  break;

                default:
                  break;
              }
            },

            // ================================================
            // STREAM ERROR
            // ================================================
            onError: (Object error) {
              if (!mounted) return;

              setDialogState(() {
                _isDownloadingUpdate = false;

                _downloadProgress = null;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Unable to download '
                    'the update. '
                    'Please try again.',
                  ),
                ),
              );
            },
          );
    } catch (error) {
      if (!mounted) return;

      setDialogState(() {
        _isDownloadingUpdate = false;

        _downloadProgress = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to start the update. '
            'Please try again.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // OTA ERROR MESSAGE
  // ============================================================

  String _otaErrorMessage(OtaStatus status) {
    switch (status) {
      case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
        return 'Installation permission '
            'is required to update the app.';

      case OtaStatus.DOWNLOAD_ERROR:
        return 'The update could not be '
            'downloaded. Please check your '
            'internet connection.';

      case OtaStatus.CHECKSUM_ERROR:
        return 'The downloaded update '
            'could not be verified. '
            'Please try again.';

      case OtaStatus.ALREADY_RUNNING_ERROR:
        return 'An update is already '
            'being downloaded.';

      default:
        return 'The update could not be '
            'installed. Please try again.';
    }
  }

  // ============================================================
  // AUTHENTICATION + ROLE ROUTING
  // ============================================================

  Future<void> _checkAuth() async {
    try {
      final session = supabase.auth.currentSession;

      if (!mounted) return;

      // ========================================================
      // NOT LOGGED IN
      // ========================================================

      if (session == null) {
        _goToLogin();

        return;
      }

      // ========================================================
      // INITIALIZE PUSH NOTIFICATIONS
      // ========================================================

      await PushNotificationService.instance.initialize();

      if (!mounted) return;

      // ========================================================
      // GET ROLE
      // ========================================================

      final String? role = await _authService.getCurrentUserRole();

      if (!mounted) return;

      // ========================================================
      // GET PENDING PUSH ORDER
      // ========================================================

      final PushNotificationService pushService =
          PushNotificationService.instance;

      final String? pendingOrderId = pushService.pendingOrderId;

      // ========================================================
      // SELLER
      // ========================================================

      if (role == 'seller') {
        if (pendingOrderId != null && pendingOrderId.isNotEmpty) {
          pushService.clearPendingNotification();

          _replaceScreenWithOrder(
            mainScreen: const SellerMainNavigationScreen(initialIndex: 2),
            orderScreen: SellerOrderDetailScreen(orderId: pendingOrderId),
          );

          return;
        }

        _replaceScreen(const SellerMainNavigationScreen());

        return;
      }

      // ========================================================
      // CUSTOMER
      // ========================================================

      if (role == 'customer') {
        if (pendingOrderId != null && pendingOrderId.isNotEmpty) {
          pushService.clearPendingNotification();

          _replaceScreenWithOrder(
            mainScreen: const MainNavigationScreen(initialIndex: 3),
            orderScreen: OrderTrackingScreen(orderId: pendingOrderId),
          );

          return;
        }

        _replaceScreen(const MainNavigationScreen());

        return;
      }

      // ========================================================
      // INVALID ROLE
      // ========================================================

      await _authService.signOut();

      if (!mounted) return;

      _goToLogin();
    } catch (error) {
      if (!mounted) return;

      _goToLogin();
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _replaceScreen(Widget screen) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return screen;
        },
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  void _replaceScreenWithOrder({
    required Widget mainScreen,
    required Widget orderScreen,
  }) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return mainScreen;
        },
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );

    // Wait until the main navigation screen
    // has been mounted before opening the order.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? navigatorContext = navigatorKey.currentContext;

      if (navigatorContext == null) {

        return;
      }

      Navigator.of(
        navigatorContext,
      ).push(MaterialPageRoute(builder: (_) => orderScreen));
    });
  }

  void _goToLogin() {
    _replaceScreen(const LoginScreen());
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ====================================================
          // BACKGROUND IMAGE
          // ====================================================
          Positioned.fill(
            child: Image.asset(
              'assets/bgWhite.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.background);
              },
            ),
          ),

          // ====================================================
          // LIGHT OVERLAY
          // ====================================================
          Positioned.fill(
            child: Container(
              color: AppColors.background.withValues(alpha: 0.58),
            ),
          ),

          // ====================================================
          // MAIN CONTENT
          // ====================================================
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: double.infinity,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      const Spacer(),

                      // ========================================
                      // MAIN BRANDING GROUP
                      // ========================================
                      Transform.translate(
                        offset: const Offset(0, -25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ================================
                            // LOGO
                            // ================================
                            FadeTransition(
                              opacity: _logoFade,
                              child: SlideTransition(
                                position: _logoSlide,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: ScaleTransition(
                                    scale: _pulseAnimation,
                                    child: _buildLogo(),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ================================
                            // TITLE + TAGLINE
                            // ================================
                            FadeTransition(
                              opacity: _textFade,
                              child: SlideTransition(
                                position: _textSlide,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        AppConstants.appName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 30,
                                          height: 1.05,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.8,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),

                                      const SizedBox(height: 13),

                                      // Small brand accent.
                                      Container(
                                        width: 34,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      Text(
                                        AppConstants.appTagline,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.1,
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ================================
                            // LOADING
                            // ================================
                            const SizedBox(height: 44),

                            FadeTransition(
                              opacity: _loaderFade,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const _PremiumLoader(),

                                  const SizedBox(height: 12),

                                  Text(
                                    'Preparing your experience',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ========================================
                      // FOOTER
                      // ========================================
                      FadeTransition(
                        opacity: _loaderFade,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'FRESH  •  SMOOTH  •  MADE FOR YOU',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.32,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREMIUM LOGO
  // ============================================================

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ======================================================
        // OUTER GLOW
        // ======================================================
        Container(
          width: 174,
          height: 174,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.10),
                AppColors.primary.withValues(alpha: 0.025),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // ======================================================
        // OUTER BORDER
        // ======================================================
        Container(
          width: 146,
          height: 146,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
        ),

        // ======================================================
        // MAIN LOGO CARD
        // ======================================================
        Container(
          width: 130,
          height: 130,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.11),
                blurRadius: 35,
                spreadRadius: 0,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/logoSmoothie.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.local_drink_rounded,
                size: 58,
                color: AppColors.primary,
              );
            },
          ),
        ),

        // ======================================================
        // SMALL PREMIUM ACCENT
        // ======================================================
        Positioned(
          right: 18,
          bottom: 23,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.eco_rounded, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// PREMIUM LOADER
// =================================================================

class _PremiumLoader extends StatefulWidget {
  const _PremiumLoader();

  @override
  State<_PremiumLoader> createState() => _PremiumLoaderState();
}

class _PremiumLoaderState extends State<_PremiumLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final double position = (_controller.value * 3) - index;

              final double distance = position.abs();

              final double scale = (1.25 - (distance * 0.35)).clamp(0.75, 1.25);

              final double opacity = (1 - (distance * 0.35)).clamp(0.35, 1);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
