const express = require('express');
const router = express.Router();
const { getApplicantApplications } = require('../databaseModules/applicationModel');
const { getApplicantStatusById } = require('../databaseModules/applicantModel');

// Add import for fetching comments
const getApplicantCommentsById = (connection, applicantId) => {
    const query = "SELECT comments FROM applicant WHERE applicant_id = ? AND validity_id = '1'";
    return new Promise((resolve, reject) => {
        connection.query(query, [applicantId], (err, results) => {
            if (err) return reject(err);
            resolve(results.length > 0 ? results[0].comments : null);
        });
    });
};

module.exports = (connection) => {

router.get('/:applicantId', async (req, res) => {
    const applicantId = req.params.applicantId;
    
    // Validate applicant ID
    if (!applicantId || isNaN(parseInt(applicantId))) {
        return res.status(400).json({ 
            success: false,
            message: 'Invalid applicant ID. Must be a valid number.' 
        });
    }
    
    try {
        const applications = await getApplicantApplications(connection, applicantId);
        const status = await getApplicantStatusById(connection, applicantId);
        const comments = await getApplicantCommentsById(connection, applicantId);
        if (applications && applications.length > 0) {
            return res.status(200).json({
                success: true,
                data: applications, // Each application now includes current_processing_employee and current_processing_employee_name
                count: applications.length,
                applicantId: applicantId,
                status: status,
                comments: comments,
                message: 'Applications retrieved successfully'
            });
        }
        return res.status(200).json({
            success: true,
            data: [],
            count: 0,
            applicantId: applicantId,
            status: status,
            comments: comments,
            message: 'No valid applications found for this applicant'
        });

    } catch (err) {
        console.log('Error fetching applicant applications:', err);
        return res.status(500).json({ 
            success: false,
            message: 'Error occurred while fetching applications' 
        });
    }
});

return router;

} 