const express = require('express');
const { updateApplicantDetails, submitApplication } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {
  router.post('/updateUserApplication', async (req, res) => {
    const { mobile_number, address, pin_code, city, state_id, station_id, status } = req.body;
    if (!mobile_number) {
      return res.status(400).json({ message: 'mobile_number is required' });
    }

    const updateFields = { address, pin_code, city, state_id, station_id };

    try {

      if (status === 'submitting') {
        await submitApplication(connection, mobile_number, updateFields);
        return res.status(200).json({ message: 'application submitted successfully' });
      }


      await updateApplicantDetails(connection, mobile_number, updateFields);
      return res.status(200).json({ message: 'application updated successfully' });
    } catch (err) {
      console.error('Error updating application:', err);
      return res.status(500).json({ message: 'An error occurred during update.' });
    }
  });

  return router;
};