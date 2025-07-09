const express = require('express');
const router = express.Router();
const { getFilteredPendingApplications } = require('../databaseModules/applicationModel');

module.exports = (connection) => {

// Express route to handle dynamic filtering
router.get('/:divId', async (req, res) => {
    try {
        // Extract query parameters and build filter object
        const filters = {};
    //filter based on date range
        if (req.params.divId)  
            filters.division_id = parseInt(req.query.division_id);
        else
        {
            //give error since only data pertaining to particular division facility is to be implemented
            throw new Error("Division Id unspecified in http request");

        }
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

