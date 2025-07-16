// Action-related DB logic for applications

/**
 * Custom transfer logic for application transfer
 * @param {object} connection - DB connection
 * @param {number} applicationId - Application ID
 * @param {number} newEmployeeId - user_id of new current_processing_employee
 * @param {string} [comments] - Optional comments to add to ApplicationLog
 * @returns {Promise<object>} - Success or error message
 */
const transferApplication = async (connection, applicationId, newEmployeeId, comments) => {
  // 1. Get the latest ApplicationLog entry for this application (validity_id=1)
  const getLogQuery = `SELECT * FROM ApplicationLog WHERE application_id = ? AND validity_id = '1' ORDER BY log_id DESC LIMIT 1`;
  const [logEntry] = await new Promise((resolve, reject) => {
    connection.query(getLogQuery, [applicationId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  if (!logEntry) throw new Error('No valid ApplicationLog entry found');

  // 2. Invalidate the current log entry (set validity_id=0, level_passed_date=NOW(), status='assign')
  const invalidateLogQuery = `UPDATE ApplicationLog SET validity_id = '0', level_passed_date = NOW(), status = 'assign' WHERE log_id = ?`;
  await new Promise((resolve, reject) => {
    connection.query(invalidateLogQuery, [logEntry.log_id], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  // 3. Get the division_id of the new employee
  const getDivisionQuery = `SELECT division_id FROM Railwayuser WHERE user_id = ? AND validity_id = '1'`;
  const [divisionRow] = await new Promise((resolve, reject) => {
    connection.query(getDivisionQuery, [newEmployeeId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  if (!divisionRow) throw new Error('No such employee or employee is not valid');

  // 4. Insert a new ApplicationLog entry (same current_level, assign_date=NOW, status='pending', validity_id=1, new employee)
  const insertLogQuery = `INSERT INTO ApplicationLog (application_id, status, current_level, assign_date, validity_id, current_processing_employee) VALUES (?, 'pending', ?, NOW(), '1', ?)`;
  await new Promise((resolve, reject) => {
    connection.query(insertLogQuery, [applicationId, logEntry.current_level, newEmployeeId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  // 4b. If comments is provided (even empty string), update comments for the latest ApplicationLog entry
  if (typeof comments !== 'undefined') {
    // Get the latest log_id (the one just inserted)
    const getLatestLogQuery = `SELECT log_id FROM ApplicationLog WHERE application_id = ? ORDER BY log_id DESC LIMIT 1`;
    const [latestLog] = await new Promise((resolve, reject) => {
      connection.query(getLatestLogQuery, [applicationId], (err, results) => {
        if (err) return reject(err);
        resolve(results);
      });
    });
    if (latestLog) {
      const updateCommentsQuery = `UPDATE ApplicationLog SET comments = ? WHERE log_id = ?`;
      await new Promise((resolve, reject) => {
        connection.query(updateCommentsQuery, [comments, latestLog.log_id], (err) => {
          if (err) return reject(err);
          resolve();
        });
      });
    }
  }

  // 5. Update Application table (set current_processing_employee, division_id, process_date=NOW())
  const updateAppQuery = `UPDATE Application SET current_processing_employee = ?, division_id = ?, process_date = NOW() WHERE application_id = ?`;
  await new Promise((resolve, reject) => {
    connection.query(updateAppQuery, [newEmployeeId, divisionRow.division_id, applicationId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  return { success: true, message: 'Application transferred successfully' };
};

module.exports = {
  transferApplication
}; 