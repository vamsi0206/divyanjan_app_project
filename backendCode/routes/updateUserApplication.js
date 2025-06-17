const express = require('express');
const { getUserByMobileNumber, updateApplicantDetails } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {
  router.post('/updateUserApplication', async (req, res) => {
    const { mobile_number, address, pin_code, city, state_id, station_id } = req.body;
    if (!mobile_number) {
      return res.status(400).json({ message: 'mobile_number is required' });
    }

    const updateFields = {};
    if (address != null && address !== '') updateFields.address = address;
    if (pin_code != null && pin_code !== '') updateFields.pin_code = pin_code;
    if (city != null && city !== '') updateFields.city = city;
    if (state_id != null && state_id !== '') updateFields.state_id = state_id;
    if (station_id != null && station_id !== '') updateFields.station_id = station_id;

    try {
      const users = await getUserByMobileNumber(connection, mobile_number);
      if (users.length === 0) {
        return res.status(404).json({ message: 'user not found' });
      }
      if (Object.keys(updateFields).length === 0) {
        return res.status(400).json({ message: 'No fields provided to update' });
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