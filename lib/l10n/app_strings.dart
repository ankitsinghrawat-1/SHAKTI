/// App-wide localization strings supporting natural, human-friendly Hindi (हिन्दी) and English.
class AppStrings {
  final String lang;

  AppStrings(this.lang);

  bool get isHindi => lang.toLowerCase().startsWith('hi');

  // Navigation (4 Bottom Tabs)
  String get navHome => isHindi ? 'होम' : 'Home';
  String get navAlerts => isHindi ? 'अलर्ट' : 'Alerts';
  String get navBand => isHindi ? 'बैंड' : 'Band';
  String get navProfile => isHindi ? 'प्रोफ़ाइल' : 'Profile';
  String get navAssistant => isHindi ? 'सहायक' : 'Assistant';

  // Common & Reassurance
  String get appTitle => isHindi ? 'शक्ति - महिला सुरक्षा' : 'SHAKTI - Women Protective Network';
  String get brandSubtitle => isHindi ? 'आपकी सुरक्षा। आपका संबल।' : 'Your Safety. Your Strength.';
  String get encryptedNetwork => isHindi ? 'सुरक्षित नेटवर्क चालू' : 'Encrypted Network Active';
  String get dispatch112 => isHindi ? '112 आपातकालीन' : '112 DISPATCH';
  String get verified => isHindi ? 'सत्यापित' : 'Verified';
  String get prototypeBanner => isHindi
      ? 'प्रोटोटाइप डेमो: सिम्युलेटेड वातावरण। कोई वास्तविक आपातकालीन कॉल या जीपीएस नहीं भेजा जाता।'
      : 'PROTOTYPE DEMO: Simulated environment. No real emergency dispatches or GPS calls are made.';
  String get cancel => isHindi ? 'रद्द करें' : 'Cancel';
  String get save => isHindi ? 'सहेजें' : 'Save';
  String get back => isHindi ? 'वापस' : 'Back';
  String get done => isHindi ? 'संपन्न' : 'Done';
  String get confirm => isHindi ? 'पुष्टि करें' : 'Confirm';
  String get close => isHindi ? 'बंद करें' : 'Close';

  // Splash & Onboarding
  String get splashSecuring => isHindi ? 'सुरक्षा प्रणाली चालू हो रही है...' : 'Securing Cryptographic Enclave...';
  String get splashGateway => isHindi ? 'आपातकालीन नेटवर्क से जुड़ रहा है...' : 'Connecting Safety Network...';
  String get splashMesh => isHindi ? 'अभिभावक संपर्क तैयार हैं।' : 'Guardian Network Ready.';
  String get splashReady => isHindi ? 'प्रणाली तैयार और सुरक्षित।' : 'System Armed & Ready.';
  String get splashEnter => isHindi ? 'आगे बढ़ें' : 'Enter Shield';

  // Onboarding Slides (Natural, Human-Friendly Hindi)
  String get slide1Step => isHindi ? '01 / 03 • तत्काल मदद' : '01 / 03 • INSTANT RESPONSE';
  String get slide1Title => isHindi ? 'तुरंत एसओएस और मौन सतर्कता' : 'Instant SOS & Silent Triggers';
  String get slide1Desc => isHindi
      ? 'पावर बटन को 3 बार दबाएं या स्मार्ट बैंड पर टैप करें। आपके अभिभावकों को तुरंत आपकी लाइव लोकेशन मिल जाएगी।'
      : 'Triple-press power or wearable tap immediately deploys high-priority alerts with live location sharing.';
  String get pillPanic => isHindi ? 'वन-टच पैनिक' : 'One-Touch Panic';
  String get pillBand => isHindi ? 'स्मार्ट बैंड' : 'Smart Band';
  String get pillAudio => isHindi ? 'मौन ऑडियो' : 'Silent Audio Vault';

  String get slide2Step => isHindi ? '02 / 03 • सुरक्षित घेरा' : '02 / 03 • TRUSTED NETWORK';
  String get slide2Title => isHindi ? 'सक्रिय अभिभावक चक्र' : 'Live Guardian Network';
  String get slide2Desc => isHindi
      ? 'जरूरत पड़ने पर आपके चुने हुए परिवारजन और मित्र तुरंत आपकी सहायता के लिए तैयार रहते हैं।'
      : 'Automatically mirrors route telemetry with designated emergency contacts, battery status, and nearby verified responders.';
  String get pillMesh => isHindi ? 'सुरक्षित रूट' : 'Encrypted Route';
  String get pillTelemetry => isHindi ? 'लाइव बीकन' : 'Telemetry Beacon';
  String get pillCircle => isHindi ? '24/7 सुरक्षा' : 'Trusted Circle 24/7';

  String get slide3Step => isHindi ? '03 / 03 • समझदार मार्ग' : '03 / 03 • PREDICTIVE DEFENSE';
  String get slide3Title => isHindi ? 'सुरक्षा रडार और सुरक्षित रास्ते' : 'Safety Radar & Routes';
  String get slide3Desc => isHindi
      ? 'रोशन रास्तों, खुले प्रतिष्ठानों और नजदीकी सुरक्षित आश्रयों की जानकारी से सही रास्ता चुनें।'
      : 'Smart routing analyzes streetlight density, active public transport, and nearby open safe zones to route you safely.';
  String get pillLights => isHindi ? 'रोशन मार्ग' : 'Well-Lit Paths';
  String get pillAcoustic => isHindi ? 'ध्वनि सुरक्षा' : 'Acoustic Anomaly AI';

  // Authentication: Welcome, Registration, Login (Phases 2, 3, 5)
  String get welcomeTitle => isHindi ? 'शक्ति में आपका स्वागत है' : 'Welcome to SHAKTI';
  String get welcomeSubtitle => isHindi
      ? 'आपकी व्यक्तिगत सुरक्षा शील्ड। सुरक्षित रहें, सशक्त रहें।'
      : 'Your personal safety shield. Stay protected, connected, and strong.';
  String get createAccountBtn => isHindi ? 'नया खाता बनाएं' : 'Create New Account';
  String get alreadyHaveAccount => isHindi ? 'पहले से खाता है? साइन इन करें' : 'Already have an account? Sign In';
  String get dontHaveAccount => isHindi ? 'खाता नहीं है? नया खाता बनाएं' : "Don't have an account? Sign Up";

  // Login Screen (Returning User)
  String get signInTitle => isHindi ? 'साइन इन करें' : 'Sign In';
  String get signInSubtitle => isHindi
      ? 'अपनी सुरक्षा शील्ड अनलॉक करने के लिए विवरण दर्ज करें।'
      : 'Sign in to access your active safety network and emergency telemetry.';
  String get phoneOrShieldLabel => isHindi ? 'रजिस्टर्ड मोबाइल नंबर या शील्ड आईडी' : 'Registered Phone or Shield ID';
  String get securityPinLabel => isHindi ? '4-अंकीय सुरक्षा पिन' : '4-Digit Security PIN';
  String get forgotPin => isHindi ? 'पिन भूल गए?' : 'Forgot PIN?';
  String get signInBtn => isHindi ? 'साइन इन करें' : 'Sign In';
  String get duressNotice => isHindi
      ? 'खतरे या दबाव में हैं? गुप्त डिकॉय मोड खोलने और चुपचाप संपर्कों को सतर्क करने के लिए गुप्त पिन (0000) दर्ज करें।'
      : 'Under coercion? Enter your decoy Duress PIN (0000) to open camouflage screen while secretly alerting your trusted circle.';
  String get emergencyBypass => isHindi ? 'तत्काल खतरे में हैं? तुरंत एसओएस भेजें' : 'In Immediate Danger? Trigger instant emergency SOS';

  // Registration Screen (First-time User)
  String get signUpTitle => isHindi ? 'नया खाता बनाएं' : 'Create Account';
  String get signUpSubtitle => isHindi
      ? 'अपनी सुरक्षा प्रोफ़ाइल और 4-अंकीय मास्टर पिन सेट करें।'
      : 'Set up your personal safety profile and 4-digit master PIN.';
  String get fullNameLabel => isHindi ? 'पूरा नाम' : 'Full Name';
  String get mobileLabel => isHindi ? 'मोबाइल नंबर' : 'Mobile Number';
  String get emailLabel => isHindi ? 'ईमेल आईडी' : 'Email Address';
  String get createPinLabel => isHindi ? '4-अंकीय सुरक्षा पिन बनाएं' : 'Create 4-Digit Security PIN';
  String get confirmPinLabel => isHindi ? 'सुरक्षा पिन की पुष्टि करें' : 'Confirm 4-Digit PIN';
  String get pairBandCheckbox => isHindi ? 'स्मार्ट रिस्टबैंड V2 को अभी जोड़ें' : 'Pair SHAKTI Band V2 now';
  String get completeRegistrationBtn => isHindi ? 'खाता बनाएं और सुरक्षित करें' : 'Create Shield Account';

  // Logout
  String get logout => isHindi ? 'लॉग आउट' : 'Log Out';
  String get logoutConfirm => isHindi ? 'क्या आप वाकई सत्र से लॉग आउट करना चाहते हैं? दोबारा प्रवेश के लिए पिन आवश्यक होगा।' : 'Are you sure you want to log out? PIN will be required to re-authenticate.';

  // Home Dashboard
  String get greetingEvening => isHindi ? 'शुभ संध्या' : 'Good evening';
  String get greetingMorning => isHindi ? 'शुभ प्रभात' : 'Good morning';
  String get greetingAfternoon => isHindi ? 'शुभ दोपहर' : 'Good afternoon';
  String get statusProtected => isHindi ? 'सुरक्षित' : 'Protected';
  String get statusSafeTracking => isHindi ? 'सुरक्षित • ट्रैकिंग चालू' : 'Safe • Tracking on';
  String get systemsNominal => isHindi ? 'सभी प्रणालियां सामान्य' : 'Systems Nominal';
  String get silentReady => isHindi ? 'मौन सतर्कता तैयार' : 'Silent Dispatch Ready';
  String get actionWalk => isHindi ? 'साथ चलें' : 'Walk With Me';
  String get actionFakeCall => isHindi ? 'नकली कॉल' : 'Fake Call';
  String get actionSiren => isHindi ? 'सायरन' : 'Siren';
  String get actionCamo => isHindi ? 'कैमूफ्लाज' : 'Camouflage';
  String get sosHoldPrompt => isHindi ? 'मौन संकट अलर्ट के लिए 3 सेकंड दबाएं या 3 बार टैप करें' : 'Hold 3s or Tap 3x for Silent Distress';
  String get sosSlidePrompt => isHindi ? 'तुरंत भेजने के लिए स्लाइड करें' : 'Slide to dispatch immediately';
  String get sosModalTitle => isHindi ? 'एसओएस सक्रिय (डेमो)' : 'SOS TRIGGERED (DEMO)';
  String get sosModalMsg => isHindi ? '4 अभिभावकों और नजदीकी पुलिस इकाई को प्राथमिकता अलर्ट भेजा जा रहा है।' : 'Dispatching priority SMS with coordinates to your 4 guardians and nearby police unit.';
  String get sosCancelFalse => isHindi ? 'रद्द करें (गलती से दबा)' : 'Cancel (False Alarm)';
  String get bandStatus => isHindi ? 'बैंड V2' : 'Band V2';
  String get bandSynced => isHindi ? 'सक्रिय' : 'Active';
  String get guardiansActive => isHindi ? 'सक्रिय अभिभावक' : 'Guardians';
  String get directAlertRing => isHindi ? '4 सुरक्षा घेरे में' : '4 in alert ring';
  String get liveCoordinates => isHindi ? 'लाइव निर्देशांक (सिम्युलेटेड)' : 'LIVE COORDINATES (SIMULATED)';
  String get currentAddress => isHindi ? 'कनॉट प्लेस, इनर सर्कल' : 'Connaught Place, Inner Circle';
  String get precisionFix => isHindi ? '±2.5मी सटीक' : '±2.5m Fix';
  String get satelliteFix => isHindi ? 'जीपीएस कनेक्टेड' : 'GNSS Satellite Fix';
  String get radarTitle => isHindi ? 'रात्रि सुरक्षा रडार' : 'Night Safety Radar';
  String get radarClear => isHindi ? 'जोन 4 सुरक्षित' : 'Zone 4 Clear';
  String get radarDesc => isHindi
      ? 'बाराखंभा रोड पर अच्छी स्ट्रीटलाइट रोशनी। 250 मीटर के भीतर 3 खुले प्रतिष्ठान और 1 सुरक्षा चौकी।'
      : 'High street illumination verified along Barakhamba road. 3 open commercial establishments and 1 metro security post within 250m.';
  String get aiAssistantBtn => isHindi ? 'एआई सहायक' : 'AI Assistant';

  // App Settings (Phase 6 B)
  String get settingsTitle => isHindi ? 'ऐप सेटिंग्स' : 'App Settings';
  String get languageSettings => isHindi ? 'ऐप की भाषा' : 'App Language';
  String get notificationPrefs => isHindi ? 'सूचनाएं एवं अलर्ट' : 'Notification Preferences';
  String get privacySettings => isHindi ? 'गोपनीयता सेटिंग्स' : 'Privacy Preferences';
  String get locationSettings => isHindi ? 'लोकेशन प्राथमिकताएं' : 'Location Preferences';
  String get displaySettings => isHindi ? 'डिस्प्ले व थीम' : 'Display Preferences';
  String get permissionInfo => isHindi ? 'डिवाइस अनुमतियां' : 'App Permission Info';
  String get securitySettings => isHindi ? 'सुरक्षा एवं पिन सेटिंग्स' : 'Security Preferences';

  // Profile Screen
  String get profileTitle => isHindi ? 'प्रोफ़ाइल एवं सुरक्षा' : 'Profile & Security';
  String get editProfile => isHindi ? 'प्रोफ़ाइल संपादित करें' : 'Edit Profile';
  String get profileCompletion => isHindi ? 'प्रोफ़ाइल पूर्णता' : 'Profile Completion';
  String get guardiansShortcut => isHindi ? 'अभिभावक चक्र (4 संपर्क)' : 'Guardian Circle (4 Contacts)';
  String get medicalIdShortcut => isHindi ? 'आपातकालीन मेडिकल आईडी' : 'Emergency Medical ID';
  String get pinSettingsShortcut => isHindi ? 'सुरक्षा पिन एवं डुरेस सेटिंग्स' : 'Security PIN & Duress Settings';
  String get privacyInfo => isHindi ? 'गोपनीयता नीति' : 'Privacy Information';
  String get safetyDrillMode => isHindi ? 'सुरक्षा मॉक ड्रिल' : 'Safety Practice Drill';

  // Feature Screens
  String get alertsTitle => isHindi ? 'सुरक्षा अलर्ट और घटनाएं' : 'Safety Alerts & Incidents';
  String get assistantTitle => isHindi ? 'शक्ति एआई' : 'SHAKTI AI';
  String get assistantSubtitle => isHindi ? 'सुरक्षा साथी' : 'Safety Companion';
  String get assistantTagline => isHindi ? 'आपकी व्यक्तिगत सुरक्षा साथी' : 'Your Personal Safety Companion';
  String get assistantActive => isHindi ? 'सक्रिय' : 'Active';
  String get assistantHeroTitle => isHindi ? 'आज मैं आपकी क्या मदद कर सकती हूँ?' : 'How can I help you today?';
  String get assistantHeroSubtitle => isHindi
      ? 'सुरक्षा, सुरक्षित मार्ग, नजदीकी सहायता या शक्ति सुविधाओं के बारे में पूछें।'
      : 'Ask about safety, routes, nearby help or use SHAKTI features.';
  String get assistantChipRoute => isHindi ? 'क्या मेरा मार्ग सुरक्षित है?' : 'Is my route safe?';
  String get assistantChipJourney => isHindi ? 'सुरक्षित यात्रा की योजना बनाएं' : 'Help me plan a safe journey';
  String get assistantChipWalk => isHindi ? 'साथ चलें शुरू करें' : 'Start Walk With Me';
  String get assistantChipEmergency => isHindi ? 'आपात स्थिति में क्या करें?' : 'What should I do in an emergency?';
  String get assistantActionWalk => isHindi ? 'साथ चलें शुरू करें' : 'Start Walk With Me';
  String get assistantActionMap => isHindi ? 'नक्शे पर देखें' : 'View on Map';
  String get assistantPlaceholder => isHindi ? 'शक्ति से कुछ भी पूछें...' : 'Ask SHAKTI anything...';
  String get assistantPrototypeNotice => isHindi
      ? 'प्रोटोटाइप एआई: आपकी बातचीत केवल इस डिवाइस पर सुरक्षित रूप से चलती है।'
      : 'Prototype AI: Queries run locally inside mock safety companion.';
  String get bandHubTitle => isHindi ? 'स्मार्ट रिस्टबैंड V2 हब' : 'Smart Wristband V2 Hub';
  String get guardiansTitle => isHindi ? 'अभिभावक चक्र प्रबंधन' : 'Guardian Circle Network';
  String get radarScreenTitle => isHindi ? 'सुरक्षा रडार और सुरक्षित आश्रय' : 'Safety Radar & Havens';
  String get vaultTitle => isHindi ? 'डिजिटल साक्ष्य वॉल्ट' : 'Evidence Vault';

  // Band Screen Blueprint (Phase 10)
  String get bandArchitecture => isHindi ? 'हार्डवेयर वास्तुकला विनिर्देश' : 'Hardware Subsystem Architecture';
  String get controllerTitle => isHindi ? 'मुख्य नियंत्रक (ESP32-S3)' : 'Main Controller (ESP32-S3 Candidate)';
  String get controllerSub => isHindi ? 'ESP32-S3 / C3 आर्किटेक्चर (nRF52840 मूल्यांकन में)' : 'ESP32-S3/C3 architecture (nRF52840 under evaluation)';
  String get bleTitle => isHindi ? 'ब्लूटूथ लो एनर्जी' : 'Bluetooth Low Energy 5.x';
  String get lteTitle => isHindi ? 'सेल्युलर एलटीई मॉडेम' : 'Standalone Cellular LTE';
  String get gnssTitle => isHindi ? 'जीएनएसएस स्वतंत्र पोजीशनिंग' : 'Multi-Constellation GNSS';
  String get sosButtonTitle => isHindi ? 'टैक्टाइल एसओएस पैनिक बटन' : 'Tactile SOS Hardware Button';
  String get hapticTitle => isHindi ? 'हैप्टिक कंपन मोटर' : 'Haptic Vibration Feedback';
  String get powerTitle => isHindi ? 'सुरक्षित ली-पो बैटरी एवं फ्यूल गेज' : 'Protected Li-Po & Fuel Gauge';
  String get storageTitle => isHindi ? 'एनवीआरएएम घटना रिकॉर्ड कतार' : 'NVRAM Incident Queue';
  String get optionalImuTitle => isHindi ? 'वैकल्पिक 6-एक्सिस मोशन सेंसर' : 'Optional 6-Axis Motion IMU';
  String get futureSatelliteTitle => isHindi ? 'भविष्य का सैटेलाइट संचार' : 'Future Satellite Messaging Module';
  String get testHapticBtn => isHindi ? 'कंपन परीक्षण' : 'Test Vibration';
  String get findBandBtn => isHindi ? 'बैंड खोजें' : 'Find My Band';

  // Hazard Report Form (Phase 11)
  String get reportHazardTitle => isHindi ? 'सुरक्षा समस्या की रिपोर्ट करें' : 'Report Safety Hazard';
  String get hazardTypeLabel => isHindi ? 'समस्या का प्रकार' : 'Hazard Category';
  String get hazardLocationLabel => isHindi ? 'स्थान / लैंडमार्क' : 'Location / Landmark';
  String get hazardSeverityLabel => isHindi ? 'गंभीरता' : 'Severity';
  String get hazardNotesLabel => isHindi ? 'अतिरिक्त विवरण' : 'Additional Notes';
  String get submitHazardBtn => isHindi ? 'रिपोर्ट सबमिट करें' : 'Submit Hazard Report';
  String get hazardSavedNotice => isHindi ? 'रिपोर्ट स्थानीय रूप से दर्ज की गई।' : 'Hazard report logged in local prototype.';

  // Theme Settings (Section 6)
  String get themeTitle => isHindi ? 'ऐप का स्वरूप' : 'App Appearance';
  String get themeLight => isHindi ? 'लाइट मोड' : 'Light Mode';
  String get themeDark => isHindi ? 'डार्क मोड' : 'Dark Mode';
  String get themeSystem => isHindi ? 'सिस्टम डिफ़ॉल्ट' : 'System Default';

  // Band Onboarding (Section 2)
  String get bandOnboardTitle => isHindi ? 'शक्ति स्मार्ट बैंड सेटअप' : 'SHAKTI Band Onboarding';
  String get doYouHaveBand => isHindi ? 'क्या आपके पास शक्ति बैंड है?' : 'Do you have a SHAKTI Band?';
  String get haveBandYes => isHindi ? 'हाँ, मेरे पास शक्ति बैंड है' : 'Yes, I have a SHAKTI Band';
  String get haveBandNo => isHindi ? 'नहीं, मैं बिना बैंड के जारी रखूँगी' : "No, I'll continue without a band";
  String get pairingInstructions => isHindi
      ? 'बैंड का बटन 2 सेकंड तक दबाकर चालू करें और फोन का ब्लूटूथ ऑन रखें।'
      : 'Turn on your band by holding the tactile button for 2s and ensure Bluetooth is enabled on your phone.';
  String get startScanBtn => isHindi ? 'बैंड खोजें' : 'Search for Band';
  String get pairingSuccess => isHindi ? 'बैंड सफलतापूर्वक जुड़ गया!' : 'Band Paired Successfully!';
  String get skipPairingBtn => isHindi ? 'अभी छोड़ें' : 'Skip Pairing for Now';

  // App Tutorial (Section 3)
  String get tutorialTitle => isHindi ? 'ऐप उपयोग मार्गदर्शिका' : 'Interactive App Tour';
  String get tutorialNext => isHindi ? 'आगे' : 'Next';
  String get tutorialSkip => isHindi ? 'छोड़ें' : 'Skip';
  String get tutorialFinish => isHindi ? 'शुरू करें' : 'Get Started';
  String get replayTutorialBtn => isHindi ? 'ट्यूटोरियल दोबारा देखें' : 'Replay App Walkthrough';

  // Emergency Evidence & Sharing Settings (Section 4)
  String get emergencySettingsTitle => isHindi ? 'आपातकालीन साक्ष्य एवं शेयरिंग' : 'Emergency Evidence & Sharing';
  String get emergencyAudioLabel => isHindi ? 'आपातकालीन ऑडियो रिकॉर्डिंग' : 'Emergency Audio Recording';
  String get emergencyVideoLabel => isHindi ? 'आपातकालीन वीडियो रिकॉर्डिंग' : 'Emergency Video Recording';
  String get shareAudioLabel => isHindi ? 'अभिभावकों के साथ ऑडियो शेयर करें' : 'Share Audio with Guardians';
  String get shareVideoLabel => isHindi ? 'अभिभावकों के साथ वीडियो शेयर करें' : 'Share Video with Guardians';
  String get shareLocationLabel => isHindi ? 'लाइव लोकेशन और 1 घंटे का रूट शेयर करें' : 'Share Live Location & 1-Hr Route';
  String get shareBatteryLabel => isHindi ? 'बैटरी व डिवाइस स्थिति शेयर करें' : 'Share Device Battery & Status';
  String get emergencyCallLogsTitle => isHindi ? 'आपातकालीन कॉल लॉग' : 'Emergency Call History';

  // Feedback (Section 11)
  String get feedbackTitle => isHindi ? 'प्रतिक्रिया एवं सुझाव' : 'Help & App Feedback';
  String get ratingLabel => isHindi ? 'समग्र अनुभव' : 'Overall Experience';
  String get categoryLabel => isHindi ? 'श्रेणी' : 'Feedback Category';
  String get descriptionLabel => isHindi ? 'अपना अनुभव या समस्या लिखें' : 'Describe your feedback or bug';
  String get attachScreenshotLabel => isHindi ? 'स्क्रीनशॉट जोड़ें (वैकल्पिक)' : 'Attach Screenshot (Optional)';
  String get submitFeedbackBtn => isHindi ? 'प्रतिक्रिया भेजें' : 'Submit Feedback';

  // Dashboard Contextual Tooltips (Section 7)
  String get tooltipSos => isHindi ? 'अपने चुने हुए अभिभावकों को तत्काल आपातकालीन अलर्ट भेजें।' : 'Send an emergency alert to your selected guardians.';
  String get tooltipWalk => isHindi ? 'अपने अभिभावकों को वास्तविक समय में अपनी यात्रा ट्रैक करने दें।' : 'Let your guardians follow your journey in real time.';
  String get tooltipFakeCall => isHindi ? 'असहज स्थिति से निकलने के लिए एक नकली इनकमिंग कॉल शुरू करें।' : 'Trigger an incoming decoy phone call to exit uncomfortable situations.';
  String get tooltipSiren => isHindi ? 'आसपास के लोगों का ध्यान खींचने के लिए तेज सायरन बजाएं।' : 'Play a loud alert sound to attract immediate attention.';
  String get tooltipCamo => isHindi ? 'स्क्रीन पर गुप्त म्यूजिक प्लेयर इंटरफ़ेस खोलें।' : 'Open the configured discreet media player interface.';

  // Alerts & Notifications Preferences
  String get sosPushAlertsTitle => isHindi ? 'एसओएस प्राथमिकता पुश अलर्ट' : 'SOS Priority Push Alerts';
  String get sosPushAlertsDesc => isHindi ? "अभिभावकों के 'डू नॉट डिस्टर्ब' को अनदेखा करता है" : 'Bypasses Do Not Disturb on guardians';
  String get silentVibrationsTitle => isHindi ? 'मौन संकट पृष्ठभूमि कंपन' : 'Silent Distress Background Vibrations';
  String get silentVibrationsDesc => isHindi ? 'अलर्ट भेजने पर सूक्ष्म हैप्टिक कंपन' : 'Subtle haptic pulses on alert dispatch';
  String get guardianTelemetryTitle => isHindi ? 'अभिभावक लाइव टेलीमेट्री सिंक' : 'Guardian Live Telemetry Sync';
  String get guardianTelemetryDesc => isHindi ? 'बैटरी और सिग्नल समय-समय पर अपडेट करता है' : 'Updates battery and signal periodically';

  // Profile Screen Subtitles & Detail Labels
  String get appSettingsSub => isHindi ? 'भाषा, अलर्ट, जीपीएस व पिन प्रबंधन' : 'Language, Alerts, GPS, and PIN Management';
  String get guardiansSub => isHindi ? 'टियर 1 व टियर 2 संपर्क एवं लाइव स्थिति' : 'Tier 1 & Tier 2 contacts with live status';
  String get vaultSub => isHindi ? 'SHA-256 सीलबंद ऑडिट लॉग व ऑडियो मेमो' : 'SHA-256 sealed logs & acoustic memos';
  String get pinSettingsSub => isHindi ? 'मास्टर पिन एवं 0000 गुप्त डिकॉय पिन' : 'Master PIN & 0000 Duress Decoy PIN';
  String get emergencySettingsSub => isHindi ? 'ऑडियो, वीडियो, 1-घंटे का रूट व कॉल इतिहास सेटिंग्स' : 'Audio, video, 1-hr route, and call history settings';
  String get feedbackSub => isHindi ? 'रेटिंग, बग रिपोर्ट या नई सुविधा का सुझाव भेजें' : 'Submit rating, bug report, or feature suggestion';
  String get privacySub => isHindi ? 'ऑन-डिवाइस एन्क्लेव एवं सिमुलेशन विवरण' : 'On-device enclave & simulation parameters';
  String get bloodGroupPrefix => isHindi ? 'रक्त: ' : 'Blood: ';

  // Photo Attachment (Community Safety Reports)
  String get attachPhotoBtn => isHindi ? 'फोटो संलग्न करें' : 'Attach Photo';
  String get takePhotoCamera => isHindi ? 'कैमरा से फोटो लें' : 'Take a Photo (Camera)';
  String get chooseFromGallery => isHindi ? 'गैलरी से फोटो चुनें' : 'Choose from Gallery';
  String get removePhoto => isHindi ? 'फोटो हटाएं' : 'Remove Photo';
  String get replacePhoto => isHindi ? 'फोटो बदलें' : 'Replace Photo';
  String get photoAttachedLocal => isHindi ? 'फोटो स्थानीय रूप से संलग्न (प्रोटोटाइप)' : 'Photo Attached Locally (Prototype)';
  String get photoLocalNotice => isHindi
      ? 'फोटो स्थानीय रिपोर्ट मॉडल में संलग्न है। सर्वर अपलोड पृथक बैकएंड द्वारा प्रबंधित होगा।'
      : 'Photo attached to local report model. Ready for backend server sync.';
  String get photoCanceled => isHindi ? 'फोटो चयन रद्द किया गया।' : 'Photo selection cancelled.';
  String get photoPermissionDenied => isHindi ? 'कैमरा या गैलरी की अनुमति अस्वीकृत की गई।' : 'Camera or photo library permission was denied.';
  String get photoSizeExceeded => isHindi ? 'फोटो का आकार 10MB से अधिक नहीं होना चाहिए।' : 'Photo size must not exceed 10 MB.';

  // Feature 1: Permissions Onboarding & Management
  String get permissionsTitle => isHindi ? 'सुरक्षा अनुमतियाँ सेटअप' : 'Safety Permissions Setup';
  String get permissionsSubtitle => isHindi
      ? 'आपात स्थिति में आपकी सुरक्षा के लिए शक्ति को अनुमतियों की आवश्यकता है। हम हर अनुरोध को स्पष्ट समझाते हैं।'
      : 'SHAKTI needs explicit permissions to protect you during emergencies. We explain every request clearly.';
  String get permStatusGranted => isHindi ? 'स्वीकृत' : 'Granted';
  String get permStatusDenied => isHindi ? 'अस्वीकृत' : 'Denied';
  String get permStatusNotRequested => isHindi ? 'अनुरोध नहीं किया' : 'Not Requested';
  String get permStatusRestricted => isHindi ? 'प्लेटफ़ॉर्म द्वारा प्रतिबंधित' : 'Restricted by Platform';
  String get permActionEnable => isHindi ? 'अनुमति दें' : 'Grant Permission';
  String get permActionRetry => isHindi ? 'पुनः प्रयास' : 'Retry / Review';
  String get permActionContinue => isHindi ? 'शक्ति में आगे बढ़ें' : 'Continue to SHAKTI';
  String get permOptionalNotice => isHindi
      ? 'गैर-आवश्यक अनुमतियाँ बाद में सेटिंग्स में सक्षम की जा सकती हैं। आप अभी आगे बढ़ सकती हैं।'
      : 'Non-essential permissions can be reviewed or changed later in Settings. You can proceed safely.';

  String get permLocationTitle => isHindi ? 'लोकेशन अनुमति' : 'Location Access';
  String get permLocationDesc => isHindi
      ? 'एसओएस प्रेषण, साथ चलें, और लाइव अभिभावक ट्रैकिंग के लिए फ़ोन जीपीएस।'
      : 'Access phone GPS coordinates for SOS dispatch, Walk With Me, and live Guardian tracking.';
  String get permLocationWhy => isHindi
      ? 'प्रतिक्रियाकर्ताओं को सटीक निर्देशांक प्रदान करता है और आपातकाल में 1 घंटे का रूट इतिहास संकलित करता है।'
      : 'Provides precise coordinates to responders and compiles your 1-hour route history during emergencies.';

  String get permMicTitle => isHindi ? 'माइक्रोफ़ोन अनुमति' : 'Microphone Access';
  String get permMicDesc => isHindi
      ? 'एसओएस सक्रिय होने पर आपातकालीन परिवेशी ऑडियो साक्ष्य रिकॉर्ड करता है।'
      : 'Captures emergency ambient audio evidence when an SOS is activated.';
  String get permMicWhy => isHindi
      ? 'केवल सक्रिय एसओएस आपात स्थिति के दौरान रिकॉर्ड किया जाता है। कभी पृष्ठभूमि में गुप्त रूप से सक्रिय नहीं होता।'
      : 'Recorded solely during active SOS emergencies. Never secretly activated in the background.';

  String get permCameraTitle => isHindi ? 'कैमरा अनुमति' : 'Camera Access';
  String get permCameraDesc => isHindi
      ? 'एसओएस के दौरान फ्रंट और रियर कैमरे से आपातकालीन वीडियो साक्ष्य रिकॉर्ड करता है।'
      : 'Records emergency video evidence from front and rear cameras during SOS.';
  String get permCameraWhy => isHindi
      ? 'घटनाओं का दृश्य दस्तावेज़ीकरण आपकी रक्षा करता है और कानूनी सहायता हेतु साक्ष्य प्रदान करता है।'
      : 'Visual documentation of incidents protects you and provides tamper-proof evidence for legal support.';

  String get permNotifTitle => isHindi ? 'सूचनाएं (नोटिफिकेशन)' : 'Notifications';
  String get permNotifDesc => isHindi
      ? 'प्राथमिकता आपातकालीन स्थिति, अभिभावक चेक-इन, और सुरक्षा क्षेत्र अलर्ट प्रदान करता है।'
      : 'Delivers priority emergency status, Guardian check-ins, and safety zone alerts.';
  String get permNotifWhy => isHindi
      ? 'यह सुनिश्चित करता है कि जब फोन डू नॉट डिस्टर्ब में हो या स्क्रीन लॉक हो, तब भी आपको अलर्ट प्राप्त हों।'
      : 'Ensures you receive immediate alerts even when your phone is in Do Not Disturb or screen is locked.';

  String get permBleTitle => isHindi ? 'ब्लूटूथ लो एनर्जी' : 'Bluetooth Low Energy';
  String get permBleDesc => isHindi
      ? 'तत्काल हार्डवेयर बटन ट्रिगर के लिए आपके पहनने योग्य शक्ति बैंड V2 से जुड़ता है।'
      : 'Connects to your wearable SHAKTI Band V2 for instant tactile hardware button triggers.';
  String get permBleWhy => isHindi
      ? 'फोन को छुए या अनलॉक किए बिना कलाई से एक-क्लिक एसओएस की सुविधा देता है।'
      : 'Allows one-click SOS from your wrist without touching or unlocking your phone.';

  String get permPhotosTitle => isHindi ? 'फोटो एवं साक्ष्य एक्सेस' : 'Photo & Evidence Access';
  String get permPhotosDesc => isHindi
      ? 'सिस्टम फोटो पिकर के माध्यम से सामुदायिक सुरक्षा रिपोर्ट में फोटो जोड़ने के लिए उपयोग किया जाता है।'
      : 'Used when attaching hazard photos to community safety reports via system photo picker.';
  String get permPhotosWhy => isHindi
      ? 'पूर्ण फाइल सिस्टम एक्सेस मांगे बिना सुरक्षित प्लेटफ़ॉर्म फोटो पिकर का उपयोग करता है।'
      : 'Uses secure platform photo picker without requesting broad filesystem access.';

  String get permCallLogTitle => isHindi ? 'आपातकालीन कॉल इतिहास' : 'Emergency Call History';
  String get permCallLogDesc => isHindi
      ? 'मोबाइल ऑपरेटिंग सिस्टम द्वारा प्रतिबंधित। इसके स्थान पर सुरक्षित मैनुअल लॉगिंग प्रदान की जाती है।'
      : 'Restricted by mobile operating systems. Secure manual logging is provided instead.';
  String get permCallLogWhy => isHindi
      ? 'गोपनीयता के लिए एंड्रॉइड और आईओएस तीसरे पक्ष के ऐप को कॉल-लॉग पढ़ने की अनुमति नहीं देते।'
      : 'For privacy, Android and iOS restrict arbitrary third-party call-log reading.';

  // Feature 2: Emergency Evidence Recording
  String get evidenceRecordingTitle => isHindi ? 'आपातकालीन साक्ष्य रिकॉर्डिंग' : 'Emergency Evidence Recording';
  String get audioEvidenceCard => isHindi ? 'परिवेशी ऑडियो रिकॉर्डिंग' : 'Ambient Audio Recording';
  String get frontCameraCard => isHindi ? 'फ्रंट कैमरा रिकॉर्डिंग' : 'Front Camera Video';
  String get rearCameraCard => isHindi ? 'रियर कैमरा रिकॉर्डिंग' : 'Rear Camera Video';
  String get recStatusRecording => isHindi ? 'रिकॉर्डिंग चालू' : 'Recording Active';
  String get recStatusSaved => isHindi ? 'वॉल्ट में सुरक्षित' : 'Saved to Vault';
  String get recStatusPermRequired => isHindi ? 'अनुमति आवश्यक' : 'Permission Required';
  String get recStatusUnavailable => isHindi ? 'हार्डवेयर अनुपलब्ध' : 'Hardware Unavailable';
  String get recStatusFailed => isHindi ? 'रिकॉर्डिंग बाधित' : 'Recording Failed';
  String get recStatusStandby => isHindi ? 'स्टैंडबाय (टैप करके बदलें)' : 'Standby (Tap to Switch)';
  String get dualCameraNotice => isHindi
      ? 'इस डिवाइस पर एक साथ दोनों कैमरों से रिकॉर्डिंग समर्थित नहीं है। आप सक्रिय कैमरा बदल सकती हैं।'
      : 'Simultaneous dual-camera recording is unsupported by this device hardware. Active camera can be toggled.';
  String get viewInVaultBtn => isHindi ? 'वॉल्ट में साक्ष्य देखें' : 'View in Evidence Vault';

  // Feature 3: Live Location Tracking & 1-Hour Route History
  String get liveLocationSection => isHindi ? 'लाइव आपातकालीन लोकेशन' : 'Live Emergency GNSS Telemetry';
  String get locationTrackingActive => isHindi ? 'लाइव ट्रैकिंग सक्रिय (30s अंतराल)' : 'Live Tracking Active (30s interval)';
  String get locationOfflineQueued => isHindi ? 'ऑफलाइन • अपडेट स्थानीय रूप से कतारबद्ध' : 'Offline • Updates queued locally';
  String get locationPermissionDenied => isHindi
      ? 'लोकेशन अनुमति अस्वीकृत। वास्तविक समय के जीपीएस निर्देशांक अनुपलब्ध हैं।'
      : 'Location permission denied. Real-time GPS coordinates are unavailable.';
  String get routeHistorySection => isHindi ? 'पिछले 1 घंटे का लोकेशन इतिहास' : 'Previous 1-Hour Location History';
  String get routeHistoryUnavailable => isHindi
      ? 'पिछला लोकेशन इतिहास अनुपलब्ध है क्योंकि लोकेशन ट्रैकिंग सक्षम नहीं थी।'
      : 'Previous location history is unavailable because location tracking was not enabled.';
  String get routeHistoryDistinction => isHindi
      ? 'एसओएस सक्रियण से पहले दर्ज • लाइव लोकेशन से पृथक'
      : 'Recorded prior to SOS activation • Distinct from live location';
  String get routeCompleteBadge => isHindi ? 'रूट निरंतर' : 'Continuous Route';
  String get routeGapsBadge => isHindi ? 'अंतराल सहित' : 'Route with Gaps';

  // Feature 3: Guardian Location Sharing
  String get guardianDeliverySection => isHindi ? 'अभिभावक आपातकालीन प्रेषण' : 'Guardian Emergency Dispatch';
  String get deliveryPending => isHindi ? 'लंबित' : 'Pending';
  String get deliverySent => isHindi ? 'भेजा गया' : 'Sent';
  String get deliveryDelivered => isHindi ? 'वितरित' : 'Delivered';
  String get deliveryFailed => isHindi ? 'विफल' : 'Failed';
  String get whatsAppMockNotice => isHindi
      ? 'व्हाट्सएप बिजनेस एपीआई के लिए पंजीकृत मेटा क्रेडेंशियल आवश्यक हैं; प्रेषण स्थानीय रूप से सिम्युलेटेड है।'
      : 'WhatsApp Business API requires authorized Meta Business credentials; dispatch previewed locally.';
  String get liveMapLink => isHindi ? 'लाइव रूट मैप देखें' : 'View Live Route Map';

  // Feature 4: Emergency Call History
  String get callActivitySection => isHindi ? 'हालिया आपातकालीन कॉल गतिविधि' : 'Recent Emergency Call Activity';
  String get callPlatformRestricted => isHindi
      ? 'इस प्लेटफ़ॉर्म पर डिवाइस कॉल इतिहास उपलब्ध नहीं है।'
      : 'Device call history is not available on this platform.';
  String get manualCallLogTitle => isHindi ? 'मैनुअल आपातकालीन कॉल लॉग' : 'Manual Emergency Call Log';
  String get addManualCallBtn => isHindi ? 'आपातकालीन कॉल दर्ज करें' : 'Log Emergency Call';
  String get callNumberPrompt => isHindi ? 'डायल किया गया नंबर (उदा. 112, 1091, माँ)' : 'Dialed Number (e.g. 112, 1091, Mom)';
  String get callDurationPrompt => isHindi ? 'कॉल स्थिति / विवरण' : 'Call Status / Notes';
  String get callLoggedLocal => isHindi ? 'डिवाइस पर मैन्युअल रूप से दर्ज' : 'Logged manually on device';
}

