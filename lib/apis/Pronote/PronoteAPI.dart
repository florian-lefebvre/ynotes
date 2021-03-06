import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:requests/requests.dart';
import 'package:ynotes/classes.dart' as localapi;
import 'package:ynotes/main.dart';
import 'package:ynotes/models.dart';
import 'package:ynotes/apis/Pronote/PronoteCas.dart';
import 'package:ynotes/usefulMethods.dart';

import '../../classes.dart';
import '../EcoleDirecte.dart';
import '../utils.dart';

Map error_messages = {
  22: '[ERROR 22] The object was from a previous session. Please read the "Long Term Usage" section in README on github.',
  10: '[ERROR 10] Session has expired and pronotepy was not able to reinitialise the connection.'
};
bool isOldAPIUsed = false;

class Client {
  var username;
  var password;
  var pronote_url;
  _Communication communication;
  var attributes;
  var func_options;

  bool ent;

  _Encryption encryption;

  double _last_ping;

  DateTime date;

  DateTime start_day;

  var week;

  var localPeriods;

  bool _expired;

  var auth_response;

  bool logged_in;

  var auth_cookie;
  var paramsUser;

  DateTime hour_end;

  DateTime hour_start;

  int one_hour_duration;
  refresh() async {
    print("Reinitialisation");

    this.communication = _Communication(this.pronote_url, null, this);
    var future = await this.communication.initialise();
    this.attributes = future[0];
    this.func_options = future[1];
    this.encryption = _Encryption();
    this.encryption.aes_iv = this.communication.encryption.aes_iv;
    await this._login();
    this.localPeriods = null;
    this.localPeriods = this.periods();
    this.week = await get_week(DateTime.now());

    this.hour_start = DateFormat("""'hh'h'mm'""")
        .parse(this.func_options['donneesSec']['donnees']['General']['ListeHeures']['V'][0]['L']);
    this.hour_end = DateFormat("""'hh'h'mm'""")
        .parse(this.func_options['donneesSec']['donnees']['General']['ListeHeuresFin']['V'][0]['L']);

    this.one_hour_duration = hour_end.difference(hour_start).inMinutes;
    print("ohduration " + one_hour_duration.toString());

    this._expired = true;
  }

  Client(String pronote_url, {String username, String password, var cookies}) {
    if (cookies == null && password == null && username == null) {
      throw 'Please provide login credentials. Cookies are None, and username and password are empty.';
    }
    this.username = username;
    this.password = password;
    this.pronote_url = pronote_url;
    print("Initiate communication");

    this.communication = _Communication(pronote_url, cookies, this);
  }
  Future init() async {
    var attributesandfunctions = await this.communication.initialise();

    this.attributes = attributesandfunctions[0];
    this.func_options = attributesandfunctions[1];

    if (this.attributes["e"] != null && this.attributes["f"] != null) {
      print("LOGIN AS ENT");
      this.ent = true;
    } else {
      print("LOGIN AS REGULAR USER");
      this.ent = false;
    }
    //set up encryption
    this.encryption = _Encryption();
    this.encryption.aes_iv = this.communication.encryption.aes_iv;

    //some other attribute creation
    this._last_ping = DateTime.now().millisecondsSinceEpoch / 1000;
    this.auth_response = null;
    this.auth_cookie = null;
    this.date = DateTime.now();
    var inputFormat = DateFormat("dd/MM/yyyy");
    this.start_day = inputFormat.parse(this.func_options['donneesSec']['donnees']['General']['PremierLundi']['V']);
    final storage = new FlutterSecureStorage();
    await storage.write(key: "startday", value: this.start_day.toString());
    this.week = await get_week(DateTime.now());

    this.localPeriods = this.periods;
    this.logged_in = await this._login();

    this.hour_start =
        DateFormat("hh'h'mm").parse(this.func_options['donneesSec']['donnees']['General']['ListeHeures']['V'][0]['L']);
    this.hour_end = DateFormat("hh'h'mm")
        .parse(this.func_options['donneesSec']['donnees']['General']['ListeHeuresFin']['V'][0]['L']);

    this.one_hour_duration = hour_end.difference(hour_start).inMinutes;
    this._expired = false;
  }

  _login() async {
    try {
      final storage = new FlutterSecureStorage();
      await storage.write(key: "username", value: this.username);
      await storage.write(key: "password", value: this.password);
      await storage.write(key: "pronoteurl", value: this.pronote_url);
      print("Saved credentials");
    } catch (e) {
      print("failed to write values");
    }
    if (this.ent != null && this.ent) {
      this.username = this.attributes['e'];
      this.password = this.attributes['f'];
    }
    Map ident_json = {
      "genreConnexion": 0,
      "genreEspace": int.parse(this.attributes['a']),
      "identifiant": this.username,
      "pourENT": this.ent,
      "enConnexionAuto": false,
      "demandeConnexionAuto": false,
      "demandeConnexionAppliMobile": false,
      "demandeConnexionAppliMobileJeton": false,
      "uuidAppliMobile": "",
      "loginTokenSAV": ""
    };
    var idr = await this.communication.post("Identification", data: {'donnees': ident_json});
    print("Identification");

    var challenge = idr['donneesSec']['donnees']['challenge'];
    var e = _Encryption();
    e.aes_set_iv(this.communication.encryption.aes_iv);
    var motdepasse;

    if (this.ent != null && this.ent == true) {
      List<int> encoded = utf8.encode(this.password);
      motdepasse = sha256.convert(encoded).bytes;
      motdepasse = hex.encode(motdepasse);
      motdepasse = motdepasse.toString().toUpperCase();
      print("t");
      e.aes_key = md5.convert(utf8.encode(motdepasse));
    } else {
      var u = this.username;
      var p = this.password;

      //Convert credentials to lowercase if needed (API returns 1)
      if (idr['donneesSec']['donnees']['modeCompLog'] != null && idr['donneesSec']['donnees']['modeCompLog'] != 0) {
        print("LOWER CASE ID");
        print(idr['donneesSec']['donnees']['modeCompLog']);
        u = u.toString().toLowerCase();
      }

      if (idr['donneesSec']['donnees']['modeCompMdp'] != null && idr['donneesSec']['donnees']['modeCompMdp'] != 0) {
        print("LOWER CASE PASSWORD");
        print(idr['donneesSec']['donnees']['modeCompMdp']);
        p = p.toString().toLowerCase();
      }

      var alea = idr['donneesSec']['donnees']['alea'];
      List<int> encoded = utf8.encode(alea + p);
      motdepasse = sha256.convert(encoded);
      motdepasse = hex.encode(motdepasse.bytes);
      motdepasse = motdepasse.toString().toUpperCase();
      e.aes_key = md5.convert(utf8.encode(u + motdepasse));
    }

    var dec = e.aes_decrypt(hex.decode(challenge));

    var dec_no_alea = _enleverAlea(dec);
    var ch = e.aes_encrypt(utf8.encode(dec_no_alea));

    Map auth_json = {"connexion": 0, "challenge": ch, "espace": int.parse(this.attributes['a'])};
    try {
      print("Authentification");
      this.auth_response =
          await this.communication.post("Authentification", data: {'donnees': auth_json, 'identifiantNav': ''});
    } catch (e) {
      throw ("Error during auth" + e.toString());
    }

    try {
      if (this.auth_response['donneesSec']['donnees'].toString().contains("cle")) {
        await this.communication.after_auth(this.communication.last_response, this.auth_response, e.aes_key);
        if (isOldAPIUsed == false) {
          try {
            paramsUser = await this.communication.post("ParametresUtilisateur", data: {'donnees': {}});

            this.communication.authorized_onglets =
                _prepare_onglets(paramsUser['donneesSec']['donnees']['listeOnglets']);
            try {
              CreateStorage("classe", paramsUser['donneesSec']['donnees']['ressource']["classeDEleve"]["L"] ?? "");
              CreateStorage("userFullName", paramsUser['donneesSec']['donnees']['ressource']["L"] ?? "");
              actualUser = paramsUser['donneesSec']['donnees']['ressource']["L"];
            } catch (e) {
              print("Failed to register UserInfos");
              print(e);
            }
          } catch (e) {
            print("Surely using OLD API");
          }
        }

        print("Successfully logged in as ${this.username}");
        return true;
      } else {
        print("login failed");
        return false;
      }
    } catch (e) {
      throw ("Error during after auth " + e.toString());
    }
  }

  keep_alive() {
    return KeepAlive();
  }

  downloadUrl(localapi.Document document) {
    try {
      Map data = {"N": document.id, "G": int.parse(document.type)};
      //Used by pronote to encrypt the data (I don't know why)
      var magic_stuff = this.encryption.aes_encryptFromString(jsonEncode(data));
      String libelle = Uri.encodeComponent(Uri.encodeComponent(document.libelle));
      String url = this.communication.root_site +
          '/FichiersExternes/' +
          magic_stuff +
          '/' +
          libelle +
          '?Session=' +
          this.attributes['h'].toString();

      return url;
    } catch (e) {
      print(e);
    }
  }

  homework(DateTime date_from, {DateTime date_to}) async {
    print(date_from);
    if (date_to == null) {
      final f = new DateFormat('dd/MM/yyyy');
      date_to = f.parse(this.func_options['donneesSec']['donnees']['General']['DerniereDate']['V']);
    }
    var json_data = {
      'donnees': {
        'domaine': {'_T': 8, 'V': "[${await get_week(date_from)}..${await get_week(date_to)}]"}
      },
      '_Signature_': {'onglet': 88}
    };
    var response = await this.communication.post("PageCahierDeTexte", data: json_data);
    var json_data_contenu = {
      'donnees': {
        'domaine': {'_T': 8, 'V': "[${1}..${62}]"}
      },
      '_Signature_': {'onglet': 89}
    };
    //Get "Contenu de cours"
    var responseContent = await this.communication.post("PageCahierDeTexte", data: json_data_contenu);

    var c_list = responseContent['donneesSec']['donnees']['ListeCahierDeTextes']['V'];
    //Content homework
    List<localapi.Homework> listCHW = List();

    c_list.forEach((h) {
      List<localapi.Document> listDocs = List();
      //description
      String description = "";
      h["listeContenus"]["V"].forEach((value) {
        if (value["descriptif"]["V"] != null) {
          description += value["descriptif"]["V"] + "<br>";
        }
        try {
          value["ListePieceJointe"]["V"].forEach((pj) {
            try {
              downloadUrl(localapi.Document(pj["L"], pj["N"], pj["G"].toString(), 0));
            } catch (e) {}
          });
        } catch (e) {}
      });

      listCHW.add(localapi.Homework(
          h["Matiere"]["V"]["L"],
          h["Matiere"]["V"]["L"].hashCode.toString(),
          "",
          "",
          description,
          DateFormat("dd/MM/yyyy hh:mm:ss").parse(h["DateFin"]["V"]),
          DateFormat("dd/MM/yyyy hh:mm:ss").parse(h["Date"]["V"]),
          false,
          false,
          false,
          listDocs,
          listDocs,
          "",
          true));
    });

    //Homework(matiere, codeMatiere, idDevoir, contenu, contenuDeSeance, date, datePost, done, rendreEnLigne, interrogation, documents, documentsContenuDeSeance, nomProf)
    var h_list = response['donneesSec']['donnees']['ListeTravauxAFaire']['V'];
    List<localapi.Homework> listHW = List();
    h_list.forEach((h) {
      //set a generated ID (Pronote ID is never the same)
      String idDevoir =
          (DateFormat("dd/MM/yyyy").parse(h["PourLe"]["V"]).toString() + h["Matiere"]["V"]["L"]).hashCode.toString() +
              h["descriptif"]["V"].hashCode.toString();
      listHW.add(localapi.Homework(
          h["Matiere"]["V"]["L"],
          h["Matiere"]["V"]["L"].hashCode.toString(),
          idDevoir,
          h["descriptif"]["V"],
          null,
          DateFormat("dd/MM/yyyy").parse(h["PourLe"]["V"]),
          DateFormat("dd/MM/yyyy").parse(h["DonneLe"]["V"]),
          h["TAFFait"] ?? false,
          h["peuRendre"] ?? false,
          false,
          null,
          null,
          "",
          true));
    });
    listHW.forEach((homework) {
      try {
        homework.contenuDeSeance = listCHW
            .firstWhere((content) => content.codeMatiere == homework.codeMatiere && content.date == homework.date)
            .contenuDeSeance;
      } catch (e) {}
    });
    return listHW;
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  periods() {
    print("GETTING PERIODS");
    //printWrapped(this.func_options['donneesSec']['donnees'].toString());

    var json;
    try {
      json = this.func_options['donneesSec']['donnees']['General']['ListePeriodes'];
    } catch (e) {
      print("ERROR WHILE PARSING JSON " + e.toString());
    }

    List toReturn = List();
    json.forEach((j) {
      toReturn.add(PronotePeriod(this, j));
    });
    return toReturn;
  }

  polls() async {
    print("GETTING POLLS");
    Map data = {
      "_Signature_": {"onglet": 8},
    };
    var response = await this.communication.post('PageActualites', data: data);
    var listActus = response['donneesSec']['donnees']['listeActualites']["V"];
    List<PollInfo> listInfosPolls = List();
    listActus.forEach((element) {
      List<localapi.Document> documents = List();
      try {
        element["listePiecesJointes"]["V"].forEach((pj) {
          documents.add(localapi.Document(pj["L"], pj["N"], pj["G"], 0));
        });
      } catch (e) {}
      try {
        //PollInfo(this.auteur, this.datedebut, this.questions, this.read);

        List<String> questions = List();
        List<Map> choices = List();
        element["listeQuestions"]["V"].forEach((question) {
          questions.add(jsonEncode(question));
        });
        listInfosPolls.add(localapi.PollInfo(
            element["elmauteur"]["V"]["L"],
            DateFormat("dd/MM/yyyy").parse(element["dateDebut"]["V"]),
            questions,
            element["lue"],
            element["L"],
            element["N"],
            documents,
            element));
      } catch (e) {
        print("Failed to add an element to the polls list " + e.toString());
      }
    });
    return listInfosPolls;
  }

  setPollRead(String meta) async {
    var user = this.paramsUser['donneesSec']['donnees']['ressource'];
    print(user);
    List metas = meta.split("/");
    Map data = {
      "_Signature_": {"onglet": 8},
      "donnees": {
        "listeActualites": [
          {
            "genrePublic": 4,
            "L": metas[1],
            "validationDirecte": true,
            "saisieActualite": false,
            "lue": (metas[2] == "true"),
            "marqueLueSeulement": false,
            "N": metas[0],
            "public": {"G": user["G"], "L": user["L"], "N": user["N"]}
          }
        ],
        "saisieActualite": false
      }
    };
    print(data);
    var response = await this.communication.post('SaisieActualites', data: data);
    print(response);
  }

  setPollResponse(String meta) async {
    try {
      List metas = meta.split("/ynsplit");
      var user = this.paramsUser['donneesSec']['donnees']['ressource'];
      Map mapData = jsonDecode(metas[0]);
      Map pollMapData = jsonDecode(metas[1]);
      String answer = metas[2];

      mapData["reponse"]["V"]["valeurReponse"]["V"] = "[$answer]";
      mapData["reponse"]["V"]["_validationSaisie"] = true;
      Map data = {
        "_Signature_": {"onglet": 8},
        "donnees": {
          "listeActualites": [
            {
              "E": 2,
              "N": pollMapData["N"],
              "L": pollMapData["L"],
              "validationDirecte": true,
              "saisieActualite": false,
              "supprimee": false,
              "lue": (pollMapData["lue"] == "true"),
              "genrePublic": 4,
              "public": {"G": user["G"], "L": user["L"], "N": user["N"]},
              "listeQuestions": [
                //adding data
                mapData
              ]
            },
          ],
          "saisieActualite": false
        }
      };
      print(data);
      var response = await this.communication.post('SaisieActualites', data: data);
      print(response);
    } catch (e) {
      print(e);
    }
  }

  lessons(DateTime date_from, {DateTime date_to}) async {
    initializeDateFormatting();
    var user = this.paramsUser['donneesSec']['donnees']['ressource'];
    List<Lesson> listToReturn = List();
    Map data = {
      "_Signature_": {"onglet": 16},
      "donnees": {
        "ressource": user,
        "avecAbsencesEleve": false,
        "avecConseilDeClasse": true,
        "estEDTPermanence": false,
        "avecAbsencesRessource": true,
        "avecDisponibilites": true,
        "avecInfosPrefsGrille": true,
        "Ressource": user,
      }
    };

    var output = [];
    var first_week = await get_week(date_from);
    print(first_week);
    if (date_to == null) {
      date_to = date_from;
    }
    var last_week = await get_week(date_to);
    for (int week = first_week; week < last_week + 1; ++week) {
      data["donnees"]["NumeroSemaine"] = week;
      data["donnees"]["numeroSemaine"] = week;

      var response = await this.communication.post('PageEmploiDuTemps', data: data);

      var l_list = response['donneesSec']['donnees']['ListeCours'];
      l_list.forEach((lesson) {
        try {
          //Lesson(String room, List<String> teachers, DateTime start, int duration, bool canceled, String status, List<String> groups, String content, String matiere, String codeMatiere)
          String room;
          try {
            var roomContainer = lesson["ListeContenus"]["V"].firstWhere((element) => element["G"] == 17);
            room = roomContainer["L"];
          }
          //Sort of null aware
          catch (e) {}

          List<String> teachers = List();
          try {
            lesson["ListeContenus"]["V"].forEach((element) {
              if (element["G"] == 3) {
                teachers.add(element["L"]);
              }
            });
          } catch (e) {}

          DateTime start = DateFormat("dd/MM/yyyy HH:mm:ss", "fr_FR").parse(lesson["DateDuCours"]["V"]);
          DateTime end = start.add(Duration(minutes: this.one_hour_duration * lesson["duree"]));
          int duration = this.one_hour_duration * lesson["duree"];
          String matiere = lesson["ListeContenus"]["V"][0]["L"];
          String codeMatiere = lesson["ListeContenus"]["V"][0]["L"].hashCode.toString();
          String id = lesson["N"];
          String status;
          bool canceled = false;
          if (lesson["Statut"] != null) {
            status = lesson["Statut"];
          }
          if (lesson["estAnnule"] != null) {
            canceled = lesson["estAnnule"];
          }
          listToReturn.add(Lesson(
              room: room,
              teachers: teachers,
              start: start,
              end: end,
              duration: duration,
              canceled: canceled,
              status: status,
              matiere: matiere,
              id: id,
              codeMatiere: codeMatiere));
        } catch (e) {
          print("Error while getting lessons " + e.toString());
        }
      });
      print("Agenda collecte succeeded");
      return listToReturn;
    }
  }
}

_enleverAlea(String text) {
  List sansalea = List();
  int i = 0;
  text.runes.forEach((int rune) {
    var character = new String.fromCharCode(rune);
    if (i % 2 == 0) {
      sansalea.add(character);
    }
    i++;
  });

  return sansalea.join("");
}

class _Communication {
  var cookies;
  var client;
  var html_page;
  var root_site;
  var encryption;
  Map attributes;
  int request_number;
  List authorized_onglets;
  bool compress_requests;
  double last_ping;
  bool encrypt_requests;
  var last_response;
  Requests session;
  var requests;

  _Communication(String site, var cookies, var client) {
    this.root_site = this.get_root_address(site)[0];
    this.html_page = this.get_root_address(site)[1];

    this.encryption = _Encryption();
    this.attributes = {};
    this.request_number = 1;
    this.cookies = cookies;
    this.last_ping = 0;
    this.authorized_onglets = [];
    this.client = client;
    this.compress_requests = false;
    this.encrypt_requests = false;
    this.last_response = null;
  }

  Future<List<Object>> initialise() async {
    //some headers to be real

    print("Getting hostname");
    // get rsa keys and session id
    String hostName = Requests.getHostname(this.root_site + "/" + this.html_page);

    //set the cookies for ENT
    if (cookies != null) {
      print("Cookies set");
      Requests.setStoredCookies(hostName, this.cookies);
    }

    print(this.root_site + "/" + this.html_page);
    var headers = {
      'connection': 'keep-alive',
      'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) Gecko/20100101 Firefox/74.0'
    };

    var get_response = await Requests.get(this.root_site + "/" + this.html_page + (this.cookies != null ? "?fd=1" : ''),
            headers: headers)
        .catchError((e) {
      throw ("Impossible de se connecter");
    });

    if (get_response.hasError) {
      print("|pImpossible de se connecter à l'adresse fournie");
    }

    this.attributes = this._parse_html(get_response.content());
    print("test" + this.attributes['ER']);
    //uuid
    this.encryption.rsa_keys = {'MR': this.attributes['MR'], 'ER': this.attributes['ER']};

    var uuid = base64.encode(await this.encryption.rsa_encrypt(this.encryption.aes_iv_temp));
    //uuid
    var json_post = {'Uuid': uuid};
    this.encrypt_requests = (this.attributes["sCra"] != null ? !this.attributes["sCra"] : false);
    this.compress_requests = (this.attributes["sCra"] != null ? !this.attributes["sCoA"] : false);
    var initial_response = await this.post('FonctionParametres',
        data: {'donnees': json_post}, decryption_change: {'iv': md5.convert(this.encryption.aes_iv_temp).toString()});

    return [this.attributes, initial_response];
  }

  _parse_html(String html) {
    var parsed = parse(html);
    var onload = parsed.getElementById("id_body");

    String onload_c;
    print(onload);
    if (onload != null) {
      onload_c = onload.attributes["onload"].substring(14, onload.attributes["onload"].length - 37);
    } else {
      if (html.contains("IP")) {
        throw ('Your IP address is suspended.');
      } else {
        printWrapped(html.toString());
        throw ("Error with HTML PAGE");
      }
    }
    Map attributes = {};

    onload_c.split(',').forEach((attr) {
      var key = attr.split(':')[0];
      var value = attr.split(':')[1];
      attributes[key] = value.toString().replaceAll("'", "");
    });

    return attributes;
  }

  post(String function_name, {var data, bool recursive = false, var decryption_change = null}) async {
    if (data != null) {
      if (data["_Signature_"] != null &&
          !this.authorized_onglets.toString().contains(data['_Signature_']['onglet'].toString())) {
        throw ('Action not permitted. (onglet is not normally accessible)');
      }
    }
    if (this.compress_requests) {
      print("Compress request");
      data = utf8.encode(jsonEncode(data.toString()));
      data = hex.encode(data);
      var zlibInstance = ZLibCodec(level: 6);
      data = zlibInstance.encode(data).sublist(2, data.length - 4);
    }
    if (this.encrypt_requests) {
      print("Encrypt requests");
      if (data.runtimeType == Map) {
        data = utf8.encode(data.toString());
      }
      data = encryption.aes_encrypt(data).toUpperCase();
    }

    var r_number = encryption.aes_encrypt(utf8.encode(this.request_number.toString()));
    print(r_number);
    var json = {
      'session': int.parse(this.attributes['h']),
      'numeroOrdre': r_number,
      'nom': function_name,
      'donneesSec': data
    };
    String p_site =
        this.root_site + '/appelfonction/' + this.attributes['a'] + '/' + this.attributes['h'] + '/' + r_number;

    this.request_number += 2;
    if (request_number > 90) {
      await this.client.refresh();
    }

    var response = await Requests.post(p_site, json: json).catchError((onError) {
      print("Error occured during request : $onError");
    });

    this.last_ping = (DateTime.now().millisecondsSinceEpoch / 1000);
    this.last_response = response;
    if (response.hasError) {
      throw "Status code: ${response.statusCode}";
    }
    if (response.content().contains("Erreur")) {
      print("Error occured");
      print(response.content());
      var r_json = response.json();
      if (r_json["Erreur"]['G'] == 22) {
        throw error_messages["22"];
      }
      if (r_json["Erreur"]['G'] == 10) {
        tlogin.details = "Connexion expirée";
        tlogin.actualState = loginStatus.error;

        throw error_messages["10"];
      }
      if (recursive != null && recursive) {
        throw "Unknown error from pronote: ${r_json["Erreur"]["G"]} | ${r_json["Erreur"]["Titre"]}\n$r_json";
      }

      //await this.client.refresh();

      return await this.client.communication.post(function_name, data: data, recursive: true);
    }

    if (decryption_change != null) {
      print("decryption change");
      if (decryption_change.toString().contains("iv")) {
        print("decryption_change contains IV");
        print(decryption_change['iv']);
        this.encryption.aes_iv = IV.fromBase16(decryption_change['iv']);
      }

      if (decryption_change.toString().contains("key")) {
        print("decryption_change contains key");
        print(decryption_change['key']);
        this.encryption.aes_key = decryption_change['key'];
      }
    }

    Map response_data = response.json();

    if (this.encrypt_requests) {
      response_data['donneesSec'] = this.encryption.aes_decrypt(hex.decode(response_data['donneesSec']));
      print("décrypté données sec");
    }
    var zlibInstanceDecode = ZLibCodec(windowBits: 15);
    if (this.compress_requests) {
      response_data['donneesSec'] = zlibInstanceDecode.decode(response_data['donneesSec']);
    }
    if (response_data['donneesSec'].runtimeType == String) {
      try {
        response_data['donneesSec'] = jsonDecode(response_data['donneesSec']);
      } catch (e) {
        throw "JSONDecodeError";
      }
    }
    return response_data;
  }

  after_auth(var auth_response, var data, var auth_key) async {
    this.encryption.aes_key = auth_key;
    if (this.cookies == null) {
      var host = Requests.getHostname(auth_response.url.toString());
      this.cookies = await Requests.getStoredCookies(host);
    }

    var work = this.encryption.aes_decrypt(hex.decode(data['donneesSec']['donnees']['cle']));
    try {
      this.authorized_onglets = _prepare_onglets(data['donneesSec']['donnees']['listeOnglets']);

      CreateStorage("classe", data['donneesSec']['donnees']['ressource']["classeDEleve"]["L"]);
      CreateStorage("userFullName", data['donneesSec']['donnees']['ressource']["L"]);
      isOldAPIUsed = true;
    } catch (e) {
      isOldAPIUsed = false;
      print("Surely using the 2020 API");
    }
    var key = md5.convert(_enBytes(work));
    print("New key : $key");
    this.encryption.aes_key = key;
  }

  get_root_address(addr) {
    return [
      (addr.split('/').sublist(0, addr.split('/').length - 1).join("/")),
      (addr.split('/').sublist(addr.split('/').length - 1, addr.split('/').length).join("/"))
    ];
  }

  _enBytes(String string) {
    List<String> list_string = string.split(',');
    List<int> ints = list_string.map(int.parse).toList();
    return ints;
  }
}

_prepare_onglets(var list_of_onglets) {
  List output = List();
  if (list_of_onglets.runtimeType != List) {
    return [list_of_onglets];
  }
  list_of_onglets.forEach((item) {
    if (item.runtimeType == Map) {
      item = item.values();
    }
    output.add(item);
  });
  return output;
}

class _Encryption {
  var aes_iv;

  var aes_iv_temp;

  var aes_key;

  Map rsa_keys;

  _Encryption() {
    List<int> list = List();
    for (var i = 0; i < 16; i++) {
      var rng = new Random();
      list.add(rng.nextInt(255));
    }
    this.aes_iv = IV.fromBase16("00000000000000000000000000000000");

    this.aes_iv_temp = Uint8List.fromList(list);
    this.aes_key = generateMd5("");

    this.rsa_keys = {};
  }
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  aes_encrypt(List<int> data, {padding = true}) {
    var data2 = utf8.decode(data);
    var key = Key.fromBase16(this.aes_key.toString());
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: padding ? "PKCS7" : null));

    final encrypted = encrypter.encrypt(data2, iv: this.aes_iv).base16;

    return (encrypted);
  }

  aes_encryptFromString(String data) {
    var key = Key.fromBase16(this.aes_key.toString());
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: "PKCS7"));
    final encrypted = encrypter.encrypt(data, iv: this.aes_iv).base16;

    return (encrypted);
  }

  aes_decrypt(var data) {
    var key = Key.fromBase16(this.aes_key.toString());
    final aesEncrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: "PKCS7"));
    //generate AES CBC block encrypter with key and PKCS7 padding

    print(this.aes_iv);

    try {
      return aesEncrypter.decrypt64(base64.encode(data), iv: this.aes_iv);
    } catch (e) {
      throw ("Error during decryption : $e");
    }
  }

  aes_set_iv(var iv) {
    if (iv == null) {
      this.aes_iv = IV.fromLength(16);
    } else {
      this.aes_iv = iv;
    }
  }

  rsa_encrypt(var data) async {
    var modulusBytes = this.rsa_keys['MR'];
    var modulus = BigInt.parse(modulusBytes, radix: 16);
    var exponent = BigInt.parse(this.rsa_keys['ER'], radix: 16);
    var cipher = PKCS1Encoding(RSAEngine());
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(RSAPublicKey(modulus, exponent)));
    Uint8List output1 = cipher.process(aes_iv_temp);

    return output1;
  }

  _prepare_onglets(list_of_onglets) {
    var output = [];

    if (list_of_onglets.runtimeType != List) {
      return list_of_onglets;
    }

    for (var item in list_of_onglets) {
      if (item.runtimeType == Map) {
        item = item.values();

        return _prepare_onglets(item);
      }
    }
  }
}

class KeepAlive {
  _Communication _connection;

  bool keep_alive;

  void init(Client client) {
    this._connection = client.communication;
    this.keep_alive = true;
  }

  void alive() async {
    while (this.keep_alive) {
      if (DateTime.now().millisecondsSinceEpoch / 1000 - this._connection.last_ping >= 300) {
        this._connection.post("Presence", data: {
          '_Signature_': {'onglet': 7}
        });
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }
}

Uint8List int32BigEndianBytes(int value) => Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

class PronotePeriod {
  DateTime end;

  DateTime start;

  var name;

  var id;

  var moyenneGenerale;
  var moyenneGeneraleClasse;

  Client _client;

  // Represents a period of the school year. You shouldn't have to create this class manually.

  // Attributes
  // ----------
  // id : str
  //     the id of the period (used internally)
  // name : str
  //     name of the period
  // start : str
  //     date on which the period starts
  // end : str
  //     date on which the period ends

  PronotePeriod(Client client, Map parsed_json) {
    this._client = client;
    this.id = parsed_json['N'];
    this.name = parsed_json['L'];
    var inputFormat = DateFormat("dd/MM/yyyy");
    this.start = inputFormat.parse(parsed_json['dateDebut']['V']);
    this.end = inputFormat.parse(parsed_json['dateFin']['V']);
  }
  gradeTranslate(String value) {
    List grade_translate = [
      'Absent',
      'Dispensé',
      'Non noté',
      'Inapte',
      'Non rendu',
      'Absent zéro',
      'Non rendu zéro',
      'Félicitations'
    ];
    if (value.contains("|")) {
      return grade_translate[int.parse(value[1]) - 1];
    } else {
      return value;
    }
  }

  ///Return the eleve average, the max average, the min average, and the class average
  average(var json, var codeMatiere) {
    //The services for the period
    List services = json['donneesSec']['donnees']['listeServices']['V'];
    //The average data for the given matiere

    var averageData = services.firstWhere((element) => element["L"].hashCode.toString() == codeMatiere);
    //print(averageData["moyEleve"]["V"]);

    return [
      gradeTranslate(averageData["moyEleve"]["V"]),
      gradeTranslate(averageData["moyMax"]["V"]),
      gradeTranslate(averageData["moyMin"]["V"]),
      gradeTranslate(averageData["moyClasse"]["V"])
    ];
  }

  grades(int codePeriode) async {
    //Get grades from the period.
    List<Grade> list = List();
    var json_data = {
      'donnees': {
        'Periode': {'N': this.id, 'L': this.name}
      },
      "_Signature_": {"onglet": 198}
    };
    //Tests
    /*var a = await Requests.get("http://demo2235921.mockable.io/2");
    var response = a.json();*/
    var response = await _client.communication.post('DernieresNotes', data: json_data);
    var grades = response['donneesSec']['donnees']['listeDevoirs']['V'];
    this.moyenneGenerale = gradeTranslate(response['donneesSec']['donnees']['moyGenerale']['V']);
    this.moyenneGeneraleClasse = gradeTranslate(response['donneesSec']['donnees']['moyGeneraleClasse']['V']);

    var other = List();
    grades.forEach((element) async {
      list.add(Grade(
          valeur: this.gradeTranslate(element["note"]["V"]),
          devoir: element["commentaire"],
          codePeriode: this.id,
          nomPeriode: this.name,
          codeMatiere: element["service"]["V"]["L"].hashCode.toString(),
          codeSousMatiere: null,
          libelleMatiere: element["service"]["V"]["L"],
          letters: element["note"]["V"].contains("|"),
          coef: element["coefficient"].toString(),
          noteSur: element["bareme"]["V"],
          min: this.gradeTranslate(element["noteMin"]["V"]),
          max: this.gradeTranslate(element["noteMax"]["V"]),
          moyenneClasse: this.gradeTranslate(element["moyenne"]["V"]),
          date: DateFormat("dd/MM/yyyy").parse(element["date"]["V"]),
          nonSignificatif: this.gradeTranslate(element["note"]["V"]) == "NonNote" ? true : false,
          typeDevoir: "Interrogation",
          dateSaisie: DateFormat("dd/MM/yyyy").parse(element["date"]["V"])));
      other.add(average(response, element["service"]["V"]["L"].hashCode.toString()));
    });
    return [list, other];
  }
}

class PronoteLesson {
  String id;
  String teacher_name;
  String classroom;
  bool canceled;
  String status;
  String background_color;
  String outing;
  DateTime start;
  String group_name;
  var _content;
  Client _client;
  PronoteLesson(Client client, var parsed_json) {
    this._client = client;
    this._content = null;
  }
}
