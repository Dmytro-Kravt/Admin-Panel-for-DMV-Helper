import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/domain/models/education_model.dart';
import 'package:dmv_admin/ui/providers/practice_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AiResponseCard extends StatefulWidget {
  final List<EducationModel> eightTranslations;

  const AiResponseCard({
    super.key,
    required this.eightTranslations,
  });

  @override
  State<AiResponseCard> createState() => _AiResponseCardState();
}

class _AiResponseCardState extends State<AiResponseCard> {
  bool _allTranslations = false;

  Card _responsAI(EducationModel question) {
    final filledField = question.toJson().entries.where(
      (e) =>
          e.value != null &&
          e.value != 0 &&
          e.value.toString().isNotEmpty &&
          e.value != false,
    );

    return Card(
      color: Theme.of(context).colorScheme.onTertiary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: .bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    question.language,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black54,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey),

              for (var entry in filledField) ...[
                Column(
                  crossAxisAlignment: .start,
                  children: [

                    Text(
                      '${entry.key}: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: .bold,
                        color: Colors.black54,
                      ),
                    ),

                    Text(
                      entry.value,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pracProv = context.watch<PracticeProvider>();
    return Column(
      children: [
        if (_allTranslations)
          for (EducationModel q in widget.eightTranslations) _responsAI(q),
        if (!_allTranslations)
          _responsAI(
            context.read<PracticeProvider>().onlyRU(widget.eightTranslations),
          ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: .spaceAround,
          children: [
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> currentState,
                ) {
                  if (currentState.contains(WidgetState.hovered)) {
                    return Theme.of(context).colorScheme.surface;
                  }
                  if (currentState.contains(WidgetState.pressed)) {
                    return Theme.of(context).colorScheme.primaryContainer;
                  }
                  return null;
                }),
              ),
              onPressed: () {
                setState(() {
                  _allTranslations = !_allTranslations;
                });
              },
              child: Text(
                !_allTranslations ? 'See All' : 'Hide',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(85.0, 40.0),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                if(pracProv.allQuestion.length == 8 &&
                pracProv.correctField != null
                ) {
                  pracProv.saveAiResponseToTable(
                      widget.eightTranslations,
                      pracProv.correctField!
                  );
                } else {
                  printer('List', '< 8');
                  null;
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
  }
}
