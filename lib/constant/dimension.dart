import 'package:flutter/material.dart';

const double sssmall = 2;
const double ssmall = 4;
const double small = 8;
const double msmall = 10;
const double smedium = 14;
const double medium = 16;
const double lmedium = 20;
const double large = 24;

const sssmallEdgeInsets = EdgeInsets.all(sssmall);
const ssmallEdgeInsets = EdgeInsets.all(ssmall);
const smallEdgeInsets = EdgeInsets.all(small);
const mediumEdgeInsets = EdgeInsets.all(medium);
const largeEdgeInsets = EdgeInsets.all(large);

const ssmallLeftEdgeInsets = EdgeInsets.only(left: ssmall);
const smallVerticalEdgeInsets = EdgeInsets.symmetric(vertical: small);
const ssmallVerticalEdgeInsets = EdgeInsets.symmetric(vertical: ssmall);
const ssmallHorizontalEdgeInsets = EdgeInsets.symmetric(horizontal: ssmall);
const smallHorizontalEdgeInsets = EdgeInsets.symmetric(horizontal: small);

//AppBar
const appbarSidePadding = smedium;

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
const double categoryCardHeight = 100;
const double categoryCardWidth = 130;

//画面用
const viewEdgeInsets = EdgeInsets.fromLTRB(medium, large, medium, medium);
