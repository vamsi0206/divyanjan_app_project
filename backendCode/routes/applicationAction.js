const express = require('express');
const router = express.Router();
const { getFilteredPendingApplications, viewApplicationById, setApplicationStatus } = require('../databaseModules/applicationModel');
const { getActiveApplicationIdByApplicantId } = require('../databaseModules/applicantModel');

module.exports = (connection) => {

// view an application with given id
router.get('/:applicationId/view', async (req, res) => {
  // Extract query parameters 
  let applicationId = req.params.applicationId;
  try {
    const application = await viewApplicationById(applicationId, connection);
    return res.status(200).json(application);
  } 
  catch (err) {
    console.error('Error during application fetch:', err);
    return res.status(500).json({ message: 'Application with given id not found' });
  }
});

// Unified application action route
router.post('/:applicantId/action', async (req, res) => {
  const applicantId = req.params.applicantId;
  // Use the organized function to get the applicationId
  const applicationId = await getActiveApplicationIdByApplicantId(connection, applicantId);
  if (!applicationId) {
    return res.status(404).json({ message: 'No active application found for this applicant' });
  }
  const { action, current_processing_employee } = req.body;
  const { transferApplication } = require('../databaseModules/actionModel');
  const { approveApplication, rejectApplication, submitApplicationAction, getNextLevelEmployeeForDivision } = require('../databaseModules/applicationModel');

  if (!action) {
    return res.status(400).json({ message: 'Action is required in request body' });
  }

  try {
    let result;
    if (action === 'submit') {
      // Submit action (custom logic)
      // Get the latest ApplicationLog entry to check current_level
      const getLogQuery = `SELECT * FROM ApplicationLog WHERE application_id = ? AND validity_id = '1' ORDER BY log_id DESC LIMIT 1`;
      const [logEntry] = await new Promise((resolve, reject) => {
        connection.query(getLogQuery, [applicationId], (err, results) => {
          if (err) return reject(err);
          resolve(results);
        });
      });
      if (!logEntry) {
        return res.status(400).json({ message: 'No valid ApplicationLog entry found' });
      }
      if (logEntry.current_level === '3' || logEntry.current_level === 3) {
        return res.status(400).json({ message: 'Application is already at the final level' });
      }
      let result;
      try {
        result = await submitApplicationAction(connection, applicationId, current_processing_employee);
        if (result === null) {
          return res.status(400).json({ message: 'No next level employee found or application is at the final level' });
        }
      } catch (err) {
        return res.status(400).json({ message: err.message || 'Error during submit action' });
      }
      return res.status(200).json(result);
    } else if (action === 'approve') {
      // Approve action (custom logic)
      let assignedEmployeeId = current_processing_employee;
      // Get the latest ApplicationLog entry to check current_level
      const getLogQuery = `SELECT * FROM ApplicationLog WHERE application_id = ? AND validity_id = '1' ORDER BY log_id DESC LIMIT 1`;
      const [logEntry] = await new Promise((resolve, reject) => {
        connection.query(getLogQuery, [applicationId], (err, results) => {
          if (err) return reject(err);
          resolve(results);
        });
      });
      if (!logEntry) {
        return res.status(400).json({ message: 'No valid ApplicationLog entry found' });
      }
      if (logEntry.current_level === '1' || logEntry.current_level === 1) {
        // Auto-assign level-3 employee for the division
        const getDivisionQuery = `SELECT division_id FROM Application WHERE application_id = ?`;
        const [appRow] = await new Promise((resolve, reject) => {
          connection.query(getDivisionQuery, [applicationId], (err, results) => {
            if (err) return reject(err);
            resolve(results);
          });
        });
        if (!appRow) {
          return res.status(400).json({ message: 'Application division not found' });
        }
        assignedEmployeeId = await getNextLevelEmployeeForDivision(connection, appRow.division_id, logEntry.current_level);
        if (!assignedEmployeeId) {
          return res.status(400).json({ message: 'No level-3 employee found for division' });
        }
      } else if (logEntry.current_level === '2' || logEntry.current_level === 2) {
        // Assign to null (no next level)
        assignedEmployeeId = null;
      } else if (!assignedEmployeeId) {
        return res.status(400).json({ message: 'current_processing_employee is required for approve action' });
      }
      const result = await approveApplication(connection, applicationId, assignedEmployeeId);
      return res.status(200).json(result);
    } else if (action === 'reject') {
      // Reject action (custom logic)
      const { comments } = req.body;
      if (!comments) {
        return res.status(400).json({ message: 'comments is required for reject action' });
      }
      result = await rejectApplication(connection, applicationId, comments);
    } else if (action === 'transfer') {
      // Transfer action
      if (!current_processing_employee) {
        return res.status(400).json({ message: 'current_processing_employee is required for transfer action' });
      }
      result = await transferApplication(connection, applicationId, current_processing_employee);
    } else {
      return res.status(400).json({ message: 'Invalid action. Allowed actions: approve, reject, transfer' });
    }
    return res.status(200).json(result);
  } catch (err) {
    console.error('Error during application action:', err);
    return res.status(500).json({ message: err.message || 'Database operation for application action failed' });
  }
});

return router;

}

