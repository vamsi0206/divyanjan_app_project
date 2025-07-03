const getAllPendingApplications =(connection)=>{
    const query="SELECT * from Application WHERE status =submitted ";
    return new Promise((resolve, reject) => {
    connection.query(query, (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}

const getApplicationsByEmployeeLevel = (connection, employeeLevel, employeeId) => {
    // Convert employee level to the level they can process (one below their level)
    const processableLevel = getProcessableLevel(employeeLevel);
    
    const query = `
        SELECT DISTINCT a.*, al.current_level, al.status as log_status
        FROM Application a
        INNER JOIN ApplicationLog al ON a.application_id = al.application_id
        WHERE al.current_level = ? 
        AND al.validity_id = '1'
        AND a.validity_id = '1'
        ORDER BY a.submission_date DESC
    `;
    
    return new Promise((resolve, reject) => {
        connection.query(query, [processableLevel], (err, results) => {
            if (err) {
                return reject(err);
            }
            resolve(results);
        });
    });
}

const getApplicantApplications = (connection, applicantId) => {
    const query = `
        SELECT 
            a.application_id, a.submission_date, a.process_date, a.status,
            a.current_division_id, a.card_number, a.card_issue_date, a.Authorname,
            a.doctor_name, a.doctor_reg_no, a.hospital_name, a.hospital_city,
            a.hospital_state, a.certificate_issue_date, a.validity_id,
            a.concession_certificate, a.photograph, a.disability_certificate, a.dob_proof_type, a.dob_proof_upload, a.photoId_proof_type, a.photoId_proof_upload, a.address_proof_type, a.address_proof_upload, a.district,
            app.name, app.mobile_number, app.email_id, app.gender,
            app.disability_type_id, app.address, app.pin_code, app.city,
            app.statename, app.station_id, app.fathers_name,
            DATE_FORMAT(app.date_of_birth, '%Y-%m-%d') as date_of_birth,
            al.current_level, al.status as log_status, al.comments
        FROM Application a
        INNER JOIN Applicant app ON a.applicant_id = app.applicant_id
        LEFT JOIN ApplicationLog al ON a.application_id = al.application_id 
            AND al.validity_id = '1'
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
    let query = "SELECT * FROM Application WHERE 1=1";
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
        'applicant_id', 'current_division_id', 'current_division_user_id',
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
  const query="SELECT * from Application WHERE application_id= ? ";
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

// Helper to increment the current_level
function incrementLevel(currentLevel) {
  if (currentLevel === 'applicant' || currentLevel === '0') return '1';
  if (currentLevel === '1') return '2';
  if (currentLevel === '2') return '3';
  return currentLevel; // If already at max, stay
}

module.exports = {
  getAllPendingApplications,
  getApplicationsByEmployeeLevel,
  getApplicantApplications,
  getFilteredPendingApplications,
  viewApplicationById,
  setApplicationStatus
};
