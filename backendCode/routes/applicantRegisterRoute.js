const express = require('express');
const { createUser, getUserByMobileNumber } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {
	router.post('/', async (req, res) => {
		// require mandatory fields
		const requiredFields = ['name', 'mobile_number', 'password', 'email_id', 'gender', 'disability_type_id'];
		// for (const field of requiredFields) {
		// 	if (!req.body[field]) {
		// 		return res.status(400).json({ message: `${field} is required` }); //////////////////////////////////checking of empty fields done in front end
		// 	}
		// }
		// extract only allowed fields and add registration_date
		const { name, mobile_number, password, email_id, gender, disability_type_id } = req.body;
		const userData = { name, mobile_number, password, email_id, gender, disability_type_id, registration_date: new Date() };

		try {
			const users = await getUserByMobileNumber(connection, userData.mobile_number);
			if (users.length > 0) {
				return res.status(200).json({ message: 'user already exists' });
			}

			await createUser(connection, userData);
			return res.status(200).json({ message: 'registration successful' });
		} catch (err) {
			console.error('Error during registration:', err);
			return res.status(500).json({ message: 'An error occurred during registration.' });
		}
	});

	return router;
};