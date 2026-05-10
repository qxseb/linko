const express = require('express');
const {
  createMessage,
  getMessagesForRequest,
} = require('../controllers/messageController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router({ mergeParams: true });

router.route('/').get(protect, getMessagesForRequest).post(protect, createMessage);

module.exports = router;
