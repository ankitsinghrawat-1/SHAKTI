import 'package:flutter/foundation.dart';

/// Supported SHAKTI Safety Permission Types
enum SafetyPermissionType {
  location,
  microphone,
  camera,
  notifications,
  bluetooth,
  photoPicker,
  callLog,
}

/// Status of an OS permission
enum PermissionStatusState {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
  restrictedByPlatform,
}

/// Representation of a permission with safety explanation and current state
class SafetyPermissionItem {
  final SafetyPermissionType type;
  PermissionStatusState status;
  final bool isMandatory;
  final String titleEn;
  final String titleHi;
  final String descEn;
  final String descHi;
  final String whyNeededEn;
  final String whyNeededHi;
  final String? platformLimitationEn;
  final String? platformLimitationHi;

  SafetyPermissionItem({
    required this.type,
    this.status = PermissionStatusState.notRequested,
    this.isMandatory = false,
    required this.titleEn,
    required this.titleHi,
    required this.descEn,
    required this.descHi,
    required this.whyNeededEn,
    required this.whyNeededHi,
    this.platformLimitationEn,
    this.platformLimitationHi,
  });

  bool get isGranted => status == PermissionStatusState.granted;
  bool get isDenied => status == PermissionStatusState.denied || status == PermissionStatusState.permanentlyDenied;
  bool get isRestricted => status == PermissionStatusState.restrictedByPlatform;
}

/// Clean service interface for managing permissions across Web prototype and native OS
class PermissionService extends ChangeNotifier {
  final Map<SafetyPermissionType, SafetyPermissionItem> _permissions = {};

  PermissionService() {
    _initDefaultPermissions();
  }

  void _initDefaultPermissions() {
    _permissions[SafetyPermissionType.location] = SafetyPermissionItem(
      type: SafetyPermissionType.location,
      status: PermissionStatusState.granted, // Default granted in prototype
      isMandatory: true,
      titleEn: 'Location Access (GNSS)',
      titleHi: 'लोकेशन अनुमति (जीपीएस)',
      descEn: 'Used for real-time SOS beacon dispatch, Walk With Me journey monitoring, and 1-hour route tracking.',
      descHi: 'एसओएस बीकन प्रेषण, वॉक विद मी यात्रा और 1 घंटे के रूट इतिहास के लिए उपयोग किया जाता है।',
      whyNeededEn: 'During emergencies, live coordinates are shared continuously with your trusted Guardians and 112 dispatch.',
      whyNeededHi: 'आपात स्थिति के दौरान लाइव निर्देशांक आपके विश्वसनीय अभिभावकों और 112 नियंत्रण कक्ष से साझा होते हैं।',
      platformLimitationEn: kIsWeb ? 'Web prototype uses browser geolocation API. Background location requires native Android/iOS service.' : null,
      platformLimitationHi: kIsWeb ? 'वेब प्रोटोटाइप ब्राउज़र जियोलोकेशन का उपयोग करता है। बैकग्राउंड लोकेशन के लिए नेटिव सर्विस आवश्यक है।' : null,
    );

    _permissions[SafetyPermissionType.microphone] = SafetyPermissionItem(
      type: SafetyPermissionType.microphone,
      status: PermissionStatusState.granted,
      isMandatory: false,
      titleEn: 'Microphone Access',
      titleHi: 'माइक्रोफ़ोन अनुमति',
      descEn: 'Captures emergency ambient audio evidence when an SOS is activated.',
      descHi: 'एसओएस सक्रिय होने पर आपातकालीन परिवेशी ऑडियो साक्ष्य रिकॉर्ड करता है।',
      whyNeededEn: 'Recorded strictly during active SOS distress events. Never secretly activated in the background without user consent.',
      whyNeededHi: 'केवल सक्रिय एसओएस आपात स्थिति के दौरान रिकॉर्ड होता है। बिना सहमति कभी पृष्ठभूमि में सक्रिय नहीं होता।',
      platformLimitationEn: kIsWeb ? 'In browser, microphone capture requires active tab focus and user permission prompt.' : null,
      platformLimitationHi: kIsWeb ? 'ब्राउज़र में सक्रिय टैब और अनुमति आवश्यक है।' : null,
    );

    _permissions[SafetyPermissionType.camera] = SafetyPermissionItem(
      type: SafetyPermissionType.camera,
      status: PermissionStatusState.granted,
      isMandatory: false,
      titleEn: 'Camera Access (Front & Rear)',
      titleHi: 'कैमरा अनुमति (फ्रंट एवं रियर)',
      descEn: 'Records emergency video evidence from front and rear cameras during SOS.',
      descHi: 'एसओएस के दौरान फ्रंट और रियर कैमरे से आपातकालीन वीडियो साक्ष्य रिकॉर्ड करता है।',
      whyNeededEn: 'Provides visual proof and tamper-proof evidence saved directly to your encrypted Evidence Vault.',
      whyNeededHi: 'दृश्य प्रमाण प्रदान करता है जो आपके एन्क्रिप्टेड एविडेंस वॉल्ट में सुरक्षित होता है।',
      platformLimitationEn: 'Note: Simultaneous front and rear camera recording is hardware-dependent. Sequential camera switching fallback is provided.',
      platformLimitationHi: 'नोट: दोनों कैमरों से एक साथ रिकॉर्डिंग हार्डवेयर पर निर्भर है। सक्रिय कैमरा स्विचिंग विकल्प उपलब्ध है।',
    );

    _permissions[SafetyPermissionType.notifications] = SafetyPermissionItem(
      type: SafetyPermissionType.notifications,
      status: PermissionStatusState.granted,
      isMandatory: false,
      titleEn: 'High-Priority Notifications',
      titleHi: 'उच्च-प्राथमिकता सूचनाएं',
      descEn: 'Bypasses Do Not Disturb on guardians and displays active SOS dispatch status.',
      descHi: 'अभिभावकों के डू नॉट डिस्टर्ब को अनदेखा करता है और एसओएस प्रेषण स्थिति दिखाता है।',
      whyNeededEn: 'Ensures life-saving alerts and guardian proximity pings reach you and your circle instantly.',
      whyNeededHi: 'यह सुनिश्चित करता है कि जीवन-रक्षक अलर्ट तुरंत आप तक और आपके अभिभावकों तक पहुंचें।',
    );

    _permissions[SafetyPermissionType.bluetooth] = SafetyPermissionItem(
      type: SafetyPermissionType.bluetooth,
      status: PermissionStatusState.granted,
      isMandatory: false,
      titleEn: 'Bluetooth Low Energy (BLE)',
      titleHi: 'ब्लूटूथ लो एनर्जी (BLE)',
      descEn: 'Connects to your wearable SHAKTI Band V2 for instant tactile hardware button triggers.',
      descHi: 'तत्काल हार्डवेयर बटन ट्रिगर के लिए आपके पहनने योग्य शक्ति बैंड V2 से जुड़ता है।',
      whyNeededEn: 'Allows one-click SOS from your wrist without touching or unlocking your phone.',
      whyNeededHi: 'फोन को छुए या अनलॉक किए बिना कलाई से एक-क्लिक एसओएस की सुविधा देता है।',
      platformLimitationEn: kIsWeb ? 'Web Bluetooth API has limited browser support. Native BLE is used on Android/iOS.' : null,
      platformLimitationHi: kIsWeb ? 'वेब ब्लूटूथ सीमित है। एंड्रॉइड/आईओएस पर नेटिव बीएलई समर्थित है।' : null,
    );

    _permissions[SafetyPermissionType.photoPicker] = SafetyPermissionItem(
      type: SafetyPermissionType.photoPicker,
      status: PermissionStatusState.granted,
      isMandatory: false,
      titleEn: 'Photo & File Evidence Access',
      titleHi: 'फोटो एवं साक्ष्य एक्सेस',
      descEn: 'Allows attaching incident photos to community safety reports via system photo picker.',
      descHi: 'सिस्टम फोटो पिकर के माध्यम से सामुदायिक सुरक्षा रिपोर्ट में फोटो जोड़ने की सुविधा।',
      whyNeededEn: 'Uses secure platform photo picker without requesting broad device filesystem access.',
      whyNeededHi: 'पूर्ण डिवाइस स्टोरेज एक्सेस मांगे बिना सुरक्षित प्लेटफ़ॉर्म फोटो पिकर का उपयोग करता है।',
    );

    _permissions[SafetyPermissionType.callLog] = SafetyPermissionItem(
      type: SafetyPermissionType.callLog,
      status: PermissionStatusState.restrictedByPlatform,
      isMandatory: false,
      titleEn: 'Device Call History',
      titleHi: 'डिवाइस कॉल इतिहास',
      descEn: 'Restricted by mobile operating systems. Manual emergency call logging is provided instead.',
      descHi: 'मोबाइल ऑपरेटिंग सिस्टम द्वारा प्रतिबंधित। इसके स्थान पर मैनुअल कॉल लॉगिंग उपलब्ध है।',
      whyNeededEn: 'Android and iOS policies strictly restrict third-party apps from reading general call logs for user privacy.',
      whyNeededHi: 'गोपनीयता हेतु एंड्रॉइड और आईओएस तीसरे पक्ष के ऐप को कॉल लॉग पढ़ने की अनुमति नहीं देते।',
      platformLimitationEn: 'Restricted by OS policy: Android requires Google Play Call Log exception approval. iOS completely disallows reading cellular call logs.',
      platformLimitationHi: 'ओएस नीति प्रतिबंध: एंड्रॉइड पर गूगल प्ले स्वीकृति आवश्यक; आईओएस कॉल लॉग पढ़ने की अनुमति नहीं देता।',
    );
  }

  Map<SafetyPermissionType, SafetyPermissionItem> get allPermissions => Map.unmodifiable(_permissions);

  SafetyPermissionItem? getPermission(SafetyPermissionType type) => _permissions[type];

  bool isGranted(SafetyPermissionType type) => _permissions[type]?.isGranted ?? false;

  bool isDenied(SafetyPermissionType type) => _permissions[type]?.isDenied ?? false;

  void grantPermission(SafetyPermissionType type) {
    if (_permissions.containsKey(type)) {
      if (type == SafetyPermissionType.callLog) {
        // Call log is restricted by OS policy on Web/iOS/general Android
        _permissions[type]!.status = PermissionStatusState.restrictedByPlatform;
      } else {
        _permissions[type]!.status = PermissionStatusState.granted;
      }
      notifyListeners();
    }
  }

  void setPermission(SafetyPermissionType type, PermissionStatusState status) {
    if (_permissions.containsKey(type)) {
      _permissions[type]!.status = status;
      notifyListeners();
    }
  }

  void denyPermission(SafetyPermissionType type, {bool permanently = false}) {
    if (_permissions.containsKey(type)) {
      _permissions[type]!.status =
          permanently ? PermissionStatusState.permanentlyDenied : PermissionStatusState.denied;
      notifyListeners();
    }
  }

  void togglePermission(SafetyPermissionType type) {
    if (_permissions.containsKey(type)) {
      if (_permissions[type]!.status == PermissionStatusState.granted) {
        denyPermission(type);
      } else {
        grantPermission(type);
      }
    }
  }
}
