import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/ui/providers/practice_provider.dart';
import 'package:dmv_admin/ui/providers/settings_provider.dart';
import 'package:dmv_admin/ui/widgets/ai_response_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AiPanel extends StatefulWidget {
  const AiPanel({super.key});

  @override
  State<AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends State<AiPanel> {
  double panelWidth = 400;
  bool _isDividerHovered = false;
  String keyToRemuve = 'Question';
  List<String> keysOfFieldsToRegenerate = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handelRegenerateSelection(String key, PracticeProvider pracProv) {
    if (pracProv.aiResponses.isEmpty ||
        pracProv.aiResponses.first.responseAI == null ||
        pracProv.aiResponses.first.responseAI!.isEmpty) {
      return;
    }

    final lastAiResponsRu = pracProv.aiResponses.first.responseAI!
        .where((ru) => ru.language == 'ru')
        .firstOrNull;
    if (lastAiResponsRu == null) return;

    final filledField = Map.fromEntries(
      lastAiResponsRu.toJson().entries.where(
        (e) =>
            e.value != null &&
            e.value != 0 &&
            e.value.toString().isNotEmpty &&
            e.value != false,
      ),
    );

    keysOfFieldsToRegenerate.add(key);

    final newText = keysOfFieldsToRegenerate
        .map((k) {
          return '$k\n${filledField[k] ?? ''}';
        })
        .join('\n\n');

    final finalText = 'Ручной промт: \n\n$newText';

    setState(() {
      _controller.text = finalText;
      keyToRemuve = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pracProv = context.watch<PracticeProvider>();
    final settProv = context.watch<SettingsProvider>();
    return Row(
      children: [
        GestureDetector(
          onPanUpdate: (detailse) {
            setState(() {
              panelWidth -= detailse.delta.dx;
              if (panelWidth < 300) panelWidth = 300;
              if (panelWidth > 600) panelWidth = 600;
            });
          },
          child: MouseRegion(
            onEnter: (_) => setState(() {
              _isDividerHovered = true;
            }),
            onExit: (_) => setState(() {
              _isDividerHovered = false;
            }),
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Container(
              width: 20,
              color: Colors.transparent,
              alignment: .center,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  decoration: BoxDecoration(
                    color: _isDividerHovered
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(48)),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: panelWidth,
          child: Container(
            margin: EdgeInsets.only(top: 10, right: 10, bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: Colors.grey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 8),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // ---- Heder ----
                  Row(
                    children: [
                      pracProv.allQuestion.isEmpty
                          ? Text(
                          'Questions list is empty!',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: Colors.red, fontWeight: .bold),
                        )
                          : Expanded(
                            child: Row(
                            mainAxisAlignment: .spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Carrect Answer: ',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer),
                                  ),
                                  DropdownButton(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    elevation: 4,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'Answer_A',
                                        child: Text(
                                          'A',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_B',
                                        child: Text(
                                          'B',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_C',
                                        child: Text(
                                          'C',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_D',
                                        child: Text(
                                          'D',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                    ],
                                    value: pracProv.correctField,
                                    onChanged: (String? value) {
                                      pracProv.setCorrectField(value!);
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: .center,
                                children: [
                                  Text(
                                    'Select to Remake: ',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer),
                                  ),
                                  DropdownButton(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    elevation: 4,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'Language',
                                        child: Text(
                                          'Language',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Question_ID',
                                        child: Text(
                                          'Question_ID',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'State',
                                        child: Text(
                                          'State',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Question',
                                        child: Text(
                                          'Question',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_A',
                                        child: Text(
                                          'Answer_A',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_B',
                                        child: Text(
                                          'Answer_B',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_C',
                                        child: Text(
                                          'Answer_C',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Answer_D',
                                        child: Text(
                                          'Answer_D',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Correct_Answer',
                                        child: Text(
                                          'Correct_Answer',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Hendbook',
                                        child: Text(
                                          'Hendbook',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Choose_Wrong',
                                        child: Text(
                                          'Choose_Wrong',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Image',
                                        child: Text(
                                          'Image',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                        ),
                                      ),
                                    ],
                                    value: keyToRemuve,
                                    onChanged: (String? value) {
                                        _handelRegenerateSelection(value!, pracProv);
                                    },
                                  ),
                                ],
                              ),
                            ],
                           ),
                          ),
                    ],
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.surface,
                    radius: const BorderRadius.all(Radius.circular(8)),
                  ),

                  // ---- Body ----
                  Expanded(
                    child: Stack(
                      alignment: .bottomCenter,
                      children: [
                        Container(
                          color: Colors.transparent,
                          child: ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: pracProv.aiResponses.length,
                            itemBuilder: (_, index) {
                              final response = pracProv.aiResponses[index];
                              return response.role == 'User'
                                  ? Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onTertiary,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SelectionArea(
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: .end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 8.0,
                                                        ),
                                                    child: Text(
                                                      'User',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSecondaryContainer,
                                                            fontWeight: .bold,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                response.content!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight: .bold,
                                                      color: Colors.black54,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : AiResponseCard(
                                      eightTranslations: response.responseAI!,
                                    );
                            },
                          ),
                        ),
                        Align(
                          alignment: .topCenter,
                          child: Container(
                            width: .infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: .bottomCenter,
                                end: .topCenter,
                                stops: [0.2, 0.9],
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondary.withValues(alpha: 0),
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ---- Bpttom ----
                        Container(
                          width: .infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: .bottomCenter,
                              end: .topCenter,
                              stops: [0.2, 0.9],
                              colors: [
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsGeometry.only(
                            left: 12,
                            right: 12,
                            bottom: 12,
                          ),
                          child: Stack(
                            alignment: .bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiary,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                  border: Border.all(color: Colors.grey),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: 550,
                                ),
                                child: Row(
                                  crossAxisAlignment: .end,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        maxLines: null,
                                        controller: _controller,
                                        keyboardType: TextInputType.multiline,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.black87),
                                        decoration: InputDecoration(
                                          filled: false,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            left: 16,
                                            top: 12,
                                            bottom: 12,
                                            right: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 35, height: 35),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -3,
                                bottom: 4.5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(10),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  onPressed: () {
                                    pracProv.generateQuestions(
                                      _controller.text,
                                      settProv.promtConfing,
                                    );
                                    _controller.clear();
                                    keysOfFieldsToRegenerate.clear();
                                  },
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: pracProv.isResponseWaite
                                        ? CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer,
                                          )
                                        : Icon(
                                            Icons.send,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
