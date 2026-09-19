enum NavItem {
  startBusiness,
  listBusiness,
  businessDetails,
  businessCategory,
  createShop,
}

enum BusinessDetailsMode {
  overview,
  viewProfile,
  editProfile,
}

enum ShopSubView {
  addPlatform,
  chooseStoreType,
  shopWizard,
  viewCreatedShop,
}

enum SetupStepView {
  intro,
  basicDetails,
  locationStep,
  step2Contact,
  step3Documents,
  step4Bank,
  step5Tier,
  step6BusinessType,
  step7BusinessCategory,
  step8BrandSelection,
}

class NavState {
  final NavItem currentItem;
  final SetupStepView setupStepView;
  final ShopSubView shopSubView;
  final BusinessDetailsMode businessDetailsMode;
  final bool isSidebarOpen;
  final bool isBusinessMenuExpanded;
  final bool isShopMenuExpanded;
  final int notificationCount;
  final int messageCount;

  const NavState({
    this.currentItem = NavItem.startBusiness,
    this.setupStepView = SetupStepView.intro,
    this.shopSubView = ShopSubView.addPlatform,
    this.businessDetailsMode = BusinessDetailsMode.overview,
    this.isSidebarOpen = true,
    this.isBusinessMenuExpanded = true,
    this.isShopMenuExpanded = true,
    this.notificationCount = 3,
    this.messageCount = 0,
  });

  NavState copyWith({
    NavItem? currentItem,
    SetupStepView? setupStepView,
    ShopSubView? shopSubView,
    BusinessDetailsMode? businessDetailsMode,
    bool? isSidebarOpen,
    bool? isBusinessMenuExpanded,
    bool? isShopMenuExpanded,
    int? notificationCount,
    int? messageCount,
  }) {
    return NavState(
      currentItem: currentItem ?? this.currentItem,
      setupStepView: setupStepView ?? this.setupStepView,
      shopSubView: shopSubView ?? this.shopSubView,
      businessDetailsMode: businessDetailsMode ?? this.businessDetailsMode,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
      isBusinessMenuExpanded: isBusinessMenuExpanded ?? this.isBusinessMenuExpanded,
      isShopMenuExpanded: isShopMenuExpanded ?? this.isShopMenuExpanded,
      notificationCount: notificationCount ?? this.notificationCount,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
