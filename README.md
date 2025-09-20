# GetX Extensions – RxCubit, Listener, Consumer

**Extend GetX with a Cubit/Bloc-style API**, inspired by `flutter_bloc`, but with **GetX simplicity**.

---

## 🚀 Features

- **`RxCubit`**: Manage state with `emit`.
- **`RxState`**: Base class for states.
- **Built-in generic states**:
    - `RxInitial`
    - `RxLoading`
    - `RxSuccess<T>`
    - `RxError`
- **`GetXListener`**: Listen for state changes (side effects only).
- **`GetXConsumer`**: Listen **and** rebuild UI in one widget.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  getx_exten: ^1.1.4
```

---

## 🔧 Base States

### `RxState` (Base Class)

```dart
abstract class RxState {
  const RxState();
}
```

### Generic States

```dart
class RxInitial extends RxState {}
class RxLoading extends RxState {}
class RxSuccess<T> extends RxState {
  final T data;
  const RxSuccess(this.data);
}
class RxError extends RxState {
  final String message;
  const RxError(this.message);
}
```

---

## 📝 Example: Counter Cubit

### State

```dart
abstract class CounterState extends RxState {
  final int value;
  const CounterState(this.value);
}

class CounterInitial extends CounterState {
  const CounterInitial() : super(0);
}

class CounterValue extends CounterState {
  const CounterValue(int value) : super(value);
}
```

### Controller

```dart
class CounterController extends RxCubit<CounterState> {
  CounterController() : super(const CounterInitial());

  void increment() => emit(CounterValue(state.value + 1));
  void reset() => emit(const CounterInitial());
}
```

### UI

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CounterController());
    return Scaffold(
      appBar: AppBar(title: const Text("Counter Example")),
      body: Center(
        child: GetXConsumer<CounterState>(
          observable: controller.state\$,
          builder: (context, state) {
            if (state is CounterValue) {
              return Text(
                "Count: \${state.value}",
                style: const TextStyle(fontSize: 32),
              );
            }
            return const Text("Press + to start");
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🎧 Listener Example

```dart
GetXListener<CounterState>(
  observable: controller.state\$,
  listenWhen: (prev, curr) => curr is CounterValue && curr.value == 5,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🎉 Count reached 5!")),
    );
  },
  child: GetXConsumer<CounterState>(
    observable: controller.state\$,
    builder: (context, state) {
      final value = state is CounterValue ? state.value : 0;
      return Text("Count: \$value", style: const TextStyle(fontSize: 28));
    },
  ),
)
```

---

## 🔄 API Fetching Example

### Controller

```dart
class ApiController extends RxCubit<RxState> {
  ApiController() : super(const RxInitial());

  @override
  void onInit(){
    super.onInit();
    fetchItems();
  }


  Future<void> fetchItems() async {
    emit(const RxLoading());
    await Future.delayed(const Duration(seconds: 2));
    try {
      final items = ["Apple", "Banana", "Mango"];
      emit(RxSuccess(items));
    } catch (e) {
      emit(RxError("Failed to fetch data"));
    }
  }
}
```

### UI

```dart
GetXConsumer<RxState>(
  observable: apiController.state,
  builder: (context, state) {
    if (state is RxLoading) {
      return const CircularProgressIndicator();
    } else if (state is RxSuccess<List<String>>) {
      return Column(
        children: state.data.map((e) => Text(e)).toList(),
      );
    } else if (state is RxError) {
      return Text("Error: ${state.message}");
    }
    return const Text("Press fetch to load items");
  },
)
```

---
