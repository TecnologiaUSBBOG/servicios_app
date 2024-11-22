class AuthManager {
  static bool isLoggedIn = false;

  static void login() {
    // Se establece isLoggedIn en true para simular un inicio de sesión exitoso
    isLoggedIn = true;
  }

  static void logout() {
    // Se establece isLoggedIn en false para simular el cierre de sesión
    isLoggedIn = false;
  }
}
