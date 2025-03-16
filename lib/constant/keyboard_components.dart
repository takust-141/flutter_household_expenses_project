import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

final List<IconData> keyboardIcons = [
  //お金系
  Symbols.savings,
  Symbols.payments,
  Symbols.credit_card,
  Symbols.receipt_long,
  Symbols.show_chart,
  Symbols.calendar_today,

  //家具
  Symbols.home,
  Symbols.scene, //家具
  Symbols.mode_fan,
  Symbols.tv_gen,

  //買い物
  Symbols.store,
  Symbols.shopping_bag,
  Symbols.shopping_cart,
  //日用品、掃除
  Symbols.water_bottle,
  Symbols.cleaning,
  Symbols.self_care,
  Symbols.health_and_beauty,
  Symbols.mop,
  //衣料
  Symbols.apparel,
  Symbols.local_laundry_service,
  Symbols.checkroom,
  //仕事
  Symbols.apartment,
  Symbols.work,

  //固定費
  Symbols.faucet, //水道
  Symbols.water_drop,
  Symbols.local_fire_department,
  Symbols.lightbulb,
  Symbols.power,

  //デバイス
  Symbols.phone,
  Symbols.phone_iphone,
  Symbols.app_promo,
  Symbols.devices,
  Symbols.wifi,
  Symbols.computer,
  Symbols.cloud,

  //飲食
  Symbols.restaurant,
  Symbols.skillet,
  Symbols.breakfast_dining,
  Symbols.brunch_dining,
  Symbols.dinner_dining,
  Symbols.sports_bar,
  Symbols.fastfood,
  Symbols.local_cafe,

  //医療
  Symbols.medical_services,
  Symbols.pill,

  //趣味
  Symbols.attractions,
  Symbols.movie,
  Symbols.videocam,
  Symbols.photo_camera,
  Symbols.landscape,
  Symbols.outdoor_garden,
  Symbols.bath_outdoor,
  Symbols.music_note,
  Symbols.stadia_controller,
  Symbols.sports_tennis,
  //運動
  Symbols.fitness_center,
  Symbols.directions_walk,
  Symbols.directions_run,

  //勉強
  Symbols.edit_note,
  Symbols.book_2,
  Symbols.menu_book,
  //子ども
  Symbols.pediatrics,
  Symbols.stroller,
  Symbols.toys,
  Symbols.school,
  //ペット
  Symbols.pets,
  Symbols.pet_supplies,
  //祝
  Symbols.featured_seasonal_and_gifts,
  Symbols.cake,
  Symbols.celebration,

  //交通費
  Symbols.commute,
  Symbols.luggage,

  //旅行
  Symbols.trip,
  Symbols.bedtime,
  //交通
  Symbols.directions_car,
  Symbols.directions_bus,
  Symbols.train,
  Symbols.travel,
  Symbols.moped,
  Symbols.local_gas_station,
  Symbols.local_parking,
  Symbols.transit_ticket,

  //人
  Symbols.emoji_people,
  Symbols.person,
  Symbols.groups,
  Symbols.public,

  //シンボル
  Symbols.favorite,
  Symbols.star,
  Symbols.circle,
  Symbols.sunny,
];

final List<Color> keyboardColors = [
  Colors.red.shade600,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.deepOrange.shade900,
  Colors.brown,
  Colors.blueGrey,
  Colors.grey.shade800,
];

final Map<String, Color> categoryColors = {
  for (var color in keyboardColors) color.toARGB32().toString(): color,
  'default': Colors.grey.shade800,
};

final Map<String, IconData> categoryIcons = {
  for (var icon in keyboardIcons) icon.codePoint.toString(): icon,
  'default': keyboardIcons[0],
};
