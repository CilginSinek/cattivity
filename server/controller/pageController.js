const mongoose = require("mongoose");
const User = require("../models/User");
const Map = require("../models/Map");
const Play = require("../models/Play");

exports.root = async (req, res) => {
  try {
    const userId = req.session.userId;

    const users = await User.aggregate([
      {
        $lookup: {
          from: "plays",
          localField: "_id",
          foreignField: "player",
          as: "plays",
        },
      },
      {
        $addFields: {
          totalScore: { $sum: "$plays.score" },
        },
      },
      {
        $project: {
          password: 0,
          plays: 0,
        },
      },
      {
        $sort: { totalScore: -1, _id: 1 },
      },
    ]);

    const userIndex = users.findIndex(
      (u) => u._id.toString() === userId.toString(),
    );

    if (userIndex === -1) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = users[userIndex];
    const score = user.totalScore || 0;
    const rank = userIndex + 1;

    res.status(200).json({ user, score, rank });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.leaderboard = async (req, res) => {
  try {
    let page = parseInt(req.query.page) || 1;
    if (page < 1) page = 1;
    const limit = 10;
    const skip = (page - 1) * limit;
    const users = await User.aggregate([
      {
        $lookup: {
          from: "plays",
          localField: "_id",
          foreignField: "player",
          as: "plays",
        },
      },
      {
        $addFields: {
          totalScore: { $sum: "$plays.score" },
        },
      },
      {
        $project: {
          password: 0,
          plays: 0,
        },
      },
      {
        $sort: { totalScore: -1, _id: 1 },
      },
    ])
      .limit(limit)
      .skip(skip);
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.profile = async (req, res) => {
  try {
    const userId = req.params.id;
    const users = await User.aggregate([
      {
        $lookup: {
          from: "plays",
          localField: "_id",
          foreignField: "player",
          as: "plays",
        },
      },
      { $unwind: { path: "$plays", preserveNullAndEmptyArrays: true } },
      {
        $group: {
          _id: { userId: "$_id", mapId: "$plays.playedMap" },
          user: { $first: "$$ROOT" },
          maxScore: { $max: "$plays.score" },
        },
      },
      {
        $group: {
          _id: "$_id.userId",
          user: { $first: "$user" },
          totalScore: { $sum: "$maxScore" },
        },
      },
      {
        $project: {
          "user.password": 0,
          "user.plays": 0,
        },
      },
      { $sort: { totalScore: -1, _id: 1 } },
    ]);

    const userIndex = users.findIndex(
      (u) => u._id.toString() === userId.toString(),
    );

    if (userIndex === -1) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = users[userIndex].user;
    const score = users[userIndex].totalScore || 0;
    const rank = userIndex + 1;

    res.status(200).json({ user, score, rank });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getmap = async (req, res) => {
  try {
    const mapId = req.params.id;
    let page = parseInt(req.query.page) || 1;
    if (page < 1) page = 1;
    const limit = 10;
    const skip = (page - 1) * limit;

    const map = await Map.findById(mapId);
    if (!map) {
      return res.status(404).json({ error: "Map not found" });
    }

    const leaderboard = await Play.aggregate([
      {
        $match: {
          playedMap: new mongoose.Types.ObjectId(mapId),
        },
      },
      {
        $group: {
          _id: "$player",
          maxScore: { $max: "$score" },
        },
      },
      { $sort: { maxScore: -1, _id: 1 } },
      { $skip: skip },
      { $limit: limit },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "user",
        },
      },
      { $unwind: "$user" },
      {
        $project: {
          _id: 0,
          user: {
            _id: "$user._id",
            name: "$user.name",
            email: "$user.email",
            coalition: "$user.coalition",
          },
          score: "$maxScore",
        },
      },
    ]);

    res.status(200).json({ map, page, leaderboard });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.maps = async (req, res) => {
  try {
    const maps = await Map.find();
    res.status(200).json(maps);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

