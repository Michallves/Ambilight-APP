import 'package:ambilight_app/layers/domain/usecases/change_color_usecase.dart';
import 'package:ambilight_app/layers/domain/usecases/turn_off_led_usecase.dart';
import 'package:ambilight_app/layers/domain/usecases/turn_on_led_usecase.dart';
import 'package:ambilight_app/layers/presentation/controller/led_controller.dart';
import 'package:get_it/get_it.dart';

class Inject {
  static void init() {
    _initUseCases();
    _initControllers();
  }

  static void _initUseCases() {
    GetIt getIt = GetIt.instance;

    // USERCASES

    getIt.registerLazySingleton<TurnOnLedUsecase>(
      () => TurnOnLedUsecaseImpl(),
    );

    getIt.registerLazySingleton<TurnOffLedUsecase>(
      () => TurnOffLedUsecaseImpl(),
    );

    getIt.registerLazySingleton<ChangeColorUsecase>(
      () => ChangeColorUsecaseImpl(),
    );
  }

  static void _initControllers() {
    GetIt getIt = GetIt.instance;

    // CONTROLLERS
    getIt.registerFactory<LedController>(
      () => LedController(getIt(), getIt(), getIt()),
    );
  }
}
