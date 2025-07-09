const express = require('express');
const router = express.Router();
const { getApplicantApplications } = require('../databaseModules/applicationModel');

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
        // Remove fetching status from Applicant table
        const applications = await getApplicantApplications(connection, applicantId);
        let status = null;
        if (applications && applications.length > 0) {
            status = applications[0].status || null;
            return res.status(200).json({
                success: true,
                data: applications,
                count: applications.length,
                applicantId: applicantId,
                status: status,
                message: 'Applications retrieved successfully'
            });
        }
        return res.status(200).json({
            success: true,
            data: [],
            count: 0,
            applicantId: applicantId,
            status: null,
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