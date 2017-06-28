// ......................................................................................................
//
//  configuration, v0.0
//
//  by xiangchen@acm.org, 06/2017
//
// ......................................................................................................

var FORTE = FORTE || {};

//
// topology optimization related
//
FORTE.P = 3;
FORTE.MAXITERATIONS = 50;   // fix this
FORTE.INITMATERIALRATIO = 0.15;
FORTE.MINMATERIALRATIO = 0.05;
FORTE.MAXMATERIALRATIO = 0.5;
FORTE.MINSIMILARITYRATIO = 0;
FORTE.MAXSIMILARITYRATIO = 10;

FORTE.GETVARIATION = 0;
FORTE.ADDSTRUCTS = 1;

//
// control ui related
//
FORTE.WIDTHDEFAULT = 240;
FORTE.HEIGHTDEFAULT = 160;

FORTE.ICONNEW = 'assets/new.svg';
FORTE.ICONDESIGN = 'assets/design.svg';
FORTE.ICONVOID = 'assets/void.svg';
FORTE.ICONLOAD = 'assets/load.svg';
FORTE.ICONBOUNDARY = 'assets/boundary.svg';
FORTE.ICONERASER = 'assets/eraser.svg';
FORTE.ICONSAVE = 'assets/save.svg';
FORTE.ICONEYE = 'assets/eye.svg';

FORTE.MINSLIDER = 0;
FORTE.MAXSLIDER = 100;
FORTE.WIDTHMATERIALSLIDER = '180px';

FORTE.HTMLCODENEWDESIGN = '&#128459;';
FORTE.HTMLCODETRIANGLEDOWN = '&#9660;';
FORTE.HTMLCODETRIANGLEUP = '&#9650;';

FORTE.COLORBLACK = '#000000';
FORTE.COLORRED = '#cc0000';
FORTE.COLORYELLOW = '#fffa90';
FORTE.COLORBLUE = '#00afff';

FORTE.MAINTABLETEMPLATE = 'assets/main_table.html';
FORTE.MINALPHAFORANIMATION = 0.33;
FORTE.PSEUDOMAXALPHA = 0.5;

FORTE.FETCHINTERVAL = 200;
FORTE.RENDERINTERVAL = 100;

FORTE.GIVEUPTHRESHOLD = 3;
FORTE.DELAYEDSTART = 1;

FORTE.WIDTHOPTIMIZEDPANEL = 96;

FORTE.LABELGETVARIATION = 'get variation';
FORTE.LABELADDSTRUCTS = 'add structs';

//
// canvas ui related
//
FORTE.BGCOLORCANVAS = '#f0f0f0';