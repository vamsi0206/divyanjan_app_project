const express = require('express');
const router = express.Router();
const { getFilteredPendingApplications, viewApplicationById, setApplicationStatus } = require('../databaseModules/applicationModel');

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

// Submit application route
router.post('/:applicationId/submit', async (req, res) => {
  let applicationId = req.params.applicationId;
  
  try {
    const result = await setApplicationStatus(connection, applicationId, 'submitted');
    return res.status(200).json(result);
  } 
  catch (err) {
    console.error('Error during application submission:', err);
    return res.status(500).json({ message: 'Database operation to submit application failed' });
  }
});

// Reject application route
router.post('/:applicationId/reject', async (req, res) => {
  let applicationId = req.params.applicationId;
  
  try {
    const result = await setApplicationStatus(connection, applicationId, 'rejected');
    return res.status(200).json(result);
  } 
  catch (err) {
    console.error('Error during application rejection:', err);
    return res.status(500).json({ message: 'Database operation to reject application failed' });
  }
});

// Transfer application route
router.post('/:applicationId/transfer', async (req, res) => {
  let applicationId = req.params.applicationId;
  let newEmployeeId = req.body.current_processing_employee;
  const { transferApplication } = require('../databaseModules/actionModel');

  if (!newEmployeeId) {
    return res.status(400).json({ message: 'current_processing_employee is required in request body' });
  }

  try {
    const result = await transferApplication(connection, applicationId, newEmployeeId);
    return res.status(200).json(result);
  } 
  catch (err) {
    console.error('Error during application transfer:', err);
    return res.status(500).json({ message: err.message || 'Database operation to transfer application failed' });
  }
});

return router;

}

