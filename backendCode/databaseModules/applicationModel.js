const getAllPendingApplications =(connection)=>{
    const query="SELECT * from Application WHERE status = 'submitted' AND validity_id = '1'";
    return new Promise((resolve, reject) => {
    connection.query(query, (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}

const getApplicationsByEmployeeId = (connection, employeeId) => {
    const query = `
        SELECT DISTINCT a.*, 
            DATE_FORMAT(a.submission_date, '%Y-%m-%d') as submission_date_formatted,
            al.current_level, al.status as log_status,
            app.city as applicant_city, app.name as applicant_name, app.mobile_number as applicant_mobile_number
        FROM Application a
        INNER JOIN ApplicationLog al ON a.application_id = al.application_id
        INNER JOIN Applicant app ON a.applicant_id = app.applicant_id
        WHERE a.current_processing_employee = ? 
        AND al.validity_id = '1'
        AND a.validity_id = '1'
        ORDER BY a.submission_date DESC
    `;
    
    return new Promise((resolve, reject) => {
        connection.query(query, [employeeId], (err, results) => {
            if (err) {
                return reject(err);
            }
            // Replace submission_date with formatted value (date only)
            const formattedResults = results.map(row => {
                if (row.submission_date_formatted) {
                    row.submission_date = row.submission_date_formatted;
                    delete row.submission_date_formatted;
                }
                return row;
            });
            resolve(formattedResults);
        });
    });
}

const getApplicationsByEmployeeLevel = (connection, employeeLevel, employeeDivision) => {
    // Convert employee level to the level they can process (one below their level)
    const processableLevel = getProcessableLevel(employeeLevel);
    
    const query = `
        SELECT DISTINCT a.*, 
            DATE_FORMAT(a.submission_date, '%Y-%m-%d') as submission_date_formatted,
            al.current_level, al.status as log_status,
            app.city as applicant_city, app.name as applicant_name, app.mobile_number as applicant_mobile_number
        FROM Application a
        INNER JOIN ApplicationLog al ON a.application_id = al.application_id
        INNER JOIN Applicant app ON a.applicant_id = app.applicant_id
        WHERE al.current_level = ? 
        AND a.division_id = ?
        AND al.validity_id = '1'
        AND a.validity_id = '1'
        ORDER BY a.submission_date DESC
    `;
    
    return new Promise((resolve, reject) => {
        connection.query(query, [processableLevel, employeeDivision], (err, results) => {
            if (err) {
                return reject(err);
            }
            // Replace submission_date with formatted value (date only)
            const formattedResults = results.map(row => {
                if (row.submission_date_formatted) {
                    row.submission_date = row.submission_date_formatted;
                    delete row.submission_date_formatted;
                }
                return row;
            });
            resolve(formattedResults);
        });
    });
}

const getApplicantApplications = (connection, applicantId) => {
    const query = `
        SELECT 
            a.application_id, a.submission_date, a.process_date, a.status,
            a.division_id, a.card_number, a.card_issue_date, 
            a.card_issue_valid_till, a.concession_card_validity, 
            a.Authorname,
            a.doctor_name, a.doctor_reg_no, a.hospital_name, a.hospital_city,
            a.hospital_state, a.certificate_issue_date, a.validity_id,
            a.concession_certificate, a.photograph, a.disability_certificate, a.dob_proof_type, a.dob_proof_upload, a.photoId_proof_type, a.photoId_proof_upload, a.address_proof_type, a.address_proof_upload, a.district,
            app.name, app.mobile_number, app.email_id, app.gender,
            app.disability_type_id, app.address, app.pin_code, app.city,
            app.statename, app.fathers_name,
            DATE_FORMAT(app.date_of_birth, '%Y-%m-%d') as date_of_birth,
            al.current_level, al.status as log_status, al.comments,
            a.current_processing_employee,
            ru.name as current_processing_employee_name
        FROM Application a
        INNER JOIN Applicant app ON a.applicant_id = app.applicant_id
        LEFT JOIN ApplicationLog al ON a.application_id = al.application_id 
            AND al.validity_id = '1'
        LEFT JOIN Railwayuser ru ON a.current_processing_employee = ru.user_id AND ru.validity_id = '1'
        WHERE a.applicant_id = ? 
        AND a.validity_id = '1'
        ORDER BY a.submission_date DESC
    `;
    
    return new Promise((resolve, reject) => {
        connection.query(query, [applicantId], (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results);
        });
    });
}

// Helper function to determine which level an employee can process
const getProcessableLevel = (employeeLevel) => {
    const levelMap = {
        '1': '0',  // Level 1 employee processes applicant level
        '2': '1',          // Level 2 employee processes level 1
        '3': '2'           // Level 3 employee processes level 2
    };
    return levelMap[employeeLevel] || 'applicant';
}

const getFilteredPendingApplications = (connection,filters = {}) => {
    let query = "SELECT * FROM Application WHERE validity_id = '1'";
    const params = [];
    
    // Handle multiple status values
    if (filters.status) {
        if (Array.isArray(filters.status)) {
            const placeholders = filters.status.map(() => '?').join(',');
            query += ` AND status IN (${placeholders})`;
            params.push(...filters.status);
        } else {
            query += " AND status = ?";
            params.push(filters.status);
        }
    }
    
    // Handle other single value filters
    const singleValueFields = [
        'applicant_id', 'division_id', 'current_division_user_id',
        'current_cmi_id', 'current_cis_id', 'card_number'
    ];
    
    singleValueFields.forEach(field => {
        if (filters[field]) {
            query += ` AND ${field} = ?`;
            params.push(filters[field]);
        }
    });
    
    // Handle date ranges
    if (filters.submission_date_from) {
        query += " AND submission_date >= ?";
        params.push(filters.submission_date_from);
    }
    
    if (filters.submission_date_to) {
        query += " AND submission_date <= ?";
        params.push(filters.submission_date_to);
    }
    
    // Handle search in card_number (partial match)
    if (filters.card_number_search) {
        query += " AND card_number LIKE ?";
        params.push(`%${filters.card_number_search}%`);
    }
    
    // Add ordering and pagination
    query += " ORDER BY submission_date DESC";
    
    if (filters.limit) {
        query += " LIMIT ?";
        params.push(parseInt(filters.limit));
        
        if (filters.offset) {
            query += " OFFSET ?";
            params.push(parseInt(filters.offset));
        }
    }
    
    return new Promise((resolve, reject) => {
        connection.query(query, params, (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results);
        });
    });
};

const viewApplicationById= (applicationId,connection)=>{
  const query="SELECT * from Application WHERE application_id= ? AND validity_id = '1'";
    return new Promise((resolve, reject) => {
    connection.query(query,[applicationId], (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}

//may need to modify database query processing based on datatype
const setApplicationStatus = (connection, applicationId, actionType) => {
  return new Promise((resolve, reject) => {
    if (actionType === 'rejected') {
      // Set validity_id = '0' and status = 'rejected' in Application and ApplicationLog
      // Set validity_id = '0' in DisabilityCertificate
      const updateQueries = [
        "UPDATE Application SET validity_id = '0', status = 'rejected' WHERE application_id = ?",
        "UPDATE ApplicationLog SET validity_id = '0', status = 'rejected' WHERE application_id = ?",
        "UPDATE DisabilityCertificate SET validity_id = '0' WHERE application_id = ?"
      ];
      const updatePromises = updateQueries.map(query => {
        return new Promise((resolve, reject) => {
          connection.query(query, [applicationId], (err) => {
            if (err) {
              console.error('Error updating validity_id/status:', err);
            }
            resolve();
          });
        });
      });
      Promise.all(updatePromises)
        .then(() => {
          resolve({ success: true, message: `Application rejected and validity_id set to 0` });
        })
        .catch(reject);
    } else {
      // Set status = actionType and validity_id = '1' in Application
      const updateAppQuery = "UPDATE Application SET status = ?, validity_id = '1' WHERE application_id = ?";
      connection.query(updateAppQuery, [actionType, applicationId], (err) => {
        if (err) {
          return reject(err);
        }
        // Set validity_id = '0' in all ApplicationLog rows for the application
        const invalidateLogsQuery = "UPDATE ApplicationLog SET validity_id = '0' WHERE application_id = ?";
        connection.query(invalidateLogsQuery, [applicationId], (err) => {
          if (err) {
            return reject(err);
          }
          // Get the latest current_level for this application
          const getLevelQuery = "SELECT current_level FROM ApplicationLog WHERE application_id = ? ORDER BY log_id DESC LIMIT 1";
          connection.query(getLevelQuery, [applicationId], (err, results) => {
            if (err) {
              return reject(err);
            }
            let newLevel = '1';
            if (results.length > 0) {
              newLevel = incrementLevel(results[0].current_level);
            }
            // Update level_passed_date for the old log entry (most recent one)
            const updateLevelPassedQuery = "UPDATE ApplicationLog SET level_passed_date = NOW() WHERE application_id = ? AND log_id = (SELECT log_id FROM (SELECT log_id FROM ApplicationLog WHERE application_id = ? ORDER BY log_id DESC LIMIT 1) AS temp)";
            connection.query(updateLevelPassedQuery, [applicationId, applicationId], (err) => {
              if (err) {
                console.error('Error updating level_passed_date:', err);
              }
              // Insert a new ApplicationLog row with incremented current_level, validity_id = '1', and status = actionType
              const insertLogQuery = "INSERT INTO ApplicationLog (application_id, status, current_level, validity_id, assign_date) VALUES (?, ?, ?, '1', NOW())";
              connection.query(insertLogQuery, [applicationId, actionType, newLevel], (err) => {
                if (err) {
                  return reject(err);
                }
                resolve({ success: true, message: `Application status updated to ${actionType} and new log row created` });
              });
            });
          });
        });
      });
    }
  });
};

/**
 * Approve application with custom logic: invalidate old log, create new log, update application.
 * @param {object} connection - DB connection
 * @param {number} applicationId - Application ID
 * @param {number} nextEmployeeId - user_id of next current_processing_employee
 * @param {string} [comments] - Optional comments to add to ApplicationLog
 * @param {string} [card_issue_date] - Optional card issue date (YYYY-MM-DD)
 * @param {string} [card_issue_valid_till] - Optional card valid till date (YYYY-MM-DD)
 * @param {string} [concession_card_validity] - Optional card validity string (e.g., '5 years', 'lifetime')
 * @returns {Promise<object>} - Success or error message
 */
const approveApplication = async (connection, applicationId, nextEmployeeId, comments, card_issue_date, card_issue_valid_till, concession_card_validity) => {
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

  // 3. Insert a new ApplicationLog entry (incremented current_level, assign_date=NOW, status='pending', validity_id=1, new employee or null)
  const newLevel = incrementLevel(logEntry.current_level);
  const insertLogQuery = `INSERT INTO ApplicationLog (application_id, status, current_level, assign_date, validity_id, current_processing_employee) VALUES (?, 'pending', ?, NOW(), '1', ?)`;
  await new Promise((resolve, reject) => {
    connection.query(insertLogQuery, [applicationId, newLevel, nextEmployeeId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  // 3b. If comments is provided (even empty string), update comments for the latest ApplicationLog entry
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

  // 4. Update Application table (set current_processing_employee, process_date=NOW(), and if current_level=2, also update card_issue_date, card_issue_valid_till, concession_card_validity)
  if (logEntry.current_level === '2' || logEntry.current_level === 2) {
    // Set status in Application and ApplicationLog to 'card_generated', and Applicant to 'approved'
    const updateAppQuery = `UPDATE Application SET current_processing_employee = ?, process_date = NOW(), card_issue_date = ?, card_issue_valid_till = ?, concession_card_validity = ?, status = 'card_generated' WHERE application_id = ?`;
    await new Promise((resolve, reject) => {
      connection.query(updateAppQuery, [nextEmployeeId, card_issue_date || null, card_issue_valid_till || null, concession_card_validity || null, applicationId], (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
    // Set status in ApplicationLog to 'card_generated' for the latest log
    const getLatestLogQuery = `SELECT log_id FROM ApplicationLog WHERE application_id = ? ORDER BY log_id DESC LIMIT 1`;
    const [latestLog] = await new Promise((resolve, reject) => {
      connection.query(getLatestLogQuery, [applicationId], (err, results) => {
        if (err) return reject(err);
        resolve(results);
      });
    });
    if (latestLog) {
      const updateLogStatusQuery = `UPDATE ApplicationLog SET status = 'card_generated' WHERE log_id = ?`;
      await new Promise((resolve, reject) => {
        connection.query(updateLogStatusQuery, [latestLog.log_id], (err) => {
          if (err) return reject(err);
          resolve();
        });
      });
    }
    // Set status in Applicant to 'approved'
    const getApplicantIdQuery = `SELECT applicant_id FROM Application WHERE application_id = ?`;
    const [row] = await new Promise((resolve, reject) => {
      connection.query(getApplicantIdQuery, [applicationId], (err, results) => {
        if (err) return reject(err);
        resolve(results);
      });
    });
    if (row && row.applicant_id) {
      const updateApplicantQuery = `UPDATE Applicant SET status = 'approved' WHERE applicant_id = ?`;
      await new Promise((resolve, reject) => {
        connection.query(updateApplicantQuery, [row.applicant_id], (err) => {
          if (err) return reject(err);
          resolve();
        });
      });
    }
    // Insert into concessionCardsIssued (always insert, do not check for existence)
    // 1. Get the updated Application row joined with Applicant
    const getAppRowQuery = `SELECT a.*, app.name, app.gender, app.date_of_birth, app.disability_type_id FROM Application a INNER JOIN Applicant app ON a.applicant_id = app.applicant_id WHERE a.application_id = ?`;
    const [appRow] = await new Promise((resolve, reject) => {
      connection.query(getAppRowQuery, [applicationId], (err, results) => {
        if (err) return reject(err);
        resolve(results);
      });
    });
    // Always insert a new card
    const insertCardQuery = `INSERT INTO concessionCardsIssued (name, gender, date_of_birth, hospital_name, doctor_name, doctor_reg_no, disability_type_id, card_issue_date, card_issue_valid_till, certificate_issue_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
    const cardValues = [
      appRow.name,
      appRow.gender,
      appRow.date_of_birth,
      appRow.hospital_name,
      appRow.doctor_name,
      appRow.doctor_reg_no,
      appRow.disability_type_id,
      appRow.card_issue_date,
      appRow.card_issue_valid_till,
      appRow.certificate_issue_date
    ];
    const result = await new Promise((resolve, reject) => {
      connection.query(insertCardQuery, cardValues, (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
    const cardNumber = result.insertId;
    // Update Application.card_number
    const updateCardNumberQuery = `UPDATE Application SET card_number = ? WHERE application_id = ?`;
    await new Promise((resolve, reject) => {
      connection.query(updateCardNumberQuery, [cardNumber, applicationId], (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  } else {
    const updateAppQuery = `UPDATE Application SET current_processing_employee = ?, process_date = NOW() WHERE application_id = ?`;
    await new Promise((resolve, reject) => {
      connection.query(updateAppQuery, [nextEmployeeId, applicationId], (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  }

  return { success: true, message: 'Application approved and moved to next level' };
};

/**
 * Reject application with custom logic: invalidate application/log, update comments, set applicant status to draft.
 * @param {object} connection - DB connection
 * @param {number} applicationId - Application ID
 * @param {string} comments - Comments to add to ApplicationLog
 * @returns {Promise<object>} - Success or error message
 */
const rejectApplication = async (connection, applicationId, comments) => {
  // 1. Set validity_id=0 and status='rejected' in Application and ApplicationLog
  const updateAppQuery = `UPDATE Application SET validity_id = '0', status = 'rejected' WHERE application_id = ?`;
  await new Promise((resolve, reject) => {
    connection.query(updateAppQuery, [applicationId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });
  const updateLogQuery = `UPDATE ApplicationLog SET validity_id = '0', status = 'rejected' WHERE application_id = ?`;
  await new Promise((resolve, reject) => {
    connection.query(updateLogQuery, [applicationId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });
  // 2. Update comments in the latest ApplicationLog entry (validity_id=1)
  const getLatestLogQuery = `SELECT log_id FROM ApplicationLog WHERE application_id = ? ORDER BY log_id DESC LIMIT 1`;
  const [latestLog] = await new Promise((resolve, reject) => {
    connection.query(getLatestLogQuery, [applicationId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  if (latestLog && comments) {
    const updateCommentsQuery = `UPDATE ApplicationLog SET comments = ? WHERE log_id = ?`;
    await new Promise((resolve, reject) => {
      connection.query(updateCommentsQuery, [comments, latestLog.log_id], (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  }
  // 3. Set status='rejected' in applicant table for the applicant associated with the application
  const getApplicantIdQuery = `SELECT applicant_id FROM Application WHERE application_id = ?`;
  const [row] = await new Promise((resolve, reject) => {
    connection.query(getApplicantIdQuery, [applicationId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  if (row && row.applicant_id) {
    const updateApplicantQuery = `UPDATE applicant SET status = 'rejected' WHERE applicant_id = ?`;
    await new Promise((resolve, reject) => {
      connection.query(updateApplicantQuery, [row.applicant_id], (err) => {
        if (err) return reject(err);
        resolve();
      });
    });
  }
  return { success: true, message: 'Application rejected, comments updated, applicant status set to draft' };
};

// Helper to increment the current_level
function incrementLevel(currentLevel) {
  if (currentLevel === 'applicant' || currentLevel === '0') return '1';
  if (currentLevel === '1') return '2';
  if (currentLevel === '2') return '3';
  return currentLevel; // If already at max, stay
}

/**
 * Get the user_id of the next level employee for a given division.
 * @param {object} connection - DB connection
 * @param {string} divisionId - Division name/id
 * @param {string|number} currentLevel - Current level as string or number
 * @returns {Promise<number|null>} - user_id of next level employee or null
 */
const getNextLevelEmployeeForDivision = async (connection, divisionId, currentLevel) => {
  let nextLevel = null;
  if (currentLevel === '0' || currentLevel === 0) nextLevel = '2';
  else if (currentLevel === '1' || currentLevel === 1) nextLevel = '3';
  else return null; // No next level for 2->3 or 3->null
  const query = `SELECT user_id FROM Railwayuser WHERE division_id = ? AND current_level = ? AND validity_id = '1' LIMIT 1`;
  const [row] = await new Promise((resolve, reject) => {
    connection.query(query, [divisionId, nextLevel], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  return row ? row.user_id : null;
};

/**
 * Submit application with custom logic: if current_level is 0, require current_processing_employee; if 1 or 2, auto-assign next level employee; if 3, return null.
 * @param {object} connection - DB connection
 * @param {number} applicationId - Application ID
 * @param {number} nextEmployeeId - user_id of next current_processing_employee (required only for level 0)
 * @returns {Promise<object|null>} - Success or error message, or null if at max level
 */
const submitApplicationAction = async (connection, applicationId, nextEmployeeId) => {
  // 1. Get the latest ApplicationLog entry for this application (validity_id=1)
  const getLogQuery = `SELECT * FROM ApplicationLog WHERE application_id = ? AND validity_id = '1' ORDER BY log_id DESC LIMIT 1`;
  const [logEntry] = await new Promise((resolve, reject) => {
    connection.query(getLogQuery, [applicationId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
  if (!logEntry) throw new Error('No valid ApplicationLog entry found');

  let assignedEmployeeId = null;
  if (logEntry.current_level === '0' || logEntry.current_level === 0) {
    // Require nextEmployeeId for level 0
    if (!nextEmployeeId) throw new Error('current_processing_employee is required for submit action at level 0');
    assignedEmployeeId = nextEmployeeId;
  } else if (logEntry.current_level === '1' || logEntry.current_level === 1 || logEntry.current_level === '2' || logEntry.current_level === 2) {
    // Auto-assign next level employee for the division
    const getDivisionQuery = `SELECT division_id FROM Application WHERE application_id = ?`;
    const [appRow] = await new Promise((resolve, reject) => {
      connection.query(getDivisionQuery, [applicationId], (err, results) => {
        if (err) return reject(err);
        resolve(results);
      });
    });
    if (!appRow) throw new Error('Application division not found');
    assignedEmployeeId = await getNextLevelEmployeeForDivision(connection, appRow.division_id, logEntry.current_level);
    if (!assignedEmployeeId) return null; // No next level employee (level 3)
  } else if (logEntry.current_level === '3' || logEntry.current_level === 3) {
    // At max level, do not proceed
    return null;
  }

  // 2. Invalidate the current log entry (set validity_id=0, level_passed_date=NOW(), status='assign')
  const invalidateLogQuery = `UPDATE ApplicationLog SET validity_id = '0', level_passed_date = NOW(), status = 'assign' WHERE log_id = ?`;
  await new Promise((resolve, reject) => {
    connection.query(invalidateLogQuery, [logEntry.log_id], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  // 3. Insert a new ApplicationLog entry (incremented current_level, assign_date=NOW, status='pending', validity_id=1, new employee)
  const newLevel = incrementLevel(logEntry.current_level);
  const insertLogQuery = `INSERT INTO ApplicationLog (application_id, status, current_level, assign_date, validity_id, current_processing_employee) VALUES (?, 'pending', ?, NOW(), '1', ?)`;
  await new Promise((resolve, reject) => {
    connection.query(insertLogQuery, [applicationId, newLevel, assignedEmployeeId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  // 4. Update Application table (set current_processing_employee, process_date=NOW())
  const updateAppQuery = `UPDATE Application SET current_processing_employee = ?, process_date = NOW() WHERE application_id = ?`;
  await new Promise((resolve, reject) => {
    connection.query(updateAppQuery, [assignedEmployeeId, applicationId], (err) => {
      if (err) return reject(err);
      resolve();
    });
  });

  return { success: true, message: 'Application submitted and moved to next level' };
};

// Fetch Railwayuser by user_id
const getRailwayUserById = (connection, userId) => {
    const query = `SELECT * FROM Railwayuser WHERE user_id = ? AND validity_id = '1'`;
    return new Promise((resolve, reject) => {
        connection.query(query, [userId], (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results && results.length > 0 ? results[0] : null);
        });
    });
};

module.exports = {
  getAllPendingApplications,
  getApplicationsByEmployeeLevel,
  getApplicationsByEmployeeId,
  getApplicantApplications,
  getFilteredPendingApplications,
  viewApplicationById,
  setApplicationStatus,
  getRailwayUserById,
  approveApplication,
  rejectApplication,
  getNextLevelEmployeeForDivision,
  submitApplicationAction
};
