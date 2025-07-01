const express = require('express');
const router = express.Router();
const { getFilteredPendingApplications } = require('../databaseModules/applicationModel');

module.exports = (connection) => {

// Express route to handle dynamic filtering
router.get('/', async (req, res) => {
    try {
        // Extract query parameters and build filter object
        const filters = {};
        
        // Single value filters
        if (req.query.status) filters.status = req.query.status;
        if (req.query.applicant_id) filters.applicant_id = parseInt(req.query.applicant_id);
        if (req.query.current_division_id) filters.current_division_id = parseInt(req.query.current_division_id);
        if (req.query.current_division_user_id) filters.current_division_user_id = parseInt(req.query.current_division_user_id);
        if (req.query.current_cmi_id) filters.current_cmi_id = parseInt(req.query.current_cmi_id);
        if (req.query.current_cis_id) filters.current_cis_id = parseInt(req.query.current_cis_id);
        if (req.query.card_number) filters.card_number = req.query.card_number;
        
        // Date range filters
        if (req.query.submission_date_from) filters.submission_date_from = req.query.submission_date_from;
        if (req.query.submission_date_to) filters.submission_date_to = req.query.submission_date_to;
        if (req.query.card_issue_date_from) filters.card_issue_date_from = req.query.card_issue_date_from;
        if (req.query.card_issue_date_to) filters.card_issue_date_to = req.query.card_issue_date_to;
        
        const applications = await getFilteredPendingApplications(connection,filters);
        res.json({
            success: true,
            data: applications,
            count: applications.length
        });
        
    } catch (error) {
        console.error('Error fetching applications:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching applications',
            error: error.message
        });
    }
});

return router;

}

