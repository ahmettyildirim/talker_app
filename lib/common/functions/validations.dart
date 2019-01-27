class Validations {
  static String validatePass(String value) {
    if (value.isEmpty) {
      return 'Please Enter Your Password';
    }
    return null;
  }
 static String validatePassRepeat(String value1,value2) {
    if (value1 != value2) {
      return 'Passwords are not matching';
    }
    return null;
  }
  static String validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please Enter Your Email';
    }
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Please Enter Valid Email';
    else
      return null;
  }
}
