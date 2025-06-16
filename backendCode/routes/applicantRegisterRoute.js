const express = require('express');
const { createUser, getUserByMobileNumber } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {
	router.post('/register', async (req, res) => {
		const { mobile_number, password } = req.body;

		try {
			const users = await getUserByMobileNumber(connection, mobile_number);
			if (users.length > 0) {
				return res.status(200).json({ message: 'user already exists' });
			}

			await createUser(connection, mobile_number, password);
			return res.status(200).json({ message: 'registration successful' });
		} catch (err) {
			console.error('Error during registration:', err);
			return res.status(500).json({ message: 'An error occurred during registration.' });
		}
	});

	return router;
};