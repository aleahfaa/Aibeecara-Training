import 'package:get/get.dart';
import '../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2));
    Get.offAllNamed(Routes.HOME);
  }
}
