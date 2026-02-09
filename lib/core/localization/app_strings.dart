import 'package:flutter/material.dart';

enum AppLanguage { ru, uz, en }

class AppStrings {
  static final ValueNotifier<AppLanguage> languageNotifier = ValueNotifier(AppLanguage.ru);

  static AppLanguage get currentLanguage => languageNotifier.value;
  static set currentLanguage(AppLanguage lang) => languageNotifier.value = lang;

  static final Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.ru: {
      'profile': 'Профиль',
      'my_applications': 'Мои заявки',
      'catalog': 'Каталог',
      'home': 'Главная',
      'total_apps': 'Всего заявок',
      'active_apps': 'Активные',
      'completed_apps': 'Завершено',
      'personal_data': 'Персональные данные',
      'my_documents': 'Мои документы',
      'phone': 'Телефон',
      'settings': 'Настройки',
      'notifications': 'Уведомления',
      'language': 'Язык',
      'help': 'Справка',
      'contact_us': 'Связаться с нами',
      'about_app': 'О приложении',
      'logout': 'Выйти из аккаунта',
      'login': 'Войти',
      'register': 'Регистрация',
      'search': 'Поиск',
      'filter': 'Фильтр',
      'brands': 'Бренды',
      'quick_actions': 'Быстрые действия',
      'damaged_cars': 'Битые авто',
      'new_cars': 'Новые авто',
      'special_offers': 'Спецпредложения',
      'details': 'Детали',
      'all': 'Все',
      'found_cars': 'Найдено {} автомобилей',
    },
    AppLanguage.uz: {
      'profile': 'Profil',
      'my_applications': 'Mening arizalarim',
      'catalog': 'Katalog',
      'home': 'Asosiy',
      'total_apps': 'Jami arizalar',
      'active_apps': 'Faol',
      'completed_apps': 'Yakunlangan',
      'personal_data': 'Shaxsiy ma\'lumotlar',
      'my_documents': 'Mening hujjatlarim',
      'phone': 'Telefon',
      'settings': 'Sozlamalar',
      'notifications': 'Bildirishnomalar',
      'language': 'Til',
      'help': 'Yordam',
      'contact_us': 'Biz bilan bog\'lanish',
      'about_app': 'Ilova haqida',
      'logout': 'Hisobdan chiqish',
      'login': 'Kirish',
      'register': 'Ro\'yxatdan o\'tish',
      'search': 'Qidiruv',
      'filter': 'Filtr',
      'brands': 'Brendlar',
      'quick_actions': 'Tezkor amallar',
      'damaged_cars': 'Urilgan avto',
      'new_cars': 'Yangi avto',
      'special_offers': 'Maxsus takliflar',
      'details': 'Batafsil',
      'all': 'Barchasi',
      'found_cars': '{} ta avtomobil topildi',
    },
    AppLanguage.en: {
      'profile': 'Profile',
      'my_applications': 'My Applications',
      'catalog': 'Catalog',
      'home': 'Home',
      'total_apps': 'Total Applications',
      'active_apps': 'Active',
      'completed_apps': 'Completed',
      'personal_data': 'Personal Data',
      'my_documents': 'My Documents',
      'phone': 'Phone',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'language': 'Language',
      'help': 'Help',
      'contact_us': 'Contact Us',
      'about_app': 'About App',
      'logout': 'Logout',
      'login': 'Login',
      'register': 'Register',
      'search': 'Search',
      'filter': 'Filter',
      'brands': 'Brands',
      'quick_actions': 'Quick Actions',
      'damaged_cars': 'Damaged Cars',
      'new_cars': 'New Cars',
      'special_offers': 'Special Offers',
      'details': 'Details',
      'all': 'All',
      'found_cars': 'Found {} cars',
    },
  };

  static String get(String key, {String? arg}) {
    String text = _translations[currentLanguage]?[key] ?? key;
    if (arg != null) {
      text = text.replaceFirst('{}', arg);
    }
    return text;
  }
}
