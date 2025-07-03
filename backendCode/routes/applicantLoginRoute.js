const express = require('express');
const { getUserByMobileNumber } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {

  router.post('/', async (req, res) => {
    const mobile_number = req.body.mobile_number || req.body['mobile_number'];
  const password = req.body.password || req.body['password'];
  
  console.log('Request body:', req.body);
  console.log('Mobile number:', mobile_number);
  console.log('Password:', password);
    try {
      const users = await getUserByMobileNumber(connection, mobile_number);
      if (users.length > 0 && users[0].password === password) {
        // Redirect to applicant dashboard with the applicant_id
        return res.redirect(`/applicantDashboard/${users[0].applicant_id}`);
      }
      // For invalid credentials, you might want to redirect to login page with error
      return res.status(401).json({ message: 'invalid credentials' });
    } 
    catch (err) {
      console.error('Error during login:', err);
      return res.status(500).json({ message: 'An error occurred during login.' });
    }
  });

  return router;
}
