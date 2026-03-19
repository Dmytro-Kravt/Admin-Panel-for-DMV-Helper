import 'package:dmv_admin/ui/providers/practice_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagerPanel extends StatefulWidget {
  final PracticeProvider pracProv;
  final Function() onTap;
  final bool isAiPanel;

  const ManagerPanel({
    super.key,
    required this.pracProv,
    required this.onTap,
    required this.isAiPanel
  });

  @override
  State<ManagerPanel> createState() => _ManagerPanelState();
}

class _ManagerPanelState extends State<ManagerPanel> {
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _statController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  bool createIndicator = false;

  @override
  void initState() {
    _languageController.addListener(languageListener);
    _statController.addListener(stateListeners);
    _idController.addListener(idListeners);
    super.initState();
  }

  void languageListener() {
    if (_languageController.text.isNotEmpty) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void stateListeners() {
    if (_statController.text.isNotEmpty) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void idListeners() {
    if (_idController.text.isNotEmpty) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _languageController.removeListener(languageListener);
    _languageController.dispose();
    _idController.dispose();
    _statController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 10,
          top: 10,
          right: !widget.isAiPanel ? 12.0 : 2.0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: Colors.grey, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 8),
              blurRadius: 12,
              spreadRadius: -4
            )
          ]
        ),
        child: Stack(
          children: [
            Positioned(
              right: 1,
              bottom: 1,
              child: Column(
                children: [

                  SizedBox(
                    width: 100,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: widget.pracProv.role == .viewer
                          ? null
                          : widget.onTap,
                      child: Text('AI'),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: widget.pracProv.role == .viewer ? null :() {
                        widget.pracProv.saveQuestionsToPC(
                          _languageController.text,
                          _statController.text,
                        );
                      },
                      child: Text('Save'),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: widget.pracProv.role == .viewer ? null :() {
                        widget.pracProv.loadQuestions(
                          language: _languageController.text.isNotEmpty
                              ? _languageController.text
                              : null,
                          state: _statController.text.isNotEmpty
                              ? _statController.text
                              : null,
                          qid: _idController.text.isNotEmpty
                              ? _idController.text
                              : null,
                        );
                        context.read<PracticeProvider>().response.clear();
                      },
                      child: widget.pracProv.isLoading
                          ? SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            )
                          : Text('Query'),
                    ),
                  ),

                ],
              ),
            ),
            Row(
              crossAxisAlignment: .start,
              children: [
                // ---- Language -----
                Column(
                  children: [
                    Text('Language'),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(2),
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _languageController.text.isEmpty
                              ? Colors.green
                              : Colors.black12,
                        ),
                        color: _languageController.text.isEmpty
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.black12,
                      ),
                      child: Center(
                        child: Text('all', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        controller: _languageController,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 5),
                VerticalDivider(width: 5, color: Colors.grey),
                SizedBox(width: 5),

                // ---- State -----
                Column(
                  children: [
                    Text('State'),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(2),
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _statController.text.isEmpty
                              ? Colors.green
                              : Colors.black12,
                        ),
                        color: _statController.text.isEmpty
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.black12,
                      ),
                      child: Center(
                        child: Text('all', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        controller: _statController,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 5),
                VerticalDivider(width: 5, color: Colors.grey),
                SizedBox(width: 5),

                // ---- ID -----
                Column(
                  children: [
                    Text('ID'),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(2),
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _idController.text.isEmpty
                              ? Colors.green
                              : Colors.black12,
                        ),
                        color: _idController.text.isEmpty
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.black12,
                      ),
                      child: Center(
                        child: Text('all', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                        controller: _idController,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 5),
                VerticalDivider(width: 5, color: Colors.grey),
                SizedBox(width: 5),

                // ---- Create new ----
                Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: widget.pracProv.create ||
                            widget.pracProv.role == .viewer
                            ? null
                            : () {
                                widget.pracProv.setCreate(true);
                                widget.pracProv.createQuestion();
                              },

                        child: Text('Create'),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: widget.pracProv.role == .viewer
                            ? null
                            : () {
                                widget.pracProv.saveNewQuestion();
                              },

                        child: Text('Submit'),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.pracProv.refreshPage();
                          setState(() {
                            _languageController.clear();
                            _statController.clear();
                            _idController.clear();
                          });
                        },

                        child: Text('Refresh'),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 5),
                VerticalDivider(width: 5, color: Colors.grey),
                SizedBox(width: 5),

                // ---- List Information ----
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Container(
                      width: 100,
                      alignment: .center,
                      child: Text('List Info'),
                    ),

                    Text('Length: ${widget.pracProv.allQuestion.length}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
