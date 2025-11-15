import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx_exten/get_selector/get_selector.dart';
import 'package:getx_exten/utils/rx_extensions.dart';

import 'rx_bloc_test.dart';
import 'rx_cubit_test.dart';

void main() {
  group('RxCubit Extensions', () {
    test('select creates GetSelector widget', () {
      final cubit = ComplexCubit();

      final selector = cubit.select(
            (state) => state.name,
            (context, name) => Text(name),
      );

      expect(selector, isA<GetSelector<TestState, String>>());
    });

    test('watch creates Worker for state changes', () async {
      final cubit = ComplexCubit();
      final watchedValues = <TestState>[];

      final worker = cubit.watch((state) {
        watchedValues.add(state);
      });

      cubit.updateName('John');
      await Future.delayed(Duration.zero);
      expect(watchedValues.length, 1);
      expect(watchedValues[0].name, 'John');

      cubit.updateAge(25);
      await Future.delayed(Duration.zero);
      expect(watchedValues.length, 2);
      expect(watchedValues[1].age, 25);

      worker.dispose();
    });
  });

  group('RxBloc Extensions', () {
    test('select creates GetSelector widget', () {
      final bloc = TestBloc();

      final selector = bloc.select(
            (state) => state > 10,
            (context, isHigh) => Text(isHigh ? 'High' : 'Low'),
      );

      expect(selector, isA<GetSelector<int, bool>>());
    });

    test('watch creates Worker for state changes', () async {
      final bloc = TestBloc();
      final watchedValues = <int>[];

      final worker = bloc.watch((state) {
        watchedValues.add(state);
      });

      bloc.add(IncrementEvent());
      await Future.delayed(Duration.zero);
      expect(watchedValues, [1]);

      bloc.add(IncrementEvent());
      await Future.delayed(Duration.zero);
      expect(watchedValues, [1, 2]);

      worker.dispose();
    });
  });
}