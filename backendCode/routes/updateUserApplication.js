const express = require('express');
const { updateApplicantDetailsById, submitApplicationById } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {
  // GET route to fetch current applicant fields for pre-filling the form
  router.get('/updateUserApplication/:applicant_id', async (req, res) => {
    const applicant_id = req.params.applicant_id;
    if (!applicant_id) {
      return res.status(400).json({ message: 'applicant_id is required' });
    }
    const query = `SELECT name, mobile_number, password, email_id, gender, disability_type_id, address, pin_code, city, statename, station_id FROM applicant WHERE applicant_id = ?`;
    connection.query(query, [applicant_id], (err, results) => {
      if (err) {
        console.error('Error fetching applicant fields:', err);
        return res.status(500).json({ message: 'An error occurred while fetching applicant fields.' });
      }
      if (!results.length) {
        return res.status(404).json({ message: 'Applicant not found.' });
      }
      return res.status(200).json(results[0]);
    });
  });

  // POST route to update or submit application
  router.post('/updateUserApplication', async (req, res) => {
    const { applicant_id, name, mobile_number, password, email_id, gender, disability_type_id, address, pin_code, city, statename, station_id, status } = req.body;
    if (!applicant_id) {
      return res.status(400).json({ message: 'applicant_id is required' });
    }

    try {
      // Check if applicant has a valid application
      const checkAppQuery = "SELECT application_id FROM application WHERE applicant_id = ? AND validity_id = '1'";
      connection.query(checkAppQuery, [applicant_id], async (err, results) => {
        if (err) {
          console.error('Error checking application:', err);
          return res.status(500).json({ message: 'An error occurred while checking application.' });
        }

        let application_id;
        if (!results.length) {
          // Create new application for this applicant
          const createAppQuery = "INSERT INTO application (applicant_id, status, validity_id, current_division_id) VALUES (?, 'draft', '1', 1)";
          connection.query(createAppQuery, [applicant_id], (err2, result) => {
            if (err2) {
              console.error('Error creating application:', err2);
              return res.status(500).json({ message: 'An error occurred while creating application.' });
            }
            application_id = result.insertId;
            processUpdate();
          });
        } else {
          application_id = results[0].application_id;
          processUpdate();
        }

        function processUpdate() {
          // Update all applicant fields
          const applicantFields = { name, mobile_number, password, email_id, gender, disability_type_id, address, pin_code, city, statename, station_id };
          // Remove undefined values
          Object.keys(applicantFields).forEach(key => {
            if (applicantFields[key] === undefined) {
              delete applicantFields[key];
            }
          });

          if (status === 'submitting') {
            // Update applicant and set submission_date in application
            updateApplicantDetailsById(connection, applicant_id, applicantFields)
              .then(() => {
                const updateAppQuery = "UPDATE application SET submission_date = NOW(), status = 'submitted' WHERE application_id = ?";
                connection.query(updateAppQuery, [application_id], (err) => {
                  if (err) {
                    console.error('Error updating application:', err);
                    return res.status(500).json({ message: 'An error occurred while updating application.' });
                  }
                  return res.status(200).json({ message: 'application submitted successfully' });
                });
              })
              .catch(err => {
                console.error('Error updating applicant:', err);
                return res.status(500).json({ message: 'An error occurred while updating applicant.' });
              });
          } else {
            // Just update applicant details
            updateApplicantDetailsById(connection, applicant_id, applicantFields)
              .then(() => {
                return res.status(200).json({ message: 'application updated successfully' });
              })
              .catch(err => {
                console.error('Error updating applicant:', err);
                return res.status(500).json({ message: 'An error occurred while updating applicant.' });
              });
          }
        }
      });
    } catch (err) {
      console.error('Error updating application:', err);
      return res.status(500).json({ message: 'An error occurred during update.' });
    }
  });

  return router;
};