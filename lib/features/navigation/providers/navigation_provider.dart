import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nav_state.dart';

class NavigationNotifier extends Notifier<NavState> {
  @override
  NavState build() => const NavState();

  void setNavItem(NavItem item) {
    state = state.copyWith(currentItem: item);
  }

  void setSetupStepView(SetupStepView view) {
    state = state.copyWith(
      currentItem: NavItem.startBusiness,
      setupStepView: view,
    );
  }

  void navigateToSetupBasic() {
    setSetupStepView(SetupStepView.basicDetails);
  }

  void navigateToLocationStep() {
    setSetupStepView(SetupStepView.locationStep);
  }

  void navigateToStep2() {
    setSetupStepView(SetupStepView.step2Contact);
  }

  void navigateToStep3() {
    setSetupStepView(SetupStepView.step3Documents);
  }

  void navigateToStep4() {
    setSetupStepView(SetupStepView.step4Bank);
  }

  void navigateToStep5() {
    setSetupStepView(SetupStepView.step5Tier);
  }

  void navigateToStep6() {
    setSetupStepView(SetupStepView.step6BusinessType);
  }

  void navigateToStep7() {
    setSetupStepView(SetupStepView.step7BusinessCategory);
  }

  void navigateToStep8() {
    setSetupStepView(SetupStepView.step8BrandSelection);
  }

  void navigateBackToIntro() {
    setSetupStepView(SetupStepView.intro);
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarOpen: !state.isSidebarOpen);
  }

  void toggleBusinessMenu() {
    state = state.copyWith(
      isBusinessMenuExpanded: !state.isBusinessMenuExpanded,
    );
  }

  void setShopSubView(ShopSubView view) {
    state = state.copyWith(
      currentItem: NavItem.createShop,
      shopSubView: view,
      isShopMenuExpanded: true,
    );
  }

  void toggleShopMenu() {
    state = state.copyWith(
      isShopMenuExpanded: !state.isShopMenuExpanded,
    );
  }

  void navigateToBusinessDetails({BusinessDetailsMode mode = BusinessDetailsMode.overview}) {
    state = state.copyWith(
      currentItem: NavItem.businessDetails,
      businessDetailsMode: mode,
      isBusinessMenuExpanded: true,
    );
  }

  void navigateToBusinessCategory() {
    state = state.copyWith(
      currentItem: NavItem.businessCategory,
      isBusinessMenuExpanded: true,
    );
  }

  void navigateToListBusiness() {
    state = state.copyWith(
      currentItem: NavItem.listBusiness,
      isBusinessMenuExpanded: true,
    );
  }

  void clearNotifications() {
    state = state.copyWith(notificationCount: 0);
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavState>(NavigationNotifier.new);
