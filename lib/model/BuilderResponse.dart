class BuilderResponse {
  Dashboard? dashboard;
  Productdetailview? productdetailview;
  AppSetUp? appSetUp;

  BuilderResponse({this.dashboard, this.productdetailview, this.appSetUp});

  BuilderResponse.fromJson(Map<String, dynamic> json) {
    dashboard = json['dashboard'] != null
        ? new Dashboard.fromJson(json['dashboard'])
        : null;
    productdetailview = json['productdetailview'] != null
        ? new Productdetailview.fromJson(json['productdetailview'])
        : null;
    appSetUp = json['appSetUp'] != null
        ? new AppSetUp.fromJson(json['appSetUp'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dashboard != null) {
      data['dashboard'] = this.dashboard!.toJson();
    }
    if (this.productdetailview != null) {
      data['productdetailview'] = this.productdetailview!.toJson();
    }
    if (this.appSetUp != null) {
      data['appSetUp'] = this.appSetUp!.toJson();
    }
    return data;
  }
}

class Dashboard {
  List<String>? sorting;
  String? layout;
  AppBar? appBar;
  AdvertiseBanner? advertiseBanner;
  AdvertiseBanner? category;
  AdvertiseBanner? saleBanner;
  NewArrivals? newArrivals;
  NewArrivals? spotLight;
  NewArrivals? trendingProduct;
  NewArrivals? todayDeal;
  NewArrivals? topPicks;
  NewArrivals? moreOffer;
  NewArrivals? hotRightNow;
  NewArrivals? vendor;
  NewArrivals? youMayAlsoLike;

  Dashboard(
      {this.sorting,
        this.layout,
        this.appBar,
        this.advertiseBanner,
        this.category,
        this.saleBanner,
        this.newArrivals,
        this.spotLight,
        this.trendingProduct,
        this.todayDeal,
        this.topPicks,
        this.moreOffer,
        this.hotRightNow,
        this.vendor,
        this.youMayAlsoLike});

  Dashboard.fromJson(Map<String, dynamic> json) {
    sorting = json['sorting'].cast<String>();
    layout = json['layout'];
    appBar =
    json['appBar'] != null ? new AppBar.fromJson(json['appBar']) : null;
    advertiseBanner = json['advertiseBanner'] != null
        ? new AdvertiseBanner.fromJson(json['advertiseBanner'])
        : null;
    category = json['category'] != null
        ? new AdvertiseBanner.fromJson(json['category'])
        : null;
    saleBanner = json['saleBanner'] != null
        ? new AdvertiseBanner.fromJson(json['saleBanner'])
        : null;
    newArrivals = json['newArrivals'] != null
        ? new NewArrivals.fromJson(json['newArrivals'])
        : null;
    spotLight = json['spotLight'] != null
        ? new NewArrivals.fromJson(json['spotLight'])
        : null;
    trendingProduct = json['trendingProduct'] != null
        ? new NewArrivals.fromJson(json['trendingProduct'])
        : null;
    todayDeal = json['todayDeal'] != null
        ? new NewArrivals.fromJson(json['todayDeal'])
        : null;
    topPicks = json['topPicks'] != null
        ? new NewArrivals.fromJson(json['topPicks'])
        : null;
    moreOffer = json['moreOffer'] != null
        ? new NewArrivals.fromJson(json['moreOffer'])
        : null;
    hotRightNow = json['hotRightNow'] != null
        ? new NewArrivals.fromJson(json['hotRightNow'])
        : null;
    vendor = json['vendor'] != null
        ? new NewArrivals.fromJson(json['vendor'])
        : null;
    youMayAlsoLike = json['youMayAlsoLike'] != null
        ? new NewArrivals.fromJson(json['youMayAlsoLike'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sorting'] = this.sorting;
    data['layout'] = this.layout;
    if (this.appBar != null) {
      data['appBar'] = this.appBar!.toJson();
    }
    if (this.advertiseBanner != null) {
      data['advertiseBanner'] = this.advertiseBanner!.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.saleBanner != null) {
      data['saleBanner'] = this.saleBanner!.toJson();
    }
    if (this.newArrivals != null) {
      data['newArrivals'] = this.newArrivals!.toJson();
    }
    if (this.spotLight != null) {
      data['spotLight'] = this.spotLight!.toJson();
    }
    if (this.trendingProduct != null) {
      data['trendingProduct'] = this.trendingProduct!.toJson();
    }
    if (this.todayDeal != null) {
      data['todayDeal'] = this.todayDeal!.toJson();
    }
    if (this.topPicks != null) {
      data['topPicks'] = this.topPicks!.toJson();
    }
    if (this.moreOffer != null) {
      data['moreOffer'] = this.moreOffer!.toJson();
    }
    if (this.hotRightNow != null) {
      data['hotRightNow'] = this.hotRightNow!.toJson();
    }
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    if (this.youMayAlsoLike != null) {
      data['youMayAlsoLike'] = this.youMayAlsoLike!.toJson();
    }
    return data;
  }
}

class AppBar {
  String? title;

  AppBar({this.title});

  AppBar.fromJson(Map<String, dynamic> json) {
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    return data;
  }
}

class AdvertiseBanner {
  bool? enable;

  AdvertiseBanner({this.enable});

  AdvertiseBanner.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enable'] = this.enable;
    return data;
  }
}

class NewArrivals {
  bool? enable;
  String? title;
  String? viewAll;

  NewArrivals({this.enable, this.title, this.viewAll});

  NewArrivals.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
    title = json['title'];
    viewAll = json['viewAll'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enable'] = this.enable;
    data['title'] = this.title;
    data['viewAll'] = this.viewAll;
    return data;
  }
}

class Productdetailview {
  String? layout;

  Productdetailview({this.layout});

  Productdetailview.fromJson(Map<String, dynamic> json) {
    layout = json['layout'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['layout'] = this.layout;
    return data;
  }
}

class AppSetUp {
  String? appName;
  String? primaryColor;
  String? secondaryColor;
  String? backgroundColor;
  String? textPrimaryColor;
  String? textSecondaryColor;
  String? consumerKey;
  String? consumerSecret;
  String? appUrl;

  AppSetUp(
      {this.appName,
        this.primaryColor,
        this.secondaryColor,
        this.backgroundColor,
        this.textPrimaryColor,
        this.textSecondaryColor,
        this.consumerKey,
        this.consumerSecret,
        this.appUrl});

  AppSetUp.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    primaryColor = json['primaryColor'];
    secondaryColor = json['secondaryColor'];
    backgroundColor = json['backgroundColor'];
    textPrimaryColor = json['textPrimaryColor'];
    textSecondaryColor = json['textSecondaryColor'];
    consumerKey = json['consumerKey'];
    consumerSecret = json['consumerSecret'];
    appUrl = json['appUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appName'] = this.appName;
    data['primaryColor'] = this.primaryColor;
    data['secondaryColor'] = this.secondaryColor;
    data['backgroundColor'] = this.backgroundColor;
    data['textPrimaryColor'] = this.textPrimaryColor;
    data['textSecondaryColor'] = this.textSecondaryColor;
    data['consumerKey'] = this.consumerKey;
    data['consumerSecret'] = this.consumerSecret;
    data['appUrl'] = this.appUrl;
    return data;
  }
}
