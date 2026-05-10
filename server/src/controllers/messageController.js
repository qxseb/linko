const mongoose = require('mongoose');
const HelpRequest = require('../models/HelpRequest');
const Message = require('../models/Message');
const { emitSocketEvent } = require('../socket/socketHandler');

const messagePopulate = {
  path: 'sender',
  select: 'name email role',
};

const ensureRequestExists = async (requestId) => {
  if (!mongoose.isValidObjectId(requestId)) {
    const error = new Error('ID-ul cererii este invalid');
    error.statusCode = 400;
    throw error;
  }

  const request = await HelpRequest.findById(requestId);

  if (!request) {
    const error = new Error('Request not found');
    error.statusCode = 404;
    throw error;
  }

  return request;
};

const getMessagesForRequest = async (req, res, next) => {
  try {
    await ensureRequestExists(req.params.id);

    const messages = await Message.find({ request: req.params.id })
      .sort({ createdAt: 1 })
      .populate(messagePopulate);

    res.json({ messages });
  } catch (error) {
    next(error);
  }
};

const createMessage = async (req, res, next) => {
  try {
    const { text } = req.body;

    if (!text) {
      res.status(400);
      throw new Error('Message text is required');
    }

    await ensureRequestExists(req.params.id);

    const message = await Message.create({
      request: req.params.id,
      sender: req.user.id,
      text,
      type: 'user',
    });

    const populatedMessage = await Message.findById(message.id).populate(
      messagePopulate
    );

    emitSocketEvent('message_created', {
      requestId: req.params.id,
      message: populatedMessage,
    });

    res.status(201).json({ message: populatedMessage });
  } catch (error) {
    next(error);
  }
};

module.exports = { getMessagesForRequest, createMessage };
