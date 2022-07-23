import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/Cubit/cubit.dart';
import '../shared/Cubit/states.dart';
import '../shared/components/components.dart';

class ArchivedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, Stack) {},
      builder: (context, state) {
        var tasks = AppCubit.get(context).archivedtasks;
        return tasksBuilder(
          tasks: tasks,
        );
      },
    );
    ;
  }
}
