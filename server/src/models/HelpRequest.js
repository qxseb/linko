const mongoose = require("mongoose");

const helpRequestSchema = new mongoose.Schema(
  {
    requester: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    assignedVolunteer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    category: {
      type: String,
      enum: ["groceries", "pharmacy", "errands", "checkin"],
      required: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    locationText: {
      type: String,
      required: true,
      trim: true,
    },
    latitude: {
      type: Number,
    },
    longitude: {
      type: Number,
    },
    distanceText: {
      type: String,
      trim: true,
    },
    urgency: {
      type: String,
      enum: ["low", "medium", "high"],
      default: "medium",
    },
    status: {
      type: String,
      enum: ["open", "accepted", "in_progress", "completed", "cancelled"],
      default: "open",
    },
    preferredTime: {
      type: Date,
    },
    completedAt: {
      type: Date,
    },
    isProxyRequest: {
      type: Boolean,
      default: false,
    },
    proxyName: {
      type: String,
      trim: true,
    },
    proxyRelationship: {
      type: String,
      trim: true,
    },
    proxyNotes: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        ret.id = ret._id.toString();
        delete ret._id;
        delete ret.__v;
      },
    },
  },
);

module.exports = mongoose.model("HelpRequest", helpRequestSchema);
