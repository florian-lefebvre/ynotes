import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wiredash/wiredash.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ynotes/UI/components/dialogs.dart';
import 'package:ynotes/UI/screens/settings/sub_pages/exportPage.dart';
import 'package:ynotes/UI/screens/settings/sub_pages/logsPage.dart';
import 'package:ynotes/apis/EcoleDirecte.dart';
import 'package:ynotes/background.dart';
import 'package:ynotes/classes.dart';
import 'package:ynotes/main.dart';
import 'package:ynotes/notifications.dart';
import 'package:ynotes/platform.dart';
import 'package:ynotes/utils/themeUtils.dart';

import '../../../tests.dart';
import '../../../usefulMethods.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

bool isFirstAvatarSelected;
final storage = new FlutterSecureStorage();

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  //Settings
  var boolSettings = {
    "nightmode": false,
    "batterySaver": false,
    "notificationNewMail": false,
    "notificationNewGrade": false,
    "lighteningOverride": false,
    "shakeToReport": false
  };

  AnimationController leftToRightAnimation;
  AnimationController rightToLeftAnimation;
  //Avatar's animations :
  Animation<double> movingRow;
  //To use by the actual image when switching
  Animation<double> avatarSize;

  //Disable new grades when battery saver is enabled
  bool disableNotification;
  @override
  void initState() {
    setState(() {
      isFirstAvatarSelected = true;
    });
    getUsername();
    getSettings();
    super.initState();
    leftToRightAnimation = AnimationController(duration: Duration(milliseconds: 800), vsync: this);
    rightToLeftAnimation = AnimationController(duration: Duration(milliseconds: 800), vsync: this);
  }

  void getSettings() async {
    await Future.forEach(boolSettings.keys, (key) async {
      var value = await getSetting(key);
      setState(() {
        boolSettings[key] = value;
      });
    });
  }

  void getUsername() async {
    var actualUserAsync = await ReadStorage("userFullName");
    setState(() {
      actualUser = actualUserAsync;
    });
  }

  @override
  void dispose() {
    // Don't forget to dispose the animation controller on class destruction
    leftToRightAnimation.dispose();
    rightToLeftAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData screenSize = MediaQuery.of(context);
//animation left to right

    return new Scaffold(
        backgroundColor: ThemeUtils().theme["background"]["default"],
        appBar: new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text("Paramètres"),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SettingsList(
          backgroundColor: ThemeUtils().theme["background"]["default"],
          darkBackgroundColor: ThemeUtils().theme["background"]["default"],
          lightBackgroundColor: ThemeUtils().theme["background"]["default"],
          sections: [
            SettingsSection(
              title: 'Mon compte',
              tiles: [
                SettingsTile(
                  title: 'Compte actuellement connecté',
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  subtitle: '${actualUser.length > 0 ? actualUser : "Invité"}',
                  leading: Icon(MdiIcons.account, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () {},
                ),
                SettingsTile(
                  title: 'Déconnexion',
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: Colors.red),
                  leading: Icon(
                    MdiIcons.logout,
                    color: Colors.red,
                  ),
                  onTap: () {
                    showExitDialog(context);
                  },
                )
              ],
            ),
            SettingsSection(
              title: 'Apparence/Comportement',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Mode nuit',
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  leading: Icon(MdiIcons.themeLightDark, color: ThemeUtils().theme["text"]["default"]),
                  switchValue: boolSettings["nightmode"],
                  onToggle: (value) async {
                    setState(() {
                      Provider.of<AppStateNotifier>(context, listen: false).updateTheme(value);
                      boolSettings["nightmode"] = value;
                    });

                    await setSetting("nightmode", value);
                  },
                ),
                SettingsTile.switchTile(
                  title: 'Economiseur de batterie',
                  subtitle: "Réduit les interactions reseaux",
                  titleTextStyle: TextStyle(
                    fontFamily: "Asap",
                    color: ThemeUtils().theme["text"]["default"],
                  ),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  leading: Icon(MdiIcons.batteryHeart, color: ThemeUtils().theme["text"]["default"]),
                  switchValue: boolSettings["batterySaver"],
                  onToggle: (value) async {
                    setState(() {
                      boolSettings["batterySaver"] = value;
                    });

                    await setSetting("batterySaver", value);
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Notifications',
              tiles: [
                SettingsTile.switchTile(
                  title: 'Notification de nouveau mail',
                  enabled: !boolSettings["batterySaver"],
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  switchValue: boolSettings["notificationNewMail"],
                  onToggle: (bool value) async {
                    if (value == false || (await Permission.ignoreBatteryOptimizations.isGranted)) {
                      setState(() {
                        boolSettings["notificationNewMail"] = value;
                      });
                      await setSetting("notificationNewMail", value);
                    } else {
                      if (await CustomDialogs.showAuthorizationsDialog(
                              context,
                              "la configuration d'optimisation de batterie",
                              "Pouvoir s'exécuter en arrière plan sans être automatiquement arrêté par Android.") ??
                          false) {
                        if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
                          setState(() {
                            boolSettings["notificationNewMail"] = value;
                          });
                          await setSetting("notificationNewMail", value);
                        }
                      }
                    }
                  },
                ),
                SettingsTile.switchTile(
                  title: 'Notification de nouvelle note',
                  enabled: !boolSettings["batterySaver"],
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  switchValue: boolSettings["notificationNewGrade"],
                  onToggle: (bool value) async {
                    if (value == false || (await Permission.ignoreBatteryOptimizations.isGranted)) {
                      setState(() {
                        boolSettings["notificationNewGrade"] = value;
                      });
                      await setSetting("notificationNewGrade", value);
                    } else {
                      if (await CustomDialogs.showAuthorizationsDialog(
                              context,
                              "la configuration d'optimisation de batterie",
                              "Pouvoir s'exécuter en arrière plan sans être automatiquement arrêté par Android.") ??
                          false) {
                        if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
                          setState(() {
                            boolSettings["notificationNewGrade"] = value;
                          });
                          await setSetting("notificationNewGrade", value);
                        }
                      }
                    }
                  },
                ),
                SettingsTile(
                  title: 'Je ne reçois pas de notifications',
                  leading: Icon(MdiIcons.bellAlert, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () async {
                    //Check battery optimization setting
                    if (!await Permission.ignoreBatteryOptimizations.isGranted &&
                            await CustomDialogs.showAuthorizationsDialog(
                                context,
                                "la configuration d'optimisation de batterie",
                                "Pouvoir s'exécuter en arrière plan sans être automatiquement arrêté par Android.") ??
                        false) {
                      await Permission.ignoreBatteryOptimizations.request().isGranted;
                    }

                    if (await CustomDialogs.showAuthorizationsDialog(
                            context,
                            "la liste blanche de lancement en arrière plan / démarrage",
                            "Pouvoir lancer yNotes au démarrage de l'appareil et ainsi régulièrement rafraichir en arrière plan.") ??
                        false) {
                      await AndroidPlatformChannel.openAutoStartSettings();
                    }
                    await LocalNotification.showDebugNotification();
                    Flushbar(
                      flushbarPosition: FlushbarPosition.BOTTOM,
                      backgroundColor: Colors.orange.shade200,
                      duration: Duration(seconds: 10),
                      isDismissible: true,
                      margin: EdgeInsets.all(8),
                      messageText: Text(
                        "Toujours pas de notifications ?",
                        style: TextStyle(fontFamily: "Asap"),
                      ),
                      mainButton: FlatButton(
                        onPressed: () {
                          const url = 'https://ynotes.fr/help/notifications';
                          launchURL(url);
                        },
                        child: Text(
                          "Aide liée aux notifications",
                          style: TextStyle(color: Colors.blue, fontFamily: "Asap"),
                        ),
                      ),
                      borderRadius: 8,
                    )..show(context);
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
              ],
            ),
            SettingsSection(
              title: 'Paramètres scolaires',
              tiles: [
                SettingsTile(
                  title: 'Choisir mes spécialités',
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  leading: Icon(MdiIcons.formatListBulleted, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () {
                    CustomDialogs.showSpecialtiesChoice(context);
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Assistance',
              tiles: [
                SettingsTile(
                  title: 'Afficher les logs',
                  leading: Icon(MdiIcons.bug, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () {
                    Navigator.of(context).push(router(LogsPage()));
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
                SettingsTile(
                  title: 'Signaler un bug',
                  subtitle: 'Ou nous recommander quelque chose',
                  leading: Icon(MdiIcons.commentAlert, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () {
                    Wiredash.of(context).show();
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
              ],
            ),
            SettingsSection(
              title: 'Autres paramètres',
              tiles: [
                SettingsTile(
                  title: 'Gestionnaire de sauvegarde',
                  leading: Icon(MdiIcons.contentSave, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () async {
                    Navigator.of(context).push(router(ExportPage()));
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
                SettingsTile(
                  title: 'Réinitialiser le tutoriel',
                  leading: Icon(MdiIcons.restore, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () async {
                    if (await CustomDialogs.showConfirmationDialog(context, null,
                        alternativeText: "Etes-vous sûr de vouloir réinitialiser le tutoriel ?",
                        alternativeButtonConfirmText: "confirmer")) {
                      await HelpDialog.resetEveryHelpDialog();
                    }
                    HelpDialog.resetEveryHelpDialog();
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
                SettingsTile(
                  title: 'Supprimer les données hors ligne',
                  leading: Icon(MdiIcons.deleteAlert, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () async {
                    if (await CustomDialogs.showConfirmationDialog(context, null,
                        alternativeText:
                            "Etes-vous sûr de vouloir supprimer les données hors ligne ? (irréversible)")) {
                      await offline.clearAll();
                    }
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
                SettingsTile(
                  title: 'Note de mise à jour',
                  leading: Icon(MdiIcons.file, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () async {
                    CustomDialogs.showUpdateNoteDialog(context);
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
                SettingsTile(
                  title: 'A propos de cette application',
                  leading: Icon(MdiIcons.information, color: ThemeUtils().theme["text"]["default"]),
                  onTap: () async {
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();

                    showAboutDialog(
                        context: this.context,
                        applicationIcon: Image(
                          image: AssetImage('assets/appico/foreground.png'),
                          width: screenSize.size.width / 5 * 0.7,
                        ),
                        applicationName: "yNotes",
                        applicationVersion:
                            packageInfo.version + "+" + packageInfo.buildNumber + " T" + Tests.testVersion ?? "",
                        applicationLegalese:
                            "Developpé avec amour en France.\nAPI Pronote adaptée à l'aide de l'API pronotepy développée par Bain sous licence MIT.\nJe remercie la participation des bêta testeurs et des développeurs ayant participé au développement de l'application.");
                  },
                  titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                  subtitleTextStyle: TextStyle(
                      fontFamily: "Asap",
                      color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                ),
                if (!kReleaseMode)
                  SettingsTile(
                    title: 'Bouton magique',
                    leading: Icon(MdiIcons.testTube, color: ThemeUtils().theme["text"]["default"]),
                    onTap: () async {
                      //await setIntSetting("gradesNumber", 35);
                      //print((await getIntSetting("gradesNumber")));
                      //await setIntSetting("gradesNumber", 35);
                      await LocalNotification.showNewMailNotification((await getMails()).first,"fff");
                    },
                    titleTextStyle: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
                    subtitleTextStyle: TextStyle(
                        fontFamily: "Asap",
                        color: isDarkModeEnabled ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7)),
                  ),
              ],
            ),
          ],
        ));
  }
}

showExitDialog(BuildContext context) {
  // set up the AlertDialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          elevation: 50,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            "Confirmation",
            style: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
          ),
          content: Text(
            "Voulez vous vraiment vous deconnecter ?",
            style: TextStyle(fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"]),
          ),
          actions: [
            FlatButton(
              child: const Text(
                'ANNULER',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: const Text(
                'SE DECONNECTER',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await exitApp();
                try {
                  Provider.of<AppStateNotifier>(context, listen: false).updateTheme(false);
                } catch (e) {}
                Navigator.of(context).pushReplacement(router(login()));
              },
            )
          ]);
    },
  );
}
