import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/Cubit/cubit.dart';
import 'package:todo_app/shared/Cubit/states.dart';

import '../shared/components/components.dart';
import '../shared/components/constants.dart';

class NewTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, Stack) {},
      builder: (context, state) {
        var tasks = AppCubit.get(context).newtasks;
        return tasksBuilder(
          tasks: tasks,
        );
      },
    );
  }
}
