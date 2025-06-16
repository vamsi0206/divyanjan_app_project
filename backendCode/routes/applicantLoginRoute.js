const express = require('express');
const { getUserByMobileNumber } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {

router.post('/login', async (req, res) => {
  const { mobile_number, password } = req.body;

  try {
    const users = await getUserByMobileNumber(connection, mobile_number);
    if (users.length > 0 && users[0].password === password) {
      return res.status(200).json({ message: 'login successful' });
    }
    return res.status(200).json({ message: 'invalid credentials' });
  } catch (err) {
    console.error('Error during login:', err);
    return res.status(500).json({ message: 'An error occurred during login.' });
  }
});

return router;

}

