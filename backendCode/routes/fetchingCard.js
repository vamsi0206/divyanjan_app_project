const express = require('express');
const router = express.Router();

module.exports = (connection) => {

// GET /:applicantId - fetch all card details for the applicant
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
        // Join Application and concessionCardsIssued to get all card fields for this applicant
        const query = `
            SELECT c.*, a.concession_card_validity
            FROM Application a
            INNER JOIN concessionCardsIssued c ON a.card_number = c.card_number
            WHERE a.applicant_id = ? AND a.card_number IS NOT NULL
        `;
        connection.query(query, [applicantId], (err, results) => {
            if (err) {
                console.error('Error fetching card details:', err);
                return res.status(500).json({
                    success: false,
                    message: 'Error occurred while fetching card details'
                });
            }
            return res.status(200).json({
                success: true,
                data: results,
                count: results.length,
                applicantId: applicantId,
                message: results.length > 0 ? 'Card(s) retrieved successfully' : 'No card found for this applicant'
            });
        });
    } catch (err) {
        console.error('Error in fetchingCard route:', err);
        return res.status(500).json({
            success: false,
            message: 'Unexpected error occurred while fetching card details'
        });
    }
});

return router;

} 