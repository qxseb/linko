const mongoose = require("mongoose");
const HelpRequest = require("../models/HelpRequest");
const Message = require("../models/Message");
const User = require("../models/User");
const { emitSocketEvent } = require("../socket/socketHandler");

const allowedCategories = ["groceries", "pharmacy", "errands", "checkin"];
const allowedUrgencies = ["low", "medium", "high"];
const allowedStatuses = [
  "open",
  "accepted",
  "in_progress",
  "completed",
  "cancelled",
];

const USER_SELECT =
  "name email role age phone trustLevel isVerified completedTasks completedRequests responseTime createdAt";

const requestPopulate = [
  { path: "requester", select: USER_SELECT },
  { path: "assignedVolunteer", select: USER_SELECT },
];

const populateRequest = (query) => query.populate(requestPopulate);

const ensureValidId = (id) => {
  if (!mongoose.isValidObjectId(id)) {
    const error = new Error("Request ID is invalid");
    error.statusCode = 400;
    throw error;
  }
};

const ensureAllowed = (value, allowedValues, message) => {
  if (value && !allowedValues.includes(value)) {
    const error = new Error(message);
    error.statusCode = 400;
    throw error;
  }
};

const findRequestOrFail = async (id) => {
  ensureValidId(id);
  const request = await HelpRequest.findById(id);
  if (!request) {
    const error = new Error("Request not found");
    error.statusCode = 404;
    throw error;
  }
  return request;
};

const createSystemMessage = (requestId, text) =>
  Message.create({ request: requestId, text, type: "system" });

const getRequests = async (req, res, next) => {
  try {
    const { status, urgency, category } = req.query;
    const filters = {};

    ensureAllowed(status, allowedStatuses, "Status filter is invalid");
    ensureAllowed(urgency, allowedUrgencies, "Urgency filter is invalid");
    ensureAllowed(category, allowedCategories, "Category filter is invalid");

    if (status) filters.status = status;
    if (urgency) filters.urgency = urgency;
    if (category) filters.category = category;

    if (!status) filters.status = { $ne: "cancelled" };

    const requests = await populateRequest(
      HelpRequest.find(filters).sort({ createdAt: -1 }),
    );

    res.json({ requests });
  } catch (error) {
    next(error);
  }
};

const getRequestById = async (req, res, next) => {
  try {
    ensureValidId(req.params.id);
    const request = await populateRequest(HelpRequest.findById(req.params.id));
    if (!request) {
      res.status(404);
      throw new Error("Request not found");
    }
    res.json({ request });
  } catch (error) {
    next(error);
  }
};

const createRequest = async (req, res, next) => {
  try {
    if (req.user.role !== "requester") {
      res.status(403);
      throw new Error("Only requesters can create requests");
    }

    const {
      category,
      title,
      description,
      locationText,
      latitude,
      longitude,
      distanceText,
      urgency,
      preferredTime,
      isProxyRequest,
      proxyName,
      proxyRelationship,
      proxyNotes,
    } = req.body;

    if (!category || !title || !description || !locationText) {
      res.status(400);
      throw new Error(
        "Category, title, description, and location are required",
      );
    }

    ensureAllowed(category, allowedCategories, "Category is invalid");
    ensureAllowed(urgency, allowedUrgencies, "Urgency is invalid");

    const request = await HelpRequest.create({
      requester: req.user.id,
      category,
      title,
      description,
      locationText,
      latitude,
      longitude,
      distanceText,
      urgency,
      preferredTime,
      isProxyRequest,
      proxyName,
      proxyRelationship,
      proxyNotes,
    });

    const populatedRequest = await populateRequest(
      HelpRequest.findById(request.id),
    );
    emitSocketEvent("request_created", {
      requestId: request.id,
      request: populatedRequest,
    });
    res.status(201).json({ request: populatedRequest });
  } catch (error) {
    next(error);
  }
};

const acceptRequest = async (req, res, next) => {
  try {
    if (req.user.role !== "volunteer") {
      res.status(403);
      throw new Error("Only volunteers can accept requests");
    }

    const request = await findRequestOrFail(req.params.id);

    if (request.status !== "open") {
      res.status(400);
      throw new Error("Request can only be accepted while it is open");
    }

    request.status = "accepted";
    request.assignedVolunteer = req.user.id;
    await request.save();

    await createSystemMessage(
      request.id,
      `${req.user.name} accepted the request.`,
    );
    await Message.create({
      request: request.id,
      sender: request.requester,
      text: "Thank you. I will wait for your help.",
      type: "user",
    });

    const populatedRequest = await populateRequest(
      HelpRequest.findById(request.id),
    );
    emitSocketEvent("request_accepted", {
      requestId: request.id,
      request: populatedRequest,
    });
    res.json({ request: populatedRequest });
  } catch (error) {
    next(error);
  }
};

const startRequest = async (req, res, next) => {
  try {
    if (req.user.role !== "volunteer") {
      res.status(403);
      throw new Error("Only volunteers can start requests");
    }

    const request = await findRequestOrFail(req.params.id);

    if (request.status !== "accepted") {
      res.status(400);
      throw new Error("Request can only be started after it is accepted");
    }

    if (request.assignedVolunteer?.toString() !== req.user.id) {
      res.status(403);
      throw new Error("Only the assigned volunteer can start this request");
    }

    request.status = "in_progress";
    await request.save();

    await createSystemMessage(
      request.id,
      `${req.user.name} started the request.`,
    );

    const populatedRequest = await populateRequest(
      HelpRequest.findById(request.id),
    );
    emitSocketEvent("request_started", {
      requestId: request.id,
      request: populatedRequest,
    });
    res.json({ request: populatedRequest });
  } catch (error) {
    next(error);
  }
};

const completeRequest = async (req, res, next) => {
  try {
    if (req.user.role !== "volunteer") {
      res.status(403);
      throw new Error("Only volunteers can complete requests");
    }

    const request = await findRequestOrFail(req.params.id);

    if (request.status !== "in_progress") {
      res.status(400);
      throw new Error("Request can only be completed while it is in progress");
    }

    if (request.assignedVolunteer?.toString() !== req.user.id) {
      res.status(403);
      throw new Error("Only the assigned volunteer can complete this request");
    }

    const now = new Date();
    request.status = "completed";
    request.completedAt = now;
    await request.save();

    await Promise.all([
      User.findByIdAndUpdate(req.user.id, { $inc: { completedTasks: 1 } }),
      User.findByIdAndUpdate(request.requester, {
        $inc: { completedRequests: 1 },
      }),
    ]);

    await createSystemMessage(
      request.id,
      `${req.user.name} completed the request.`,
    );

    const populatedRequest = await populateRequest(
      HelpRequest.findById(request.id),
    );
    emitSocketEvent("request_completed", {
      requestId: request.id,
      request: populatedRequest,
    });
    res.json({ request: populatedRequest });
  } catch (error) {
    next(error);
  }
};

const cancelRequest = async (req, res, next) => {
  try {
    const request = await findRequestOrFail(req.params.id);

    if (["completed", "cancelled"].includes(request.status)) {
      res.status(400);
      throw new Error("Request can no longer be cancelled");
    }

    const isRequester = request.requester.toString() === req.user.id;
    const isAssignedVolunteer =
      request.assignedVolunteer?.toString() === req.user.id;

    if (!isRequester && !isAssignedVolunteer) {
      res.status(403);
      throw new Error("You cannot cancel this request");
    }

    request.status = "cancelled";
    await request.save();

    await createSystemMessage(request.id, "Request was cancelled.");

    const populatedRequest = await populateRequest(
      HelpRequest.findById(request.id),
    );
    emitSocketEvent("request_cancelled", {
      requestId: request.id,
      request: populatedRequest,
    });
    res.json({ request: populatedRequest });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getRequests,
  getRequestById,
  createRequest,
  acceptRequest,
  startRequest,
  completeRequest,
  cancelRequest,
};
