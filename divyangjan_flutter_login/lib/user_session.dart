class UserSession{
  static final UserSession _instance=UserSession._internal();
      factory UserSession() => _instance;
      UserSession._internal();

      String? selectedApplicantId;
      int? applicant_id ;
      int? level_user;
      int? staff_id;
      String? division_id;


}