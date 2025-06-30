class UserSession{
  static final UserSession _instance=UserSession._internal();
      factory UserSession() => _instance;
      UserSession._internal();

      int? applicant_id ;

}