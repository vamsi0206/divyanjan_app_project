const express = require('express');
const { updateApplicantDetailsById, submitApplicationById, getDivisionByCity, getLevel1EmployeeForDivision } = require('../databaseModules/applicantModel');
const router = express.Router();

module.exports = (connection) => {
  // GET route to fetch current applicant fields for pre-filling the form
  router.get('/:applicant_id', async (req, res) => {
    const applicant_id = req.params.applicant_id;
    if (!applicant_id) {
      return res.status(400).json({ message: 'applicant_id is required' });
    }

    // First get applicant details
    const applicantQuery = `
      SELECT name, mobile_number, password, fathers_name, email_id, gender, 
             disability_type_id, address, pin_code, city, statename,
             date_of_birth, fathers_name
      FROM applicant 
      WHERE applicant_id = ?`;

    // Then get application details if exists
    const applicationQuery = `
      SELECT doctor_name, doctor_reg_no, hospital_name, hospital_city, 
             hospital_state, certificate_issue_date, status,
             concession_certificate, photograph, disability_certificate, disability_cert_no, dob_proof_type, dob_proof_upload, photoId_proof_type, photoId_proof_upload, address_proof_type, address_proof_upload, district
      FROM application 
      WHERE applicant_id = ? AND validity_id = '1'`;

    connection.query(applicantQuery, [applicant_id], (err, applicantResults) => {
      if (err) {
        console.error('Error fetching applicant fields:', err);
        return res.status(500).json({ message: 'An error occurred while fetching applicant fields.' });
      }
      if (!applicantResults.length) {
        return res.status(404).json({ message: 'Applicant not found.' });
      }

      // Get application details
      connection.query(applicationQuery, [applicant_id], (err, applicationResults) => {
        if (err) {
          console.error('Error fetching application fields:', err);
          return res.status(500).json({ message: 'An error occurred while fetching application fields.' });
        }

        // Combine both results
        const response = {
          ...applicantResults[0],
          ...(applicationResults.length ? applicationResults[0] : {})
        };

        return res.status(200).json(response);
      });
    });
  });

  // POST route to update or submit application
  router.post('/', async (req, res) => {
    const {
      applicant_id, name, mobile_number, password, fathers_name, email_id, gender,
      disability_type_id, address, pin_code, city, statename, status, date_of_birth,
      // Disability certificate fields
      doctor_name, doctor_reg_no, hospital_name, hospital_city, 
      hospital_state, certificate_issue_date: raw_certificate_issue_date,
      concession_certificate, photograph, disability_certificate, disability_cert_no,
      dob_proof_type, dob_proof_upload, photoId_proof_type, photoId_proof_upload, address_proof_type, address_proof_upload, district
    } = req.body;

    // Helper to format date to YYYY-MM-DD
    function toDateString(val) {
      if (!val) return null;
      try {
        // Handles both Date objects and ISO strings
        return new Date(val).toISOString().slice(0, 10);
      } catch (e) {
        return val;
      }
    }

    // Ensure certificate_issue_date is null if empty or undefined
    const certificate_issue_date = raw_certificate_issue_date ? toDateString(raw_certificate_issue_date) : null;
    const formatted_date_of_birth = date_of_birth ? toDateString(date_of_birth) : null;

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
          // Create new application for this applicant with disability certificate fields
          // Lookup division_id from hospital_city
          const division_id = await getDivisionByCity(connection, hospital_city);
          if (!division_id) {
            return res.status(400).json({ message: 'Could not determine division for the given hospital_city.' });
          }
          // Lookup level-1 employee for this division
          const level1EmployeeId = await getLevel1EmployeeForDivision(connection, division_id);
          if (!level1EmployeeId) {
            return res.status(400).json({ message: 'No level-1 employee found for the given division.' });
          }
          const createAppQuery = `
            INSERT INTO application (
              applicant_id, status, validity_id, division_id,
              doctor_name, doctor_reg_no, hospital_name, hospital_city,
              hospital_state, certificate_issue_date,
              concession_certificate, photograph, disability_certificate, disability_cert_no,
              dob_proof_type, dob_proof_upload, photoId_proof_type, photoId_proof_upload, address_proof_type, address_proof_upload, district, current_processing_employee
            ) VALUES (
              ?, 'draft', '1', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            )`;
         connection.query(createAppQuery, [
           applicant_id, division_id, doctor_name, doctor_reg_no, hospital_name,
           hospital_city, hospital_state, certificate_issue_date,
           concession_certificate, photograph, disability_certificate, disability_cert_no,
           dob_proof_type, dob_proof_upload, photoId_proof_type, photoId_proof_upload, address_proof_type, address_proof_upload, district, level1EmployeeId
         ], (err2, result) => {
           if (err2) {
             console.error('Error creating application:', err2);
             return res.status(500).json({ message: 'An error occurred while creating application.' });
           }
           application_id = result.insertId;
           // Insert initial ApplicationLog entry
           const createLogQuery = `INSERT INTO ApplicationLog (application_id, status, current_level, assign_date, validity_id, current_processing_employee) VALUES (?, 'pending', '0', NOW(), '1', ?)`;
           connection.query(createLogQuery, [application_id, level1EmployeeId], (err3) => {
             if (err3) {
               console.error('Error creating application log:', err3);
               return res.status(500).json({ message: 'An error occurred while creating application log.' });
             }
             processUpdate();
           });
         });
        } else {
          application_id = results[0].application_id;
          processUpdate();
        }

        function processUpdate() {
          // Update all applicant fields
          const applicantFields = { 
            name, mobile_number, password, fathers_name, email_id, gender,
            disability_type_id, address, pin_code, city, statename,
            date_of_birth: formatted_date_of_birth
          };
          // Remove undefined values
          Object.keys(applicantFields).forEach(key => {
            if (applicantFields[key] === undefined) {
              delete applicantFields[key];
            }
          });

          // Update disability certificate fields
          const certificateFields = {
            doctor_name, doctor_reg_no, hospital_name, hospital_city,
            hospital_state, certificate_issue_date,
            concession_certificate, photograph, disability_certificate, disability_cert_no,
            dob_proof_type, dob_proof_upload, photoId_proof_type, photoId_proof_upload, address_proof_type, address_proof_upload, district
          };
          certificateFields.certificate_issue_date = certificate_issue_date;
          // Remove undefined values
          Object.keys(certificateFields).forEach(key => {
            if (certificateFields[key] === undefined) {
              delete certificateFields[key];
            }
          });

          if (status === 'submitting') {
            // Update applicant and set submission_date in application
            // Set applicant status to 'submitting'
            applicantFields.status = 'submitting';
            updateApplicantDetailsById(connection, applicant_id, applicantFields)
              .then(() => {
                const updateAppQuery = `
                  UPDATE application 
                  SET submission_date = NOW(), 
                      status = 'pending',
                      doctor_name = ?,
                      doctor_reg_no = ?,
                      hospital_name = ?,
                      hospital_city = ?,
                      hospital_state = ?,
                      certificate_issue_date = ?,
                      concession_certificate = ?,
                      photograph = ?,
                      disability_certificate = ?,
                      disability_cert_no = ?,
                      dob_proof_type = ?,
                      dob_proof_upload = ?,
                      photoId_proof_type = ?,
                      photoId_proof_upload = ?,
                      address_proof_type = ?,
                      address_proof_upload = ?,
                      district = ?
                  WHERE application_id = ?`;
                connection.query(updateAppQuery, [
                  certificateFields.doctor_name,
                  certificateFields.doctor_reg_no,
                  certificateFields.hospital_name,
                  certificateFields.hospital_city,
                  certificateFields.hospital_state,
                  certificateFields.certificate_issue_date,
                  certificateFields.concession_certificate,
                  certificateFields.photograph,
                  certificateFields.disability_certificate,
                  certificateFields.disability_cert_no,
                  certificateFields.dob_proof_type,
                  certificateFields.dob_proof_upload,
                  certificateFields.photoId_proof_type,
                  certificateFields.photoId_proof_upload,
                  certificateFields.address_proof_type,
                  certificateFields.address_proof_upload,
                  certificateFields.district,
                  application_id
                ], (err) => {
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
            // Update both applicant details and disability certificate fields
            applicantFields.status = 'draft';
            updateApplicantDetailsById(connection, applicant_id, applicantFields)
              .then(() => {
                // Update disability certificate fields if they exist
                if (Object.keys(certificateFields).length > 0) {
                  const updateCertQuery = `
                    UPDATE application 
                    SET doctor_name = ?,
                        doctor_reg_no = ?,
                        hospital_name = ?,
                        hospital_city = ?,
                        hospital_state = ?,
                        certificate_issue_date = ?,
                        concession_certificate = ?,
                        photograph = ?,
                        disability_certificate = ?,
                        disability_cert_no = ?,
                        dob_proof_type = ?,
                        dob_proof_upload = ?,
                        photoId_proof_type = ?,
                        photoId_proof_upload = ?,
                        address_proof_type = ?,
                        address_proof_upload = ?,
                        district = ?
                    WHERE application_id = ?`;
                  connection.query(updateCertQuery, [
                    certificateFields.doctor_name,
                    certificateFields.doctor_reg_no,
                    certificateFields.hospital_name,
                    certificateFields.hospital_city,
                    certificateFields.hospital_state,
                    certificateFields.certificate_issue_date,
                    certificateFields.concession_certificate,
                    certificateFields.photograph,
                    certificateFields.disability_certificate,
                    certificateFields.disability_cert_no,
                    certificateFields.dob_proof_type,
                    certificateFields.dob_proof_upload,
                    certificateFields.photoId_proof_type,
                    certificateFields.photoId_proof_upload,
                    certificateFields.address_proof_type,
                    certificateFields.address_proof_upload,
                    certificateFields.district,
                    application_id
                  ], (err) => {
                    if (err) {
                      console.error('Error updating disability certificate fields:', err);
                      return res.status(500).json({ message: 'An error occurred while updating disability certificate fields.' });
                    }
                    return res.status(200).json({ message: 'application updated successfully' });
                  });
                } else {
                  return res.status(200).json({ message: 'application updated successfully' });
                }
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