const mongoose = require("mongoose");

const InputSchema = new mongoose.Schema(
  {
    time: {
      type: Number,
      required: true,
    },
    direction: {
      type: Number,
      enum: [0, 1],
      required: true,
    },
  },
  { _id: false },
);

const MapSchema = new mongoose.Schema(
  {
    // basic info
    name: {
      type: String,
      required: true,
    },
    artist: {
      type: String,
      required: true,
    },
    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    description: {
      type: String,
      default: "",
    },
    bpm: {
      type: Number,
      required: true,
    },
    offset: {
      type: Number,
      default: 0,
    },
    duration: {
      type: Number,
      required: true,
    },
    packageUrl: {
      type: String,
      required: true,
    },
    inputs: {
      type: [InputSchema],
      default: [],
    },
    difficulty: {
      type: String,
      enum: ["Easy", "Normal", "Hard", "Insane"],
      default: "Normal",
    },
    tags: {
      type: [String],
      default: [],
    },

    playCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.model("Map", MapSchema);
