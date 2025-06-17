
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

const updateApplicantDetails = (connection, mobileNumber, fields) => {
  const sets = [];
  const values = [];
  for (const key in fields) {
    sets.push(`${key} = ?`);
    values.push(fields[key]);
  }
  if (sets.length === 0) {
    return Promise.resolve();
  }
  const sql = `UPDATE applicant SET ${sets.join(', ')} WHERE mobile_number = ?`;
  values.push(mobileNumber);
  return new Promise((resolve, reject) => {
    connection.query(sql, values, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
};

module.exports = { getUserByMobileNumber, createUser, updateApplicantDetails };
