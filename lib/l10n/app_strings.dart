// lib/l10n/app_strings.dart

class AppStrings {
  final String locale;
  const AppStrings(this.locale);

  bool get isFr => locale == 'fr';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  String get onboardingSkip        => isFr ? 'Passer'       : 'Skip';
  String get onboardingNext        => isFr ? 'Suivant'      : 'Next';
  String get onboardingStart       => isFr ? 'Commencer →'  : 'Get Started →';

  String get onboarding1Title      => isFr ? 'Scannez le QR Code'          : 'Scan the QR Code';
  String get onboarding1Desc       => isFr
      ? 'Utilisez l\'appareil photo de votre téléphone pour scanner le QR code VeriScan sur l\'emballage du produit. Rapide, simple et instantané.'
      : 'Use your phone camera to scan the VeriScan QR code on the product packaging. Fast, simple and instant.';

  String get onboarding2Title      => isFr ? 'Vérifiez l\'Authenticité'    : 'Verify Authenticity';
  String get onboarding2Desc       => isFr
      ? 'Obtenez instantanément le résultat :\n🟢 Vert = Produit authentique\n🟡 Jaune = Produit suspect\n🔴 Rouge = Produit contrefait\nAvec toutes les infos du fabricant.'
      : 'Get the result instantly:\n🟢 Green = Authentic product\n🟡 Yellow = Suspicious product\n🔴 Red = Counterfeit product\nWith all manufacturer details.';

  String get onboarding3Title      => isFr ? 'Signalez les Contrefaçons'   : 'Report Counterfeits';
  String get onboarding3Desc       => isFr
      ? 'Vous suspectez un produit contrefait ? Photographiez-le et signalez-le directement depuis l\'app. Le fabricant et l\'administrateur seront alertés immédiatement.'
      : 'Suspect a counterfeit product? Photograph it and report it directly from the app. The manufacturer and administrator will be alerted immediately.';

  // ── Auth — Login ───────────────────────────────────────────────────────────
  String get antiCounterfeit       => isFr ? 'Anti-contrefaçon au Cameroun' : 'Anti-counterfeiting in Cameroon';
  String get loginTitle            => isFr ? 'Connexion'                    : 'Sign In';
  String get loginSubtitle         => isFr ? 'Connectez-vous pour continuer': 'Sign in to continue';
  String get emailLabel            => isFr ? 'Adresse email'                : 'Email address';
  String get emailHint             => isFr ? 'hermannchoffo05@gmail.com'    : 'hermannchoffo05@gmail.com';
  String get passwordLabel         => isFr ? 'Mot de passe'                 : 'Password';
  String get forgotPassword        => isFr ? 'Mot de passe oublié ?'        : 'Forgot password?';
  String get loginButton           => isFr ? 'Se connecter'                 : 'Sign in';
  String get orLoginWith           => isFr ? 'Ou se connecter avec'         : 'Or sign in with';
  String get noAccount             => isFr ? 'Pas encore de compte ? '      : 'No account yet? ';
  String get register              => isFr ? 'S\'inscrire'                  : 'Sign up';
  String get emailRequired         => isFr ? 'Veuillez entrer votre email'  : 'Please enter your email';
  String get emailInvalid          => isFr ? 'Email invalide'               : 'Invalid email';
  String get passwordRequired      => isFr ? 'Veuillez entrer votre mot de passe' : 'Please enter your password';
  String get passwordMin           => isFr ? 'Minimum 6 caractères'         : 'Minimum 6 characters';
  String get errorGoogle           => isFr ? 'Erreur Google'                : 'Google error';
  String get errorFacebook         => isFr ? 'Erreur Facebook'              : 'Facebook error';
  String get unknownError          => isFr ? 'Erreur inconnue'              : 'Unknown error';

  // ── Auth — Register ────────────────────────────────────────────────────────
  String get registerTitle         => isFr ? 'Créer un compte'              : 'Create account';
  String get registerSubtitle      => isFr ? 'Rejoignez VeriScan'           : 'Join VeriScan';
  String get nameLabel             => isFr ? 'Nom complet'                  : 'Full name';
  String get nameHint              => isFr ? 'Jean Dupont'                  : 'John Doe';
  String get nameRequired          => isFr ? 'Veuillez entrer votre nom'    : 'Please enter your name';
  String get confirmPassword       => isFr ? 'Confirmer le mot de passe'    : 'Confirm password';
  String get passwordMismatch      => isFr ? 'Les mots de passe ne correspondent pas' : 'Passwords do not match';
  String get registerButton        => isFr ? 'S\'inscrire'                  : 'Sign up';
  String get alreadyAccount        => isFr ? 'Déjà un compte ? '            : 'Already have an account? ';
  String get signIn                => isFr ? 'Se connecter'                 : 'Sign in';

  // ── Auth — Forgot / Reset ──────────────────────────────────────────────────
  String get forgotTitle           => isFr ? 'Mot de passe oublié'          : 'Forgot password';
  String get forgotSubtitle        => isFr ? 'Entrez votre email pour recevoir un code de réinitialisation' : 'Enter your email to receive a reset code';
  String get sendCode              => isFr ? 'Envoyer le code'              : 'Send code';
  String get resetTitle            => isFr ? 'Nouveau mot de passe'         : 'New password';
  String get resetButton           => isFr ? 'Réinitialiser'                : 'Reset';
  String get verifyCodeTitle       => isFr ? 'Vérification'                 : 'Verification';
  String get verifyCodeSubtitle    => isFr ? 'Entrez le code reçu par email': 'Enter the code received by email';
  String get verifyButton          => isFr ? 'Vérifier'                     : 'Verify';
  String get resendCode            => isFr ? 'Renvoyer le code'             : 'Resend code';

  // ── Navigation ─────────────────────────────────────────────────────────────
  String get navHome               => isFr ? 'Accueil'   : 'Home';
  String get navScan               => isFr ? 'Scanner'   : 'Scan';
  String get navProfile            => isFr ? 'Profil'    : 'Profile';

  // ── Home / Dashboard ───────────────────────────────────────────────────────
  String get homeGreeting          => isFr ? 'Bonjour,'           : 'Hello,';
  String get homeSubtitle          => isFr ? 'Protégez-vous des contrefaçons' : 'Protect yourself from counterfeits';
  String get homeScanBtn           => isFr ? 'Scanner un produit' : 'Scan a product';
  String get homeRecentScans       => isFr ? 'Derniers scans'     : 'Recent scans';
  String get homeNoScans           => isFr ? 'Aucun scan récent'  : 'No recent scans';
  String get homeAuthentic         => isFr ? 'Authentique'        : 'Authentic';
  String get homeSuspect           => isFr ? 'Suspect'            : 'Suspect';
  String get homeCounterfeit       => isFr ? 'Contrefait'         : 'Counterfeit';
  String get homeViewAll           => isFr ? 'Voir tout'          : 'View all';
  String get homeQuickActions      => isFr ? 'Actions rapides'    : 'Quick actions';
  String get homeReport            => isFr ? 'Signaler'           : 'Report';
  String get homeHistory           => isFr ? 'Historique'         : 'History';
  String get homeAssistant         => isFr ? 'Assistant'          : 'Assistant';
  String get homeHelp              => isFr ? 'Aide'               : 'Help';
  String get homeSearch            => isFr ? 'Rechercher'         : 'Search';
  String get homeNotifications     => isFr ? 'Notifications'      : 'Notifications';

  // ── Profile ────────────────────────────────────────────────────────────────
  String get profileTitle          => isFr ? 'Mon profil'                   : 'My profile';
  String get profileConsumer       => isFr ? 'Consommateur'                 : 'Consumer';
  String get profileChoosePhoto    => isFr ? 'Choisir une photo'            : 'Choose a photo';
  String get profileGallery        => isFr ? 'Galerie photos'               : 'Photo gallery';
  String get profileCamera         => isFr ? 'Prendre une photo'            : 'Take a photo';
  String get profileDeletePhoto    => isFr ? 'Supprimer la photo'           : 'Delete photo';
  String get profileEditProfile    => isFr ? 'Mon profil'                   : 'My profile';
  String get profileEditSubtitle   => isFr ? 'Modifier mes informations'    : 'Edit my information';
  String get profileVerifications  => isFr ? 'Mes vérifications'            : 'My verifications';
  String get profileVerifSubtitle  => isFr ? 'Historique des scans'         : 'Scan history';
  String get profileReports        => isFr ? 'Mes signalements'             : 'My reports';
  String get profileReportsSubtitle=> isFr ? 'Produits signalés'            : 'Reported products';
  String get profileNotifications  => isFr ? 'Notifications'                : 'Notifications';
  String get profileNotifSubtitle  => isFr ? 'Gérer les notifications'      : 'Manage notifications';
  String get profileSecurity       => isFr ? 'Sécurité'                     : 'Security';
  String get profileSecuritySubtitle=> isFr? 'Mot de passe et confidentialité' : 'Password and privacy';
  String get profileAbout          => isFr ? 'À propos'                     : 'About';
  String get profileAboutSubtitle  => isFr ? 'Version 1.0.0 – VeriScan'    : 'Version 1.0.0 – VeriScan';
  String get profileLogout         => isFr ? 'Se déconnecter'               : 'Sign out';
  String get profileLogoutConfirm  => isFr ? 'Déconnexion'                  : 'Sign out';
  String get profileLogoutMessage  => isFr ? 'Voulez-vous vraiment vous déconnecter ?' : 'Are you sure you want to sign out?';
  String get profileAboutText      => isFr
      ? 'VeriScan est une plateforme anti-contrefaçon camerounaise. Elle permet aux consommateurs de vérifier l\'authenticité des produits en scannant leur QR code et de signaler les produits suspects.'
      : 'VeriScan is a Cameroonian anti-counterfeiting platform. It allows consumers to verify product authenticity by scanning their QR code and to report suspicious products.';
  String get profileVersion        => isFr ? 'Version 1.0.0'               : 'Version 1.0.0';
  String get profileClose          => isFr ? 'Fermer'                       : 'Close';
  String get profileLanguage       => isFr ? 'Langue'                       : 'Language';
  String get profileLanguageSubtitle => isFr ? 'Français / English'         : 'Français / English';

  // ── Scan ───────────────────────────────────────────────────────────────────
  String get scanTitle             => isFr ? 'Scanner'                      : 'Scanner';
  String get scanInstruction       => isFr ? 'Pointez vers un QR code VeriScan' : 'Point at a VeriScan QR code';
  String get scanManual            => isFr ? 'Saisie manuelle'              : 'Manual entry';
  String get scanPermission        => isFr ? 'Autorisation caméra requise'  : 'Camera permission required';
  String get scanPermissionBtn     => isFr ? 'Autoriser'                    : 'Allow';
  String get scanResult            => isFr ? 'Résultat du scan'             : 'Scan result';
  String get scanAuthentic         => isFr ? 'Produit Authentique'          : 'Authentic Product';
  String get scanSuspect           => isFr ? 'Produit Suspect'              : 'Suspicious Product';
  String get scanCounterfeit       => isFr ? 'Produit Contrefait'           : 'Counterfeit Product';
  String get scanReport            => isFr ? 'Signaler ce produit'          : 'Report this product';
  String get scanScanAgain         => isFr ? 'Scanner à nouveau'            : 'Scan again';

  // ── Signalement ────────────────────────────────────────────────────────────
  String get reportTitle           => isFr ? 'Signaler un produit'          : 'Report a product';
  String get reportName            => isFr ? 'Votre nom (optionnel)'        : 'Your name (optional)';
  String get reportContact         => isFr ? 'Votre contact (optionnel)'    : 'Your contact (optional)';
  String get reportDescription     => isFr ? 'Description du problème'      : 'Problem description';
  String get reportDescHint        => isFr ? 'Décrivez le problème observé...': 'Describe the observed problem...';
  String get reportDescRequired    => isFr ? 'Veuillez décrire le problème' : 'Please describe the problem';
  String get reportPhoto           => isFr ? 'Ajouter une photo'            : 'Add a photo';
  String get reportLocation        => isFr ? 'Localisation'                 : 'Location';
  String get reportLocationCapture => isFr ? 'Capturer ma position'         : 'Capture my location';
  String get reportLocationCapturing => isFr ? 'Localisation en cours...'   : 'Getting location...';
  String get reportLocationDone    => isFr ? 'Position capturée'            : 'Location captured';
  String get reportSubmit          => isFr ? 'Envoyer le signalement'       : 'Submit report';
  String get reportSuccess         => isFr ? 'Signalement envoyé avec succès' : 'Report submitted successfully';
  String get reportError           => isFr ? 'Erreur lors de l\'envoi'      : 'Error while submitting';

  // ── Historique ─────────────────────────────────────────────────────────────
  String get historyTitle          => isFr ? 'Mes vérifications'            : 'My verifications';
  String get historyEmpty          => isFr ? 'Aucune vérification'          : 'No verifications yet';
  String get historyEmptySubtitle  => isFr ? 'Scannez un produit pour commencer' : 'Scan a product to get started';

  // ── Notifications ──────────────────────────────────────────────────────────
  String get notifTitle            => isFr ? 'Notifications'                : 'Notifications';
  String get notifEmpty            => isFr ? 'Aucune notification'          : 'No notifications';

  // ── Sécurité ───────────────────────────────────────────────────────────────
  String get securityTitle         => isFr ? 'Sécurité'                     : 'Security';
  String get securityChangePass    => isFr ? 'Changer le mot de passe'      : 'Change password';
  String get securityCurrentPass   => isFr ? 'Mot de passe actuel'          : 'Current password';
  String get securityNewPass       => isFr ? 'Nouveau mot de passe'         : 'New password';
  String get securityConfirmPass   => isFr ? 'Confirmer le mot de passe'    : 'Confirm password';
  String get securitySave          => isFr ? 'Enregistrer'                  : 'Save';

  // ── Assistant ──────────────────────────────────────────────────────────────
  String get assistantTitle        => isFr ? 'Assistant VeriScan'           : 'VeriScan Assistant';
  String get assistantHint         => isFr ? 'Posez votre question...'      : 'Ask your question...';
  String get assistantSend         => isFr ? 'Envoyer'                      : 'Send';

  // ── Aide ───────────────────────────────────────────────────────────────────
  String get helpTitle             => isFr ? 'Aide'                         : 'Help';

  // ── Recherche ──────────────────────────────────────────────────────────────
  String get searchTitle           => isFr ? 'Rechercher'                   : 'Search';
  String get searchHint            => isFr ? 'Rechercher un produit...'     : 'Search a product...';

  // ── Vérification manuelle ──────────────────────────────────────────────────
  String get verifyManualTitle     => isFr ? 'Vérification manuelle'        : 'Manual verification';
  String get verifyManualHint      => isFr ? 'Entrez le code du produit'    : 'Enter the product code';
  String get verifyManualButton    => isFr ? 'Vérifier'                     : 'Verify';

  // ── Commun ─────────────────────────────────────────────────────────────────
  String get cancel                => isFr ? 'Annuler'                      : 'Cancel';
  String get confirm               => isFr ? 'Confirmer'                    : 'Confirm';
  String get save                  => isFr ? 'Enregistrer'                  : 'Save';
  String get close                 => isFr ? 'Fermer'                       : 'Close';
  String get back                  => isFr ? 'Retour'                       : 'Back';
  String get loading               => isFr ? 'Chargement...'                : 'Loading...';
  String get retry                 => isFr ? 'Réessayer'                    : 'Retry';
  String get yes                   => isFr ? 'Oui'                          : 'Yes';
  String get no                    => isFr ? 'Non'                          : 'No';
  String get disconnect            => isFr ? 'Déconnecter'                  : 'Sign out';
}