const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,
    },
    role: {
      type: String,
      enum: ["requester", "volunteer"],
      required: true,
    },
    age: {
      type: Number,
    },
    phone: {
      type: String,
      trim: true,
    },
    trustLevel: {
      type: String,
      default: "Verified",
    },
    isVerified: {
      type: Boolean,
      default: true,
    },
    completedTasks: {
      type: Number,
      default: 0,
    },
    completedRequests: {
      type: Number,
      default: 0,
    },
    responseTime: {
      type: Number,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        ret.id = ret._id.toString();
        delete ret._id;
        delete ret.__v;
        delete ret.passwordHash;
      },
    },
  },
);

module.exports = mongoose.model("User", userSchema);
