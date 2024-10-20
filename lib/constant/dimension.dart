import 'package:flutter/material.dart';

const double sssmall = 2;
const double ssmall = 4;
const double small = 8;
const double msmall = 10;
const double smedium = 14;
const double medium = 16;
const double lmedium = 20;
const double large = 24;
const double llarge = 28;
const double lllarge = 32;

const sssmallEdgeInsets = EdgeInsets.all(sssmall);
const ssmallEdgeInsets = EdgeInsets.all(ssmall);
const smallEdgeInsets = EdgeInsets.all(small);
const mediumEdgeInsets = EdgeInsets.all(medium);
const largeEdgeInsets = EdgeInsets.all(large);

const ssmallLeftEdgeInsets = EdgeInsets.only(left: ssmall);
const mediumLeftEdgeInsets = EdgeInsets.only(left: medium);
const msmallRightEdgeInsets = EdgeInsets.only(right: msmall);
const mediumRightEdgeInsets = EdgeInsets.only(right: medium);

const smallVerticalEdgeInsets = EdgeInsets.symmetric(vertical: small);
const ssmallVerticalEdgeInsets = EdgeInsets.symmetric(vertical: ssmall);
const ssmallHorizontalEdgeInsets = EdgeInsets.symmetric(horizontal: ssmall);
const smallHorizontalEdgeInsets = EdgeInsets.symmetric(horizontal: small);
const mediumHorizontalEdgeInsets = EdgeInsets.symmetric(horizontal: medium);

//AppBar
const appbarSidePadding = smedium;
const segmentedButtonPadding =
    EdgeInsets.symmetric(vertical: small, horizontal: lllarge);

const appbarSearchPadding =
    EdgeInsets.symmetric(vertical: small, horizontal: medium);

const double bottomAppBarHeight = 70;
const double bottomNavIconSize = 25;

//CalendarSliver用
const calendarSliverEdgeInsets =
    EdgeInsets.symmetric(vertical: smedium, horizontal: msmall);

const sumContainerEdgeInsets =
    EdgeInsets.symmetric(vertical: ssmall, horizontal: small);

//registerList用
const double registerYMListHeight = 40;
const double registerListHeight = 50;
const double registerDateWidth = 40;
const double registerListPadding = small;

const double colorV = ssmall + 2;
const double colorH = 6;
const colorContainerMargin =
    EdgeInsets.symmetric(vertical: colorV, horizontal: colorH);
const colorContainerHeight =
    registerListHeight - registerListPadding - colorV * 2;

//カスタムキーボード
const double keyboardIconSize = 24;
const double customIconSize = 20;
const keyboardInkWellPadding = EdgeInsets.all(5);
const keyboardCustomIconPadding =
    EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0);
const keyboardClosedIconPadding =
    EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0);

const double containreBorderRadius = 6;
const double dialogRadius = 10;

const double boarderWidth = 1.2;

const double keyboardMonthHeight = 45.0;
const double weekHeight = 28.0;

//リストアイテム
const double listHeight = 45;

//Form
const double formItemHeight = 50;
const double formItemNameWidth = 90;
BorderRadius formInputBoarderRadius = BorderRadius.circular(small);
BorderRadius formInputInnerBoarderRadius =
    BorderRadius.circular(small - formInputBoarderWidth);
const double formInputBoarderWidth = 2.0;
const double formInputpadding = smedium;

//カテゴリedit
const double categoryCardHeight = 130;
const double categoryCardWidth = 130;

//画面用
const viewEdgeInsets = EdgeInsets.fromLTRB(medium, large, medium, large);

//register
const double registerItemHeight = 50;
const double registerItemTitleWidth = 120;
const double moneyFontsize = 20;
const double amountOfMoneyFormHeight = 62;
const double registerButtonHeight = 50;

BorderRadius segmentedButtomRadius = BorderRadius.circular(msmall);
BorderRadius registerButtomRadius = BorderRadius.circular(msmall);
