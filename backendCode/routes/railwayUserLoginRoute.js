const express = require('express');
const router = express.Router();

module.exports = (connection) => {
  router.post('/', async (req, res) => {
    const { user_id, password } = req.body;
    try {
      const [users] = await connection.promise().query(
        'SELECT user_id, password, current_level FROM Railwayuser WHERE user_id = ?',
        [user_id]
      );
      if (users.length > 0 && users[0].password === password) {
        return res.status(200).json({
          message: 'login successful',
          user_id: users[0].user_id,
          current_level: users[0].current_level
        });
      }
      return res.status(200).json({ message: 'invalid credentials' });
    } catch (err) {
      console.error('Error during railway user login:', err);
      return res.status(500).json({ message: 'An error occurred during login.' });
    }
  });
  return router;
}; 