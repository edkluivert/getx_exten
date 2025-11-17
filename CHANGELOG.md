# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.3] - 2025-11-18

### 🎉 Major Release - Complete Architecture Overhaul

This release represents a complete rewrite of the package, removing tight coupling to base state classes and embracing GetX's reactive capabilities while maintaining BLoC-like patterns.

### ✨ Added

#### Core State Management
- **`RxCubit<S>`** - Cubit implementation that works with ANY state type (no base class required)
    - Supports primitives: `int`, `String`, `bool`, `double`
    - Supports custom classes without inheritance
    - Supports nullable types: `String?`, `MyClass?`
    - Supports collections: `List<T>`, `Map<K,V>`, `Set<T>`
    - Exposes `rx` property for direct reactive access
    - Includes `onChange` lifecycle hook

- **`RxBloc<E, S>`** - BLoC implementation with event-driven architecture
    - Works with any state type
    - Event handler registration with `on<Event>(handler)`
    - Async event handling support
    - Exposes `rx` property for direct reactive access

#### Reactive Widgets
- **`GetChanger<S>`** - Pure builder widget that rebuilds on state changes
    - Works with `Rx<T>`, `RxCubit<S>`, or `RxBloc<E, S>`
    - Optional `buildWhen` condition for fine-grained control
    - Optimized to prevent unnecessary builder calls
    - Uses `ever` worker for efficient state tracking

- **`GetListenerWidget<S>`** - Side-effect widget without rebuilding
    - Executes listeners without triggering widget rebuilds
    - Optional `listenWhen` condition for selective listening
    - Perfect for navigation, snackbars, dialogs
    - Works with `Rx<T>`, `RxCubit<S>`, or `RxBloc<E, S>`

- **`GetConsumer<S>`** - Combined listener and builder widget
    - Independent `buildWhen` and `listenWhen` conditions
    - Calls listener on initial state
    - Optimized to prevent unnecessary rebuilds
    - Ideal for complex UI with side effects

- **`GetSelector<S, T>`** - Fine-grained reactive builder
    - Only rebuilds when selected value changes
    - Dramatically improves performance for large state objects
    - Works with any selector function
    - Prevents unnecessary rebuilds when unrelated state changes

- **`GetMultiChanger`** - Multi-source reactive builder
    - Reacts to changes from multiple `Rx` sources
    - Combines state from different cubits/blocs
    - Handles empty source lists gracefully
    - Perfect for widgets that depend on multiple state sources

#### Extensions
- **`RxCubit.select<T>()`** - Create selector widgets fluently
  ```dart
  cubit.select(
    (state) => state.name,
    (context, name) => Text(name),
  )
  ```

- **`RxCubit.watch()`** - Imperatively watch state changes
  ```dart
  final worker = cubit.watch((state) => print(state));
  ```

- **`RxBloc.select<T>()`** - Create selector widgets for blocs
- **`RxBloc.watch()`** - Imperatively watch bloc state changes

### 🔄 Changed

#### Breaking Changes
- **Removed `RxState` base class requirement** - State can now be ANY type
    - **Before**: All states had to extend `RxState`
  ```dart
  class MyState extends RxState { ... }
  class MyCubit extends RxCubit<MyState> { ... }
  ```
    - **After**: Use any type directly
  ```dart
  class MyCubit extends RxCubit<int> { ... }
  class MyCubit extends RxCubit<MyClass> { ... }
  ```

- **Removed generic state classes** - `RxInitial`, `RxLoading`, `RxSuccess`, `RxError` are no longer included
    - **Migration**: Define your own state classes as needed
  ```dart
  // Before
  emit(RxLoading());
  
  // After - Define your own
  sealed class MyState {}
  class Loading extends MyState {}
  class Success extends MyState { final data; Success(this.data); }
  emit(Loading());
  ```

- **Widget constructors now require explicit source** - Must provide either `rx` or `controller`
    - **Before**: Only supported controller
  ```dart
  GetConsumer<int>(controller: cubit, ...)
  ```
    - **After**: Support both direct Rx and controllers
  ```dart
  GetChanger<int>(rx: count.obs, ...)
  GetChanger<int>(controller: cubit, ...)
  ```

- **Renamed `GetListener` to `GetListenerWidget`** - Clearer distinction from the typedef
    - **Before**: `GetListener<S>(...)`
    - **After**: `GetListenerWidget<S>(...)`

#### Performance Improvements
- Widgets now use `ever` workers instead of `Obx` for better control
- Builder functions only called when conditions are met
- Selector widget prevents rebuilds when selected value unchanged
- Cached widget approach eliminated in favor of state tracking

### 📚 Documentation
- Comprehensive test suite with 100+ test cases
- Integration tests covering real-world scenarios
- Detailed inline documentation for all public APIs
- Examples for every widget and feature

### 🐛 Fixed
- Fixed `buildWhen` not preventing builder calls in `GetChanger`
- Fixed `listenWhen` and `buildWhen` interfering with each other in `GetConsumer`
- Fixed `GetSelector` rebuilding on every state change
- Fixed `GetMultiChanger` error when sources list is empty
- Fixed initial state handling in all widgets
- Fixed memory leaks by properly disposing workers

### 🏗️ Architecture
- Decoupled from specific state base classes
- Leverages GetX's reactive system more effectively
- Follows BLoC patterns while maintaining GetX simplicity
- Clear separation of concerns between listening and building

### 📦 Dependencies
- Updated GetX dependency to latest version
- Minimum Flutter SDK: 3.0.0
- Minimum Dart SDK: 3.0.0

---

## [1.0.0] - 2024-XX-XX

### Initial Release
- Basic `RxCubit` with `RxState` requirement
- Basic `RxBloc` with `RxState` requirement
- `GetConsumer` widget
- `GetListener` widget
- Generic state classes (`RxInitial`, `RxLoading`, `RxSuccess`, `RxError`)

---

## Migration Guide (1.x → 2.x)

### 1. Remove RxState inheritance
```dart
// Before (1.x)
class CounterState extends RxState {
  final int count;
  CounterState(this.count);
}

class CounterCubit extends RxCubit<CounterState> {
  CounterCubit() : super(CounterState(0));
  void increment() => emit(CounterState(state.count + 1));
}

// After (2.x) - Use primitives directly
class CounterCubit extends RxCubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

// Or keep your custom class (no inheritance needed)
class CounterState {
  final int count;
  CounterState(this.count);
}

class CounterCubit extends RxCubit<CounterState> {
  CounterCubit() : super(CounterState(0));
  void increment() => emit(CounterState(state.count + 1));
}
```

### 2. Update widget names
```dart
// Before (1.x)
GetListener<MyState>(
controller: cubit,
listener: (context, state) { },
child: MyWidget(),
)

// After (2.x)
GetListenerWidget<MyState>(
controller: cubit,
listener: (context, state) { },
child: MyWidget(),
)
```

### 3. Replace generic states
```dart
// Before (1.x)
emit(RxLoading());
emit(RxSuccess(data));
emit(RxError('Failed'));

// After (2.x) - Define your own sealed classes
sealed class MyState {}
class Loading extends MyState {}
class Success extends MyState {
final Data data;
Success(this.data);
}
class Error extends MyState {
final String message;
Error(this.message);
}

emit(Loading());
emit(Success(data));
emit(Error('Failed'));
```

### 4. Leverage new features
```dart
// Use GetChanger for simpler building
GetChanger<int>(
controller: counterCubit,
builder: (context, count) => Text('$count'),
)

// Use GetSelector for performance
GetSelector<UserState, String>(
controller: userCubit,
selector: (state) => state.name,
builder: (context, name) => Text(name),
)

// Use direct Rx values
final count = 0.obs;
GetChanger<int>(
rx: count,
builder: (context, value) => Text('$value'),
)
```

---

**Full Changelog**: https://github.com/edkluivert/getx_exten/compare/v1.0.0...v2.0.0