import 'package:authentication/auth_repository.dart';
import 'package:authentication/firebase_auth_exceptions.dart';
import 'package:authentication/form_inputs/email.dart';
import 'package:authentication/form_inputs/password.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(email: email, isValid: Formz.validate([email, state.password])));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(password: password, isValid: Formz.validate([state.email, password])));
  }

  Future<void> logInWithCredentials() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(errorMessage: e.message,status: FormzSubmissionStatus.failure));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithGoogleFailure catch (e) {
      emit(state.copyWith(errorMessage: e.message, status: FormzSubmissionStatus.failure));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}