const express = require('express');
const {
  acceptRequest,
  cancelRequest,
  completeRequest,
  createRequest,
  getRequestById,
  getRequests,
  startRequest,
} = require('../controllers/requestController');
const { protect } = require('../middleware/authMiddleware');
const messageRoutes = require('./messageRoutes');

const router = express.Router();

router.route('/').get(getRequests).post(protect, createRequest);

router.patch('/:id/accept', protect, acceptRequest);
router.patch('/:id/start', protect, startRequest);
router.patch('/:id/complete', protect, completeRequest);
router.patch('/:id/cancel', protect, cancelRequest);
router.use('/:id/messages', messageRoutes);

router.get('/:id', getRequestById);

module.exports = router;
