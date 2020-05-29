import 'package:econoomaccess/AddDetailsMaker.dart';
import 'package:econoomaccess/ChatPage.dart';
import 'package:econoomaccess/ChooseOrderToTrack.dart';
import 'package:econoomaccess/ExistingOrder.dart';
import 'package:econoomaccess/LoyaltyPage.dart';
import 'package:econoomaccess/MakerAddProfilePhotoPage.dart';
import 'package:econoomaccess/MakerInstructions.dart';
import 'package:econoomaccess/Makerchat.dart';
import 'package:econoomaccess/ReviewOrder.dart';
import 'package:econoomaccess/TrackOrder.dart';
import 'package:econoomaccess/UserProfilePage.dart';
import 'package:econoomaccess/VendorLocation.dart';
import 'package:econoomaccess/analytics.dart';
import 'package:econoomaccess/business_location.dart';
import 'package:econoomaccess/homemaker_profile.dart';
import 'package:econoomaccess/payouts.dart';
import 'package:econoomaccess/promotionList.dart';
import 'package:provider/provider.dart';
import 'favorites_screen.dart';
import 'chat.dart';
import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'AuthChoosePage.dart';
import 'EditPage.dart';
import 'ExplorePage.dart';
import 'MenuPage.dart';
import 'OnBoardPage.dart';
import 'ProfilePage.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';
import 'UserDetailsPage.dart';
import 'foodPref.dart';
import 'localization/appLocalization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ProfileSetUpIntroPage.dart';
import 'localization/language_constants.dart';
import 'recepie_screen.dart';
import 'new_item.dart';
import 'UserAddProfilePhotoPage.dart';
import 'MerchantOrder.dart';
import 'MakerOnBoardPage.dart';
import 'PromotionsPage.dart';
import 'PromotionMealOpen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
      return ChangeNotifierProvider(
        create: (context) => PriceModel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: [
            Locale("en", "US"),
            Locale("bn", "IN"),
            Locale("gu", "IN"),
            Locale("hi", "IN"),
            Locale("kn", "IN"),
            Locale("ml", "IN"),
            Locale("mr", "IN"),
            Locale("pa", "IN"),
            Locale("ta", "IN"),
            Locale("te", "IN"),
            Locale("ur", "IN")
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          title: "Naniz Eats",
          home: AuthChoosePage(),
          theme: ThemeData(
            textTheme: TextTheme(
              button: TextStyle(
                fontFamily: "Gilroy",
              ),
              caption: TextStyle(
                fontFamily: "Gilroy",
              ),
              body1: TextStyle(
                fontFamily: "Gilroy",
              ),
              body2: TextStyle(
                fontFamily: "Gilroy",
              ),
            ),
          ),
          routes: <String, WidgetBuilder>{
            "/SignInPage": (BuildContext context) => SignInPage(),
            "/SignUpPage": (BuildContext context) => SignUpPage(),
            "/OnBoardPage": (BuildContext context) => OnBoardPage(),
            "/ProfileSetUpIntroPage": (BuildContext context) =>
                ProfileSetUpIntoPage(),
            "/UserDetailsPage": (BuildContext context) => UserDetailsPage(),
            "/MenuPage": (BuildContext context) => MenuPage(),
            "/EditPage": (BuildContext context) => EditPage(),
            "/AuthChoosePage": (BuildContext context) => AuthChoosePage(),
            "/ExplorePage": (BuildContext context) => ExplorePage(),
            "/FoodPrefPage": (BuildContext context) => FoodPref(),
            "/SearchPage": (BuildContext context) => SearchScreen(),
            "/ProfilePage": (BuildContext context) => ProfilePage(),
            "/ChatPage": (BuildContext context) => ChatScreen(),
            "/RecipePage": (BuildContext context) => RecipeScreen(),
            "/FavoriteScreenPage": (BuildContext context) => FavoritesScreen(),
            "/NewItemPage": (BuildContext context) => NewItem(),
            "/ReviewOrderPage": (BuildContext context) => ReviewOrder(),
            "/MerchantOrderPage": (BuildContext context) => MerchantOrder(),
            "/UserAddProfilePhotoPage": (BuildContext context) => UserAddProfilePhotoPage(),
            "/MakerAddProfilePhotoPage": (BuildContext context) => MakerAddProfilePhotoPage(),
            "/MakerOnBoardPage": (BuildContext context) => MakerOnBoardPage(),
            "/AddDetailsMakerPage": (BuildContext context) => AddDetailsMaker(),
            "/MakerInstructionsPage": (BuildContext context) => MakerInstructions(),
            "/MakerChatPage": (BuildContext context) => MakerChatScreen(),
            "/BuissnessLocationPage": (BuildContext context) => BusinessLocation(),
            "/UserProfilePage": (BuildContext context) => UserProfilePage(),
            "/LoyaltyPage": (BuildContext context) => LoyaltyPage(),
            "/AnalyticsPage": (BuildContext context) => Analytics(),
            "/PromotionListPage": (BuildContext context) => PromotionList(),
            "/ExistingOrders": (BuildContext context) => ExistingOrders(),
            "/TrackOrder": (BuildContext context) => TrackOrder(),
            "/VendorLocation": (BuildContext context) => VendorLocation(),
            "/ChooseTrackOrder": (BuildContext context) => ChooseTrackOrder(),
            "/PromotionPage": (BuildContext context) => PromotionsPage(),
            "/PayoutPage": (BuildContext context) => Payouts(),
            "/HomemakerProfilePage": (BuildContext context) => HomemakerProfile(),
          },
        ),
      );
    }
  }
}
