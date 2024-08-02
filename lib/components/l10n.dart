mixin AppLocale {
  static const String welcome = 'welcome';
  static const String ble = 'bluetooth';
  static const String save = 'save';
  static const String control = 'control';
  static const String assistant = 'Voice Chat';
  static const String med = "Pill dispensing";
  static const String settings = "Settings";
  static const String login = "Login";
  static const String signup = "Sign Up";
  static const String home = 'Home';

  static const Map<String, dynamic> EN = {
    welcome: 'welcome',
    ble: 'bluetooth',
    save: 'save',
    control: 'control',
    assistant: 'Voice Chat',
    med: 'Pill dispensing',
    settings: 'Settings',
    login: 'Login',
    signup: 'Sign up',
    home: "Home",
  };

  static const Map<String, dynamic> CN = {
    welcome: '欢迎回来!',
    ble: '蓝牙',
    save: '保存',
    control: '遥控',
    assistant: "人工智能助手",
    med: '配药',
    settings: '设置',
    login: '登录',
    signup: '报名',
    home: '主页'
  };
}