
const getUserByMobileNumber = (connection, mobileNumber) => {
  const query = "SELECT * FROM applicant WHERE mobile_number = ?";
  return new Promise((resolve, reject) => {
    connection.query(query, [mobileNumber], (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
};

const createUser = (connection, userData) => {
  const columns = [
    'name',
    'mobile_number',
    'password',
    'email_id',
    'gender',
    'disability_type_id',
    'registration_date'
  ];
  const values = [
    userData.name,
    userData.mobile_number,
    userData.password,
    userData.email_id,
    userData.gender,
    userData.disability_type_id,
    userData.registration_date
  ];
  const placeholders = columns.map(() => '?').join(', ');
  const query = `INSERT INTO applicant (${columns.join(',')}) VALUES (${placeholders})`;
  return new Promise((resolve, reject) => {
    connection.query(query, values, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
};

module.exports = { getUserByMobileNumber, createUser };
