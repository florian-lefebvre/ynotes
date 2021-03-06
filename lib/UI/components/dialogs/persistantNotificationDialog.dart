import 'package:auto_size_text/auto_size_text.dart';
import 'package:battery_optimization/battery_optimization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ynotes/UI/components/dialogs.dart';
import 'package:ynotes/UI/screens/agenda/agendaPageWidgets/agenda.dart';
import 'package:ynotes/utils/themeUtils.dart';
import 'package:ynotes/main.dart';

import '../../../notifications.dart';
import '../../../usefulMethods.dart';

class PersistantNotificationConfigDialog extends StatefulWidget {
  @override
  _PersistantNotificationConfigDialogState createState() => _PersistantNotificationConfigDialogState();
}

class _PersistantNotificationConfigDialogState extends State<PersistantNotificationConfigDialog> {
  var boolSettings = {
    "enableDNDWhenOnGoingNotifEnabled": false,
    "agendaOnGoingNotification": false,
    "disableAtDayEnd": false,
  };
  String perm = "Permissions accordées.";
  void initState() {
    // TODO: implement initState

    getSettings();
    getAuth();
  }

  getAuth() async {
    await BatteryOptimization.isIgnoringBatteryOptimizations().then((onValue) {
      setState(() {
        if (onValue) {
          setState(() {
            perm = "";
          });
        } else {
          setState(() {
            perm = "L'application n'ignore pas les optimisations de batterie !";
          });
        }
      });
    });
  }

  var intSettings = {};
  void getSettings() async {
    await Future.forEach(boolSettings.keys, (key) async {
      var value = await getSetting(key);
      setState(() {
        boolSettings[key] = value;
      });
    });

    await Future.forEach(intSettings.keys, (key) async {
      int value = await getIntSetting(key);
      setState(() {
        intSettings[key] = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData screenSize;
    screenSize = MediaQuery.of(context);
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: ThemeUtils.darken(Theme.of(context).primaryColorDark, forceAmount: 0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      contentPadding: EdgeInsets.only(top: 0.0),
      content: Container(
        height: screenSize.size.height / 10 * 7,
        width: screenSize.size.width / 5 * 4.7,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                color: ThemeUtils.darken(Theme.of(context).primaryColorDark, forceAmount: 0.12),
              ),
              height: screenSize.size.height / 10 * 2.8,
              width: screenSize.size.width / 5 * 4.7,
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.only(top: screenSize.size.height / 10 * 0.1),
                      child: Image(
                          width: screenSize.size.width / 5 * 4,
                          height: screenSize.size.height / 10 * 1.8,
                          fit: BoxFit.scaleDown,
                          image: AssetImage(
                              'assets/images/persistantNotification/persisIllu${isDarkModeEnabled ? "Dark" : "Light"}.png'))),
                  Container(
                    width: screenSize.size.width / 5 * 4.4,
                    child: AutoSizeText.rich(
                      TextSpan(
                        text: "Soyez averti des cours en cours grâce à une",
                        children: <TextSpan>[
                          TextSpan(
                              text: ' notification toujours présente', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' dans le panneau de contrôle de votre appareil.'),
                        ],
                      ),
                      style: TextStyle(color: ThemeUtils().theme["text"]["default"], fontFamily: "Asap"),
                    ),
                  )
                ],
              ),
            ),
            SwitchListTile(
              value: boolSettings["agendaOnGoingNotification"],
              title: Text("Activée",
                  style: TextStyle(
                      fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"], fontSize: screenSize.size.height / 10 * 0.21)),
              onChanged: (value) async {
                if ((await Permission.ignoreBatteryOptimizations.isGranted)) {
                  setState(() {
                    boolSettings["agendaOnGoingNotification"] = value;
                  });
                  await setSetting("agendaOnGoingNotification", value);
                  if (value) {
                    await LocalNotification.setOnGoingNotification();
                  } else {
                    await LocalNotification.cancelOnGoingNotification();
                  }
                } else {
                  if (await CustomDialogs.showAuthorizationsDialog(
                          context,
                          "la configuration d'optimisation de batterie",
                          "Pouvoir s'exécuter en arrière plan sans être automatiquement arrêté par Android.") ??
                      false) {
                    if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
                      setState(() {
                        boolSettings["agendaOnGoingNotification"] = value;
                      });
                      await setSetting("agendaOnGoingNotification", value);
                      if (value) {
                        await LocalNotification.setOnGoingNotification();
                      } else {
                        await LocalNotification.cancelOnGoingNotification();
                      }
                    }
                  }
                }
              },
              secondary: Icon(
                MdiIcons.power,
                color: ThemeUtils().theme["text"]["default"],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            SwitchListTile(
              value: boolSettings["enableDNDWhenOnGoingNotifEnabled"],
              title: Text("Activer le mode ne pas déranger à l'entrée en cours",
                  style: TextStyle(
                      fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"], fontSize: screenSize.size.height / 10 * 0.20)),
              onChanged: (value) async {
                setState(() {
                  boolSettings["enableDNDWhenOnGoingNotifEnabled"] = value;
                });
                if (value && (await getCurrentLesson(await localApi.getNextLessons(DateTime.now()))) != null) {
                  if (await FlutterDnd.isNotificationPolicyAccessGranted) {
                    await FlutterDnd.setInterruptionFilter(
                        FlutterDnd.INTERRUPTION_FILTER_NONE); // Turn on DND - All notifications are suppressed.
                  } else {
                    if (await CustomDialogs.showAuthorizationsDialog(context, "mode ne pas déranger",
                        "Allumer ou éteindre le mode ne pas déranger dans la journée.")) {
                      await FlutterDnd.gotoPolicySettings();
                    }
                  }
                }
                await setSetting("enableDNDWhenOnGoingNotifEnabled", value);
              },
              secondary: Icon(
                MdiIcons.moonWaningCrescent,
                color: ThemeUtils().theme["text"]["default"],
              ),
            ),
            SwitchListTile(
              value: boolSettings["disableAtDayEnd"],
              title: Text("Desactiver en fin de journée",
                  style: TextStyle(
                      fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"], fontSize: screenSize.size.height / 10 * 0.20)),
              onChanged: (value) async {
                setState(() {
                  boolSettings["disableAtDayEnd"] = value;
                });

                await setSetting("disableAtDayEnd", value);
              },
              secondary: Icon(
                MdiIcons.powerOff,
                color: ThemeUtils().theme["text"]["default"],
              ),
            ),
            ListTile(
              title: Text("Réparer les permissions",
                  style: TextStyle(
                      fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"], fontSize: screenSize.size.height / 10 * 0.21)),
              subtitle: Text(
                perm,
                style: TextStyle(
                    fontFamily: "Asap", color: ThemeUtils().theme["text"]["default"], fontSize: screenSize.size.height / 10 * 0.16),
              ),
              onTap: () async {
                if (!(await BatteryOptimization.isIgnoringBatteryOptimizations()) &&
                    await CustomDialogs.showAuthorizationsDialog(context, "la configuration d'optimisation de batterie",
                        "Pouvoir s'exécuter en arrière plan sans être automatiquement arrêté par Android.")) {
                  await BatteryOptimization.openBatteryOptimizationSettings();
                }
                await getAuth();
              },
              leading: Icon(
                MdiIcons.autoFix,
                color: ThemeUtils().theme["text"]["default"],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
