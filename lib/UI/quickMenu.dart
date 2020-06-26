import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ynotes/UI/settingsPage.dart';
import 'package:ynotes/UI/tabBuilder.dart';
import 'package:flushbar/flushbar.dart';
import 'package:ynotes/apiManager.dart';
import 'package:ynotes/background.dart';
import 'package:ynotes/encrypttest.dart';
import 'package:ynotes/pronoteAPI.dart';
import '../main.dart';
import '../usefulMethods.dart';
import 'dialogs.dart';

class QuickMenu extends StatefulWidget {
  final Function close;

  const QuickMenu(this.close);
  @override
  State<StatefulWidget> createState() {
    return _QuickMenuState();
  }
}

bool visibility = true;

class _QuickMenuState extends State<QuickMenu> with TickerProviderStateMixin {
  OverlayEntry overlayEntry;
  PageController _pageController = PageController(initialPage: 0);

  Animation<double> quickMenuShowAnimation;
  AnimationController quickMenuController;
API api  = APIManager();
  @override
  void initState() {
    super.initState();

    quickMenuController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 80));
    quickMenuShowAnimation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
        new CurvedAnimation(parent: quickMenuController, curve: Curves.easeIn));

    quickMenuController.forward();
  }

  bool isOnDownloadPage = false;
  @override
  Widget build(BuildContext context) {
    show() {
      setState(() {
        visibility = true;
      });
    }

    List quickMenuTexts = [
      "Paramètres",
      "Téléchargements",
      "Envoyer un mail",
      "Signaler un bug"
    ];
    List quickMenuIcons = [
      Icons.settings,
      MdiIcons.downloadOutline,
      MdiIcons.mailboxUp,
      MdiIcons.bug
    ];
    MediaQueryData screenSize;
    screenSize = MediaQuery.of(context);
    return Offstage(
      offstage: !visibility,
      child: AnimatedBuilder(
        animation: quickMenuShowAnimation,
        builder: (_, child) => Container(
          width: screenSize.size.width,
          height: screenSize.size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: screenSize.size.height / 10 * 1.1,
                left: screenSize.size.width / 5 * 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15)),
                        width: screenSize.size.width / 5 * 3,
                        height: !isOnDownloadPage
                            ? (screenSize.size.height / 10 * 0.6) *
                                4 *
                                quickMenuShowAnimation.value
                            : (screenSize.size.height / 10 * 0.6) * 8,
                        child: Container(
                          width: screenSize.size.width / 5 * 3,
                          child: PageView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _pageController,
                            children: <Widget>[
                              //PAGE 1
                              ListView.builder(
                                reverse: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: quickMenuTexts.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: <Widget>[
                                      Container(
                                        child: Material(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          child: InkWell(
                                            splashColor: Color(0xff525252),
                                            onTap: () async {
                                              switch (index) {
                                                case 0:
                                                  widget.close();
                                                  Navigator.of(context).push(
                                                      router(SettingsPage()));

                                                  break;
                                                case 1:
                                                  setState(() {
                                                    isOnDownloadPage = true;
                                                  });
                                                  _pageController.animateToPage(
                                                      1,
                                                      duration: Duration(
                                                          milliseconds: 200),
                                                      curve: Curves.easeIn);
                                                  break;
                                                case 2:
                                                 
                                                 {
                                                   testingEncryptor();
                                                //api.app("cloud", args: "/", action: "CD");
                                           /* var client = Client('https://demo.index-education.net/pronote/eleve.html',
                          username:'demonstration',
                          password:'pronotevs');
                                                    await client.init();
                                                 */

                                       
                                        /*widget.close();
                                        CustomDialogs.showGiffyDialog(context,"QuickMenu","Glisser en bas à droite pour afficher le quickMenu", Image.asset("assets/gifs/QuickMenu720.gif"));*/
                                     
                                                 }
                                                  break;
                                              }
                                            },
                                            child: Container(
                                              width:
                                                  screenSize.size.width / 5 * 3,
                                              height: (screenSize.size.height /
                                                      10 *
                                                      0.6 *
                                                      4) /
                                                  4,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenSize.size.width /
                                                          5 *
                                                          0.25),
                                              child: Stack(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      quickMenuTexts[index],
                                                      style: TextStyle(
                                                          fontFamily: "Asap",
                                                          fontSize: screenSize
                                                                  .size.height /
                                                              10 *
                                                              0.2,
                                                          color:
                                                              isDarkModeEnabled
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Icon(
                                                        quickMenuIcons[index],
                                                        color: isDarkModeEnabled
                                                            ? Colors.white
                                                            : Colors.black),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              ///PAGE 2
                              Material(
                                color: Theme.of(context).primaryColor,
                                child: FutureBuilder(
                                  future: getListOfFiles(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data.length != 0) {
                                        List<FileInfo> listFiles =
                                            snapshot.data;
                                        return Container(
                                          height:
                                              screenSize.size.height / 10 * 8,
                                          child: ListView.builder(
                                            padding: EdgeInsets.all(0.0),
                                            itemCount: listFiles.length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  listFiles[index].fileName;
                                              return Dismissible(
                                                direction:
                                                    DismissDirection.endToStart,
                                                background: Container(
                                                    color: Colors.red),
                                                confirmDismiss:
                                                    (direction) async {
                                                  setState(() {
                                                    visibility = false;
                                                  });
                                                  return await showConfirmationDialog(
                                                          context,
                                                          listFiles[index].file,
                                                          show) ==
                                                      true;
                                                },
                                                onDismissed: (direction) async{
                                                  await AppUtil.remove(
                                                      listFiles[index].file);
                                                      setState(() {
                                                    listFiles.removeAt(index);
                                                  });
                                                },
                                                key: Key(item),
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      ConstrainedBox(
                                                        constraints:
                                                            new BoxConstraints(
                                                          minHeight: screenSize
                                                                  .size.height /
                                                              10 *
                                                              0.8,
                                                        ),
                                                        child: Container(
                                                          margin: EdgeInsets.only(
                                                              bottom: (screenSize
                                                                      .size
                                                                      .height /
                                                                  10 *
                                                                  0.008)),
                                                          child: Material(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            child: InkWell(
                                                              splashColor: Color(
                                                                  0xff525252),
                                                              onTap: () {
                                                                openFile(listFiles[
                                                                        index]
                                                                    .fileName);
                                                              },
                                                              child: Container(
                                                                width: screenSize
                                                                        .size
                                                                        .width /
                                                                    5 *
                                                                    3,
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: screenSize
                                                                            .size
                                                                            .width /
                                                                        5 *
                                                                        0.25,
                                                                    vertical: screenSize
                                                                            .size
                                                                            .height /
                                                                        10 *
                                                                        0.2),
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                    Stack(
                                                                      children: <
                                                                          Widget>[
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Text(
                                                                            snapshot.data[index].fileName,
                                                                            style: TextStyle(
                                                                                fontFamily: "Asap",
                                                                                fontSize: screenSize.size.height / 10 * 0.2,
                                                                                color: isDarkModeEnabled ? Colors.white : Colors.black),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        DateFormat("yyyy-MM-dd HH:mm").format(snapshot
                                                                            .data[index]
                                                                            .lastModifiedDate),
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                "Asap",
                                                                            fontSize: screenSize.size.height /
                                                                                10 *
                                                                                0.2,
                                                                            color: isDarkModeEnabled
                                                                                ? Colors.white.withOpacity(0.5)
                                                                                : Colors.black.withOpacity(0.5)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          height:
                                              screenSize.size.height / 10 * 6,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                MdiIcons.downloadOffOutline,
                                                color: isDarkModeEnabled
                                                    ? Colors.white
                                                    : Colors.black,
                                                size: screenSize.size.width /
                                                    5 *
                                                    1.5,
                                              ),
                                              Text(
                                                "Aucun téléchargement.",
                                                style: TextStyle(
                                                    fontFamily: "Asap",
                                                    color: isDarkModeEnabled
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 15),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                    } else {
                                      return SpinKitFadingFour(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        size: screenSize.size.width / 5 * 1,
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showConfirmationDialog(
    BuildContext context, File file, Function show) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    elevation: 50,
    backgroundColor: Theme.of(context).primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    title: Text(
      "Confirmation",
      style: TextStyle(
          fontFamily: "Asap",
          color: isDarkModeEnabled ? Colors.white : Colors.black),
    ),
    content: Text(
      "Voulez vous vraiment supprimer ce fichier ?",
      style: TextStyle(
          fontFamily: "Asap",
          color: isDarkModeEnabled ? Colors.white : Colors.black),
    ),
    actions: [
      FlatButton(
        child: const Text(
          'ANNULER',
          style: TextStyle(color: Colors.green),
        ),
        onPressed: () {
          show();
          Navigator.pop(context, false);
        },
      ),
      FlatButton(
        child: const Text(
          'SUPPRIMER',
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () {
          show();
          Navigator.pop(context, true);
        },
      )
    ],
  );

  // show the dialog
  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
