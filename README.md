# GetX Extensions 🚀

[![pub package](https://img.shields.io/pub/v/getx_exten.svg)](https://pub.dev/packages/getx_exten)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful state management extension for GetX that combines BLoC patterns with GetX's reactive superpowers. Build scalable Flutter apps with ease!

## ✨ Features

- 🎯 **Type Flexibility** - Use ANY type as state (int, String, custom classes, etc.)
- 🔥 **GetX Reactive** - Direct `Rx` support for lightweight reactive state
- 🏗️ **BLoC Patterns** - Familiar Cubit and BLoC architecture
- ⚡ **Performance** - Fine-grained reactivity with selectors
- 🎨 **Rich Widgets** - Specialized widgets for every use case
- 🧪 **Well Tested** - Comprehensive test suite
- 📦 **Zero Boilerplate** - No base classes required

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  getx_exten: ^2.0.0
  get: ^4.6.5
```

## 🎯 Quick Start

### 1. Create a Cubit (Simple State)

```dart
class CounterCubit extends RxCubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

### 2. Use in Your Widget

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = Get.put(CounterCubit());
    
    return Scaffold(
      body: Center(
        child: GetChanger<int>(
          controller: cubit,
          builder: (context, count) => Text('Count: $count'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: cubit.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

That's it! 🎉

## 📚 Core Concepts

### RxCubit - Simple State Management

Perfect for straightforward state that doesn't need events.

```dart
// Works with primitives
class CounterCubit extends RxCubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

// Works with custom classes
class User {
  final String name;
  final int age;
  User(this.name, this.age);
}

class UserCubit extends RxCubit<User> {
  UserCubit() : super(User('', 0));
  
  void updateUser(String name, int age) {
    emit(User(name, age));
  }
}

// Works with nullable types
class SearchCubit extends RxCubit<String?> {
  SearchCubit() : super(null);
  
  void search(String query) => emit(query);
  void clear() => emit(null);
}

// Works with collections
class TodosCubit extends RxCubit<List<String>> {
  TodosCubit() : super([]);
  
  void addTodo(String todo) => emit([...state, todo]);
}
```

### RxBloc - Event-Driven State Management

For complex state logic with events.

```dart
// Define events
abstract class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}
class AddValue extends CounterEvent {
  final int value;
  AddValue(this.value);
}

// Create bloc
class CounterBloc extends RxBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) async {
      emit(state + 1);
    });
    
    on<Decrement>((event, emit) async {
      emit(state - 1);
    });
    
    on<AddValue>((event, emit) async {
      emit(state + event.value);
    });
  }
}

// Use in widget
final bloc = Get.put(CounterBloc());
bloc.add(Increment());
bloc.add(AddValue(5));
```

## 🎨 Widgets

### GetChanger - Simple Builder

Rebuilds when state changes. Perfect for displaying state.

```dart
GetChanger<int>(
  controller: counterCubit,
  builder: (context, count) => Text('$count'),
)

// With buildWhen condition
GetChanger<int>(
  controller: counterCubit,
  buildWhen: (prev, curr) => curr % 2 == 0, // Only rebuild on even numbers
  builder: (context, count) => Text('$count'),
)

// With direct Rx
final count = 0.obs;
GetChanger<int>(
  rx: count,
  builder: (context, value) => Text('$value'),
)
```

### GetListenerWidget - Side Effects Only

Listens to state without rebuilding. Perfect for navigation, snackbars, dialogs.

```dart
GetListenerWidget<int>(
  controller: counterCubit,
  listener: (context, count) {
    if (count > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Count exceeded 10!')),
      );
    }
  },
  child: MyWidget(),
)

// With listenWhen condition
GetListenerWidget<int>(
  controller: counterCubit,
  listenWhen: (prev, curr) => curr > prev, // Only listen on increase
  listener: (context, count) {
    print('Count increased: $count');
  },
  child: MyWidget(),
)
```

### GetConsumer - Builder + Listener

Combines building and listening. Perfect for complex UI with side effects.

```dart
GetConsumer<int>(
  controller: counterCubit,
  listener: (context, count) {
    // Side effects
    if (count == 10) {
      showDialog(context: context, builder: (_) => AlertDialog(...));
    }
  },
  builder: (context, count) {
    // UI
    return Text('$count');
  },
)

// With independent conditions
GetConsumer<int>(
  controller: counterCubit,
  listenWhen: (prev, curr) => curr % 5 == 0, // Listen every 5
  buildWhen: (prev, curr) => curr % 2 == 0,  // Build every 2
  listener: (context, count) => print('Multiple of 5: $count'),
  builder: (context, count) => Text('$count'),
)
```

### GetSelector - Fine-Grained Reactivity

Only rebuilds when the selected value changes. HUGE performance boost!

```dart
class UserState {
  final String name;
  final int age;
  final List<String> hobbies;
  
  UserState(this.name, this.age, this.hobbies);
}

class UserCubit extends RxCubit<UserState> {
  UserCubit() : super(UserState('', 0, []));
  
  void updateName(String name) => emit(UserState(name, state.age, state.hobbies));
  void updateAge(int age) => emit(UserState(state.name, age, state.hobbies));
}

// Only rebuilds when NAME changes (not age or hobbies!)
GetSelector<UserState, String>(
  controller: userCubit,
  selector: (state) => state.name,
  builder: (context, name) => Text('Name: $name'),
)

// Using extension method (cleaner syntax)
userCubit.select(
  (state) => state.age,
  (context, age) => Text('Age: $age'),
)

// With primitive selectors
GetSelector<int, bool>(
  controller: counterCubit,
  selector: (count) => count > 10,
  builder: (context, isHigh) => Text(isHigh ? 'High' : 'Low'),
)
```

### GetMultiChanger - Multiple Sources

Reacts to multiple state sources. Perfect for combining different cubits.

```dart
GetMultiChanger(
  sources: [
    Get.find<CartCubit>().rx,
    Get.find<PriceCubit>().rx,
  ],
  builder: (context) {
    final cart = Get.find<CartCubit>();
    final price = Get.find<PriceCubit>();
    
    return Text('${cart.state.length} items - \$${price.state}');
  },
)

// With mixed sources
final userCubit = Get.find<UserCubit>();
final count = 0.obs;

GetMultiChanger(
  sources: [userCubit.rx, count],
  builder: (context) => Text('${userCubit.state.name}: ${count.value}'),
)
```

## 🎓 Advanced Usage

### Custom State Classes

No inheritance required! Define your state however you want.

```dart
// Simple class
class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  
  TodoState(this.todos, this.isLoading);
}

// Sealed classes (recommended for complex states)
sealed class AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthLoading extends AuthState {}

class AuthCubit extends RxCubit<AuthState> {
  AuthCubit() : super(Unauthenticated());
  
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authService.login(email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
```

### Pattern Matching with Sealed Classes

```dart
GetChanger<AuthState>(
  controller: authCubit,
  builder: (context, state) {
    return switch (state) {
      Authenticated(:final user) => HomePage(user: user),
      Unauthenticated() => LoginPage(),
      AuthLoading() => LoadingPage(),
    };
  },
)
```

### Watching State Imperatively

```dart
class MyController extends GetxController {
  final counterCubit = CounterCubit();
  late Worker _worker;
  
  @override
  void onInit() {
    super.onInit();
    
    // Watch state changes
    _worker = counterCubit.watch((count) {
      print('Count changed to: $count');
      
      if (count == 10) {
        // Do something
      }
    });
  }
  
  @override
  void onClose() {
    _worker.dispose();
    super.onClose();
  }
}
```

### Combining Multiple Conditions

```dart
GetConsumer<TodoState>(
  controller: todoCubit,
  // Rebuild only when todos list changes
  buildWhen: (prev, curr) => prev.todos.length != curr.todos.length,
  // Listen only when loading state changes
  listenWhen: (prev, curr) => prev.isLoading != curr.isLoading,
  listener: (context, state) {
    if (!state.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos loaded!')),
      );
    }
  },
  builder: (context, state) {
    if (state.isLoading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: state.todos.length,
      itemBuilder: (context, index) => TodoItem(state.todos[index]),
    );
  },
)
```

## 🎯 Best Practices

### 1. Use the Right Widget for the Job

```dart
// ✅ Good - Use GetChanger for simple display
GetChanger<int>(
  controller: cubit,
  builder: (context, count) => Text('$count'),
)

// ✅ Good - Use GetListenerWidget for side effects
GetListenerWidget<String>(
  controller: messageCubit,
  listener: (context, message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  },
  child: MyWidget(),
)

// ❌ Bad - Don't use GetConsumer when you only need building
GetConsumer<int>(
  controller: cubit,
  listener: (context, count) {}, // Empty listener
  builder: (context, count) => Text('$count'),
)
```

### 2. Leverage Selectors for Performance

```dart
// ❌ Bad - Rebuilds when ANY field changes
GetChanger<UserState>(
  controller: userCubit,
  builder: (context, state) => Text(state.name),
)

// ✅ Good - Only rebuilds when name changes
GetSelector<UserState, String>(
  controller: userCubit,
  selector: (state) => state.name,
  builder: (context, name) => Text(name),
)
```

### 3. Use Direct Rx for Simple Cases

```dart
// For simple reactive values, skip the cubit
class MyController extends GetxController {
  final count = 0.obs;
  final name = 'John'.obs;
  final isLoading = false.obs;
  
  void increment() => count.value++;
}

// Use directly
GetChanger<int>(
  rx: controller.count,
  builder: (context, count) => Text('$count'),
)
```

### 4. Combine with GetX Dependency Injection

```dart
// In your binding or main.dart
Get.put(CounterCubit());
Get.lazyPut(() => UserCubit());

// Access anywhere
final counterCubit = Get.find<CounterCubit>();
```

### 5. Proper Disposal

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final CounterCubit cubit;
  
  @override
  void initState() {
    super.initState();
    cubit = CounterCubit();
  }
  
  @override
  void dispose() {
    cubit.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GetChanger<int>(
      controller: cubit,
      builder: (context, count) => Text('$count'),
    );
  }
}
```

## 🧪 Testing

All widgets are fully testable:

```dart
testWidgets('GetChanger rebuilds on state change', (tester) async {
  final cubit = CounterCubit();
  
  await tester.pumpWidget(
    MaterialApp(
      home: GetChanger<int>(
        controller: cubit,
        builder: (context, count) => Text('$count'),
      ),
    ),
  );
  
  expect(find.text('0'), findsOneWidget);
  
  cubit.increment();
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});
```

## 📊 Comparison with Other Solutions

| Feature | GetX Extensions | flutter_bloc | GetX Alone |
|---------|----------------|--------------|------------|
| Type Flexibility | ✅ Any type | ✅ Any type | ✅ Any type |
| Fine-grained Selectors | ✅ Built-in | ✅ Via BlocSelector | ❌ Manual |
| Multi-source Reactivity | ✅ GetMultiChanger | ❌ Manual | ✅ Obx |
| Performance | ⚡ Excellent | ⚡ Excellent | ⚡ Excellent |
| Boilerplate | 🟢 Low | 🟡 Medium | 🟢 Low |
| Learning Curve | 🟢 Easy | 🟡 Medium | 🟢 Easy |
| BLoC Pattern | ✅ Optional | ✅ Core | ❌ Not built-in |
| Direct Rx Support | ✅ Yes | ❌ No | ✅ Yes |

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on top of the amazing [GetX](https://pub.dev/packages/get) package
- Inspired by [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- Thanks to all contributors!

## 📞 Support

- 📧 Email: edkluivert@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/edkluivert/getx_exten/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/edkluivert/getx_exten/discussions)

---

Made with ❤️ by the GetX Extensions team