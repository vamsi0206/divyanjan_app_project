const getUserByMobileNumber = (connection, mobileNumber) => {
  const query = "SELECT * FROM applicant WHERE mobile_number = ? AND validity_id = '1'";
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
    'fathers_name',
    'date_of_birth',
    'registration_date',
    'status', // Add status
    'validity_id'
  ];
  const values = [
    userData.name,
    userData.mobile_number,
    userData.password,
    userData.email_id,
    userData.gender,
    userData.disability_type_id,
    userData.fathers_name,
    userData.date_of_birth,
    userData.registration_date,
    'draft', // Always set status to draft
    '1' // Set validity_id to '1' by default
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

const getApplicationByMobileNumber = async (connection, mobileNumber) => {
  // First, get applicant_id from applicant table
  const applicantQuery = "SELECT applicant_id FROM applicant WHERE mobile_number = ? AND validity_id = '1'";
  return new Promise((resolve, reject) => {
    connection.query(applicantQuery, [mobileNumber], (err, results) => {
      if (err) return reject(err);
      if (!results.length) return resolve({});
      const applicant_id = results[0].applicant_id;
      // Now get application(s) for this applicant_id
      const appQuery = "SELECT submission_date FROM application WHERE applicant_id = ? AND validity_id = '1'";
      connection.query(appQuery, [applicant_id], (err2, results2) => {
        if (err2) return reject(err2);
        resolve(results2[0] || {});
      });
    });
  });
};

const submitApplication = async (connection, mobileNumber, fields) => {
  // First, get applicant_id from applicant table
  const applicantQuery = "SELECT applicant_id FROM applicant WHERE mobile_number = ? AND validity_id = '1'";
  return new Promise((resolve, reject) => {
    connection.query(applicantQuery, [mobileNumber], (err, results) => {
      if (err) return reject(err);
      if (!results.length) return reject(new Error('Applicant not found'));
      const applicant_id = results[0].applicant_id;
      // Update applicant table
      const applicantSets = [];
      const values = [];
      for (const key in fields) {
        applicantSets.push(`${key} = ?`);
        values.push(fields[key]);
      }
      applicantSets.push("submitted = 'submitted'");
      const applicantSql = `UPDATE applicant SET ${applicantSets.join(', ')} WHERE mobile_number = ?`;
      values.push(mobileNumber);
      connection.query(applicantSql, values, (err) => {
        if (err) return reject(err);
        // Update application table using applicant_id
        const appSql = "UPDATE application SET submission_date = NOW() WHERE applicant_id = ?";
        connection.query(appSql, [applicant_id], (err2, result) => {
          if (err2) return reject(err2);
          resolve(result);
        });
      });
    });
  });
};

const updateApplicantDetailsById = (connection, applicantId, fields) => {
  const sets = [];
  const values = [];
  for (const key in fields) {
    sets.push(`${key} = ?`);
    values.push(fields[key]);
  }
  if (sets.length === 0) {
    return Promise.resolve();
  }
  const sql = `UPDATE applicant SET ${sets.join(', ')} WHERE applicant_id = ?`;
  values.push(applicantId);
  return new Promise((resolve, reject) => {
    connection.query(sql, values, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
};

const submitApplicationById = (connection, applicantId, fields) => {
  const applicantSets = [];
  const values = [];
  for (const key in fields) {
    applicantSets.push(`${key} = ?`);
    values.push(fields[key]);
  }
  applicantSets.push("submitted = 'submitted'");
  const applicantSql = `UPDATE applicant SET ${applicantSets.join(', ')} WHERE applicant_id = ?`;
  values.push(applicantId);
  return new Promise((resolve, reject) => {
    connection.query(applicantSql, values, (err) => {
      if (err) return reject(err);
      const appSql = "UPDATE application SET submission_date = NOW() WHERE applicant_id = ?";
      connection.query(appSql, [applicantId], (err2, result) => {
        if (err2) return reject(err2);
        resolve(result);
      });
    });
  });
};

const getApplicantStatusById = (connection, applicantId) => {
  const query = "SELECT status FROM applicant WHERE applicant_id = ? AND validity_id = '1'";
  return new Promise((resolve, reject) => {
    connection.query(query, [applicantId], (err, results) => {
      if (err) return reject(err);
      resolve(results.length > 0 ? results[0].status : null);
    });
  });
};

/**
 * Get the application_id for the given applicantId where validity_id=1
 * @param {object} connection - DB connection
 * @param {number} applicantId - Applicant ID
 * @returns {Promise<number|null>} - application_id or null
 */
const getActiveApplicationIdByApplicantId = async (connection, applicantId) => {
  const query = `SELECT application_id FROM Application WHERE applicant_id = ? AND validity_id = '1' LIMIT 1`;
  const [row] = await new Promise((resolve, reject) => {
    connection.query(query, [applicantId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  return row ? row.application_id : null;
};

/**
 * Get the division_name for a given city from DivisionCity table
 * @param {object} connection - DB connection
 * @param {string} city - City name
 * @returns {Promise<string|null>} - division_name or null
 */
const getDivisionByCity = async (connection, city) => {
  const query = `SELECT division_name FROM DivisionCity WHERE city = ? LIMIT 1`;
  const [row] = await new Promise((resolve, reject) => {
    connection.query(query, [city], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  return row ? row.division_name : null;
};

/**
 * Get the user_id of the level-1 employee for a given division from Railwayuser table
 * @param {object} connection - DB connection
 * @param {string} divisionId - Division name
 * @returns {Promise<number|null>} - user_id or null
 */
const getLevel1EmployeeForDivision = async (connection, divisionId) => {
  const query = `SELECT user_id FROM Railwayuser WHERE division_id = ? AND current_level = '1' AND validity_id = '1' LIMIT 1`;
  const [row] = await new Promise((resolve, reject) => {
    connection.query(query, [divisionId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  return row ? row.user_id : null;
};

module.exports = {
  getUserByMobileNumber,
  createUser,
  updateApplicantDetails,
  getApplicationByMobileNumber,
  submitApplication,
  updateApplicantDetailsById,
  submitApplicationById,
  getApplicantStatusById,
  getActiveApplicationIdByApplicantId,
  getDivisionByCity,
  getLevel1EmployeeForDivision,
};
