import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:todo_app/shared/Cubit/cubit.dart';
import 'package:todo_app/shared/Cubit/states.dart';

import '../shared/components/constants.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            //appBar
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            // floating Button
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheeetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                    //
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          color: Colors.grey[100],
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //Title form
                                  TextFormField(
                                    controller: titleController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.title),
                                      label: Text('Task Title'),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Title must not be empty';
                                      }
                                    },
                                  ),
                                  //Time form
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: timeController,
                                    // enabled: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.watch_later),
                                      label: Text('Task time'),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.datetime,
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeController.text =
                                            value!.format(context).toString();
                                        print(value.format(context));
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'time must not be empty';
                                      }
                                    },
                                  ),
                                  // Date form
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: dateController,
                                    //enabled: false,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.calendar_today),
                                      label: Text('Task Date'),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.datetime,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        lastDate: DateTime.parse('2022-10-20'),
                                        firstDate: DateTime.now(),
                                      ).then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                        print(DateFormat.yMMMd().format(value));
                                      });
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheeetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheeetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            //Navigation Bar
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.ChangeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
