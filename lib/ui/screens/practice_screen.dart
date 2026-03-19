import 'package:data_table_2/data_table_2.dart';
import 'package:dmv_admin/domain/models/education_model.dart';
import 'package:dmv_admin/ui/providers/settings_provider.dart';
import 'package:dmv_admin/ui/widgets/ai_panel.dart';
import 'package:dmv_admin/ui/widgets/manager_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/response_log.dart';
import '../providers/practice_provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

enum CellStatus { normal, loading, notChanged, saved, created, error }

class _PracticeScreenState extends State<PracticeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isPanelOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pracProv = context.read<PracticeProvider>();
      pracProv.init(context.read<SettingsProvider>().configLog);
      if (pracProv.response.isNotEmpty) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showEditPopup(
    BuildContext context,
    Offset clickPosition,
    String text,
    Function(String) onSave,
    Function(String) onReplay,
    String title,
  ) {
    final controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    controller.text = text;

    // Размеры нашего будущего окна
    const double popupWidth = 300;
    const double popupHeight = 200;

    // --- ЛОГИКА ПОЗИЦИИ ---

    // 1. По горизонтали:
    // Если клик был близко к правому краю (места справа меньше, чем ширина окна),
    // то рисуем окно СЛЕВА от курсора. Иначе - СПРАВА.
    double left = clickPosition.dx;
    if (left + popupWidth > screenWidth) {
      left = screenWidth - popupWidth - 10; // Сдвигаем влево + отступ
    }

    // 2. По вертикали:
    // Если клик внизу экрана - поднимаем окно НАД курсором.
    double top = clickPosition.dy;
    if (top + popupHeight > screenHeight) {
      top = screenHeight - popupHeight - 10;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: popupWidth,
                  constraints: BoxConstraints(minHeight: 100, maxHeight: 300),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          'Редактирование: \'$title\'',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          maxLines: null,
                          keyboardType: .multiline,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: .end,
                          children: [
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed:
                                    title == 'Q-ID' ||
                                        title == 'State' ||
                                        title == 'bool' ||
                                        title == 'Image'
                                    ? () {
                                        onReplay(controller.text);
                                        Navigator.pop(context);
                                      }
                                    : null,
                                child: Text('Replay'),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () async {
                                  onSave(controller.text);
                                  await Future.delayed(
                                    Duration(milliseconds: 100),
                                  );
                                  _scrollToBottom();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Save'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  DataCell _dataCell({
    required PracticeProvider pracProv,
    required EducationModel q,
    required String textValue,
    required String columKey,
    required String popupTitle,
  }) {
    final cellKey = pracProv.getCellKey(
      q.language,
      q.questionId.toString(),
      q.usState,
      columKey,
    );

    final CellStatus currentStatus =
        pracProv.cellStatus[cellKey] ?? CellStatus.normal;

    Color bgColor = Colors.transparent;
    switch (currentStatus) {
      case CellStatus.notChanged:
        bgColor = Colors.orangeAccent;
        break;
      case CellStatus.loading:
        bgColor = Colors.cyanAccent;
        break;
      case CellStatus.saved:
        bgColor = Colors.green;
        break;
      case CellStatus.error:
        bgColor = Colors.red;
        break;
      case CellStatus.normal:
        bgColor = Colors.transparent;
        break;
      case CellStatus.created:
        bgColor = Colors.greenAccent;
    }

    return DataCell(
      Stack(
        children: [
          Container(
            width: .infinity,
            height: .infinity,
            decoration: BoxDecoration(
              color: bgColor,
              border: columKey == 'Language'
                  ? Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(8),
            child: Center(child: Text(textValue, overflow: .ellipsis)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 3),
            child: Row(
              mainAxisAlignment: .end,
              children: [
                pracProv.warningIsEqual(
                  SizedBox.shrink(),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 15,
                  ),

                  columKey,
                  q,
                ),
                if (textValue == q.correctAnswer &&
                    columKey != 'Correct_Answer' &&
                    q.correctAnswer != '')
                  Icon(
                    Icons.check_circle_outline_outlined,
                    color: Colors.blue,
                    size: 15,
                  ),
              ],
            ),
          ),
        ],
      ),
      onTapDown: (details) {
        final indexToUpdate = pracProv.getQuestionIndex(q);
        _showEditPopup(
          context,
          details.globalPosition,
          textValue,
          (newValue) async {
            final currentType = q.getFieldValue(columKey);
            dynamic parsedValue = newValue;

            if (currentType is int) {
              try {
                parsedValue = int.parse(newValue);
              } catch (e) {
                setState(() {
                  ResponseLog responseLog = ResponseLog(
                    logNumber: pracProv.response.length,
                    log: 'Ошибка: поле - $columKey должно иметь только числа',
                  );
                  pracProv.response.add(responseLog);
                  pracProv.cellStatus[cellKey] = CellStatus.error;
                });
              }
            } else if (currentType is bool) {
              // Ответ true or false и будет записан как значение bool
              parsedValue = newValue.toLowerCase() == 'true';
            }

            if (!pracProv.create) {
              await pracProv.updateQuestion(
                indexToUpdate: indexToUpdate,
                lang: q.language,
                id: q.questionId,
                state: q.usState,
                newValue: parsedValue,
                fieldName: columKey,
                cellKey: cellKey,
                question: q,
              );
            } else {
              pracProv.createNewFieldValue(q, columKey, parsedValue, cellKey);
            }
          },
          (newValue) {
            pracProv.replayAllCellInColumn(q, columKey, newValue, cellKey);
          },
          popupTitle,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pracProv = context.watch<PracticeProvider>();
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  ManagerPanel(
                    pracProv: pracProv,
                    onTap: () => setState(() {
                      if(pracProv.allQuestion.isNotEmpty &&
                          pracProv.allQuestion.first.correctAnswer.isNotEmpty){
                        pracProv.initSetCorrectField();
                      }
                      _isPanelOpen = !_isPanelOpen;
                    }),
                    isAiPanel: _isPanelOpen,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      if (pracProv.allQuestion.isNotEmpty &&
                          pracProv.allQuestion.first.image != null &&
                          pracProv.allQuestion.first.image!.isNotEmpty) ...[
                        SizedBox(width: 10),
                        Container(
                          width: 400,
                          height: 220,
                          clipBehavior: .hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Image.network(
                            pracProv.allQuestion.first.image ?? '',
                            fit: .contain,
                          ),
                        ),
                      ],
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 220,
                          color: Colors.transparent,
                          child: ListView.separated(
                            controller: _scrollController,
                            itemCount: pracProv.response.length,
                            itemBuilder: (_, index) {
                              final log = pracProv.response[index];
                              return Text(
                                '${log.logNumber}: ${log.log} - Cell Key: ${log.cellKey}',
                              );
                            },
                            separatorBuilder: (_, _) {
                              return Divider(color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 12, bottom: 12, right: !_isPanelOpen ? 12.0 : 2.0 ),
                          child: Container(
                            clipBehavior: .antiAlias,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -4
                                ),
                              ],
                            ),
                            child: DataTable2(
                              fixedLeftColumns: 1,
                              columnSpacing: 0,
                              horizontalMargin: 0,
                              isHorizontalScrollBarVisible: true,
                              isVerticalScrollBarVisible: true,
                              headingRowDecoration: BoxDecoration(color: Colors.grey),
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              border: TableBorder(
                                verticalInside: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                                horizontalInside: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                              columns: [
                                DataColumn2(
                                  label: Container(
                                    width: .infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                    child: Center(child: Text('Language')),
                                  ),
                                  size: ColumnSize.S,
                                  fixedWidth: 85,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Q-ID')),
                                  size: ColumnSize.S,
                                  fixedWidth: 85,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('State')),
                                  size: ColumnSize.S,
                                  fixedWidth: 110,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Question')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Answer-A')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Answer-B')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Answer-C')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Answer-D')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Correct-Answer')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Handbook')),
                                  minWidth: 150,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Choose-Wrong')),
                                  fixedWidth: 100,
                                ),

                                DataColumn2(
                                  label: Center(child: Text('Image')),
                                  minWidth: 150,
                                ),
                              ],
                              rows: pracProv.allQuestion
                                  .map(
                                    (q) => DataRow2(
                                      cells: [
                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.language,
                                          columKey: 'Language',
                                          popupTitle: 'Language',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.questionId.toString(),
                                          columKey: 'Question_ID',
                                          popupTitle: 'Q-ID',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.usState,
                                          columKey: 'State',
                                          popupTitle: 'State',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.question,
                                          columKey: 'Question',
                                          popupTitle: 'Question',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.answerA,
                                          columKey: 'Answer_A',
                                          popupTitle: 'Answer-A',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.answerB,
                                          columKey: 'Answer_B',
                                          popupTitle: 'Answer-B',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.answerC,
                                          columKey: 'Answer_C',
                                          popupTitle: 'Answer-C',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.answerD ?? '',
                                          columKey: 'Answer_D',
                                          popupTitle: 'Answer-D',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.correctAnswer,
                                          columKey: 'Correct_Answer',
                                          popupTitle: 'Correct-Answer',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.handBook,
                                          columKey: 'Hendbook',
                                          popupTitle: 'Handbook',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.enableAnswerD.toString(),
                                          columKey: 'Choose_Wrong',
                                          popupTitle: 'bool',
                                        ),

                                        _dataCell(
                                          pracProv: pracProv,
                                          q: q,
                                          textValue: q.image ?? '',
                                          columKey: 'Image',
                                          popupTitle: 'Image',
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            if (_isPanelOpen)
              AiPanel()
          ],
        ),
        if (pracProv.isLoading)
          Positioned(
            right: 10,
            bottom: 10,
            child: SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                color: Colors.black26,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }
}
