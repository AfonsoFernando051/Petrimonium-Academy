import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/glass_card.dart';
import 'package:petrimonium/features/asset_details/domain/entities/asset_details.dart';
import 'package:petrimonium/features/portfolio/presentation/widgets/shared/section_label.dart';

/// Educational section that explains what the asset is, how it generates
/// income, and what investors should understand about it. Content is
/// determined by asset type.
class AssetEducationSection extends StatefulWidget {
  const AssetEducationSection({super.key, required this.asset});

  final AssetDetails asset;

  @override
  State<AssetEducationSection> createState() => _AssetEducationSectionState();
}

class _AssetEducationSectionState extends State<AssetEducationSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: context.colors.surface.withValues(alpha: context.isDarkMode ? 0.55 : 0.94),
      borderColor: AppColors.neonCyan.withValues(alpha: 0.15),
      borderRadius: 18,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SectionLabel('GUIA EDUCACIONAL'),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: AppColors.neonCyan,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── What is this asset? ─────────────────────────────
            _EducationBlock(
              icon: Icons.help_outline,
              title: 'O que é ${widget.asset.displayName}?',
              content: _whatIs(),
              accentColor: AppColors.neonCyan,
            ),

            if (_expanded) ...[
              const SizedBox(height: 16),

              // ── How does it make money? ─────────────────────────
              _EducationBlock(
                icon: Icons.monetization_on_outlined,
                title: 'Como gera renda?',
                content: _howMakesMoney(),
                accentColor: AppColors.goldenBorder,
              ),

              const SizedBox(height: 16),

              // ── What to watch? ──────────────────────────────────
              _EducationBlock(
                icon: Icons.visibility_outlined,
                title: 'O que observar?',
                content: _whatToWatch(),
                accentColor: context.colors.warning,
              ),
            ],

            if (!_expanded) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: const Text(
                  'Saiba mais →',
                  style: TextStyle(
                    color: AppColors.neonCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _whatIs() {
    final name = widget.asset.displayName;
    final sector = widget.asset.sector;

    if (widget.asset.isFii) {
      return '$name é um Fundo de Investimento Imobiliário (FII) brasileiro'
          '${sector != null ? ' do segmento de $sector' : ''}. '
          'FIIs investem em imóveis ou títulos imobiliários e distribuem '
          'rendimentos periodicamente aos cotistas.';
    }
    if (widget.asset.isEtf) {
      return '$name é um ETF (fundo de índice) negociado em bolsa. '
          'ETFs replicam a composição de um índice, permitindo investir em '
          'uma cesta diversificada de ativos com uma única operação.';
    }
    if (widget.asset.isBdr) {
      return '$name é um BDR (Brazilian Depositary Receipt) — um certificado '
          'que representa ações de empresas estrangeiras negociado na B3.';
    }
    return '$name é uma ação negociada na bolsa brasileira'
        '${sector != null ? ', do setor de $sector' : ''}. '
        'Ao comprar uma ação, você se torna sócio da empresa, participando '
        'de seus resultados.';
  }

  String _howMakesMoney() {
    if (widget.asset.isFii) {
      return 'FIIs geram renda principalmente através de aluguéis de imóveis '
          'ou rendimentos de títulos imobiliários. São obrigados a distribuir '
          'pelo menos 95% do lucro caixa semestralmente, mas na prática a '
          'maioria distribui mensalmente.';
    }
    if (widget.asset.isEtf) {
      return 'ETFs geram retorno através da valorização dos ativos que compõem '
          'o índice replicado. Alguns ETFs também distribuem dividendos dos '
          'ativos subjacentes, embora no Brasil isso seja menos comum.';
    }
    return 'Ações geram retorno de duas formas: valorização do preço e '
        'distribuição de proventos (dividendos e juros sobre capital próprio). '
        'Empresas lucrativas podem compartilhar parte do lucro com acionistas.';
  }

  String _whatToWatch() {
    if (widget.asset.isFii) {
      return '• Vacância: imóveis desocupados reduzem a renda\n'
          '• P/VP: relação entre preço e valor patrimonial\n'
          '• Dividend Yield: rendimento relativo ao preço\n'
          '• Qualidade dos inquilinos e contratos\n'
          '• Concentração do portfólio de imóveis';
    }
    if (widget.asset.isEtf) {
      return '• Índice replicado: o que o ETF segue\n'
          '• Taxa de administração: custo do fundo\n'
          '• Tracking error: diferença entre ETF e índice\n'
          '• Diversificação: quantos ativos compõem\n'
          '• Liquidez: facilidade de comprar/vender';
    }
    return '• Lucro e receita: a empresa está crescendo?\n'
        '• Endividamento: a dívida está controlada?\n'
        '• Margens: a empresa é eficiente?\n'
        '• P/L e P/VP: indicadores de valuation\n'
        '• Dividend Yield: retorno em dividendos';
  }
}

class _EducationBlock extends StatelessWidget {
  const _EducationBlock({
    required this.icon,
    required this.title,
    required this.content,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}
