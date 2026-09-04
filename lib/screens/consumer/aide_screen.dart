import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AideScreen extends StatefulWidget {
  const AideScreen({super.key});

  @override
  State<AideScreen> createState() => _AideScreenState();
}

class _AideScreenState extends State<AideScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Comment scanner un produit ?',
      'reponse':
          'Ouvrez l\'application VeriScan et appuyez sur l\'onglet "Scanner" en bas de l\'écran. Pointez la caméra vers le QR Code imprimé sur le produit et attendez la détection automatique. Le résultat s\'affiche immédiatement.',
    },
    {
      'question': 'Comment interpréter le résultat du scan ?',
      'reponse':
          'Un résultat ✅ AUTHENTIQUE (vert) signifie que le produit est certifié et enregistré par son fabricant. Un résultat ⚠️ SUSPECT (rouge) signifie que le produit n\'est pas reconnu ou présente des anomalies. Dans ce cas, ne consommez pas le produit.',
    },
    {
      'question': 'Que faire si le produit est suspect ?',
      'reponse':
          'Si le scan indique un produit suspect, signalez-le immédiatement via le bouton "Signaler ce produit". Notre équipe examinera votre signalement. Évitez de consommer le produit et informez le vendeur.',
    },
    {
      'question': 'Comment signaler un produit contrefait ?',
      'reponse':
          'Vous pouvez signaler un produit depuis la carte "Signaler" sur l\'accueil, ou directement après un scan suspect. Remplissez la description du problème, votre nom et contact (optionnel), puis soumettez le signalement.',
    },
    {
      'question': 'Puis-je vérifier un produit sans scanner ?',
      'reponse':
          'Oui ! Utilisez la carte "Vérifier" sur l\'accueil pour saisir manuellement le code imprimé sous le QR Code du produit. Cette option est utile si le QR Code est endommagé ou illisible.',
    },
    {
      'question': 'VeriScan est-il gratuit ?',
      'reponse':
          'Oui, VeriScan est totalement gratuit pour les consommateurs. Notre mission est de protéger les citoyens camerounais contre les produits contrefaits sans aucun coût.',
    },
    {
      'question': 'Mes données sont-elles sécurisées ?',
      'reponse':
          'Vos données personnelles sont protégées et ne sont jamais vendues à des tiers. Les signalements sont traités de façon confidentielle. Seules les informations nécessaires à la vérification sont collectées.',
    },
    {
      'question': 'Comment nous contacter ?',
      'reponse':
          'Pour toute question ou assistance, contactez-nous par email à hermannchoffo05@gmail.com ou par téléphone au +237 652705137. Notre équipe est disponible du lundi au vendredi de 8h à 17h.',
    },
  ];

  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [

          // ── Header teal ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF0D9488),
                  Color(0xFF14B8A6),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Aide & FAQ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Trouvez des réponses à vos questions sur VeriScan.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
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
          ),

          // ── FAQ List ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                const Text(
                  'Questions fréquentes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                ...List.generate(_faqs.length, (index) {
                  final faq = _faqs[index];
                  final isOpen = _openIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _openIndex = isOpen ? null : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOpen
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.textGray.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [

                          // Question
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isOpen
                                        ? AppColors.primary.withValues(alpha: 0.1)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.question_answer_rounded,
                                    color: isOpen
                                        ? AppColors.primary
                                        : AppColors.textGray,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    faq['question']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isOpen
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: isOpen
                                      ? AppColors.primary
                                      : AppColors.textGray,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),

                          // Réponse
                          if (isOpen) ...[
                            Divider(
                              height: 1,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                              child: Text(
                                faq['reponse']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGray.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Contact card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Besoin d\'aide supplémentaire ?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Contactez notre support à hermannchoffo05@gmail.com',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}