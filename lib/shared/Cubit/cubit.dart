import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/Cubit/states.dart';
import 'states.dart';
import '../../modules/archived_tasks_screen.dart';
import '../../modules/done_tasks_screen.dart';
import '../../modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'Tasks',
    ' Done Tasks',
    'Archived Tasks',
  ];
  void ChangeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNabBarState());
  }

  late Database database;
  List<Map> newtasks = [];
  List<Map> donetasks = [];
  List<Map> archivedtasks = [];

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        //id integer
        //title string
        //date string
        // time string
        // status string
        print('database is created');
        database
            .execute(
                'CREATE TABLE TASKS (id INTEGER PRIMARY KEY, title TEXT,date TEXT,time TEXT, status TEXT  )')
            .then((value) {
          print('taple created');
        }).catchError((onError) {
          //print('Error when create table ${onError.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status ) VALUES ("$title","$date","$time", "new")')
          .then((value) {
        print("$value insert successfully");
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error) {});
    });
  }

  void getDataFromDatabase(database) {
    newtasks = [];
    donetasks = [];
    archivedtasks = [];
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      // print(value);
      value.forEach(
        (element) {
          if (element['status'] == 'new') {
            newtasks.add(element);
          } else if (element['status'] == 'done') {
            donetasks.add(element);
          } else {
            archivedtasks.add(element);
          }
        },
      );
      emit(AppGetDatabaseState());
    });
  }

  updateData({
    required String status,
    required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  deleteData({
    required int id,
  }) async {
    database.rawDelete(
      'DELETE FROM tasks WHERE id = ?',
      [id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheeetShown = false;
  IconData fabIcon = Icons.edit;
  void changeBottomSheeetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheeetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
