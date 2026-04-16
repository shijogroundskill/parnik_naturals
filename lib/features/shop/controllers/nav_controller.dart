import 'package:get/get.dart';

class NavController extends GetxController {
  final index = 0.obs;

  void setIndex(int i) => index.value = i;

  void goToShop() => setIndex(0);
  void goToCart() => setIndex(1);
  void goToMore() => setIndex(2);
}

