const Map = require("../models/Map");
const User = require("../models/User");
const Play = require("../models/Play");
const fs = require("fs");

exports.savePlay = async (req, res) => {
  try {
    const userId = req.session.userId;
    const { mapId, score } = req.body;

    const map = await Map.findById(mapId);
    if (!map) {
      return res.status(404).json({ error: "Map not found" });
    }

    const myUser = await User.findById(userId);
    if (!myUser) {
      return res.status(404).json({ error: "User not found" });
    }

    const play = await Play.create({
      player: userId,
      playedMap: mapId,
      score,
    });

    myUser.plays.push(play._id);
    await myUser.save();
    const resplay = await play
      .populate("player", "name coalition")
      .populate("playedMap", "name artist creator");
    res.status(201).json({ status: "success", resplay });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.uploadMap = async (req, res) => {
  try {
    const { name, artist, bpm, offset, duration, inputs } = req.body;

    if (!name || !artist || !bpm || !duration || !Array.isArray(inputs))
      return res.status(400).json({ error: "Missing required fields" });

    if (inputs.some((input) => !input.time || !input.direction))
      return res.status(400).json({ error: "Invalid input format" });

    if (inputs.some((input) => input.direction !== 1 && input.direction !== 0))
      return res.status(400).json({ error: "Invalid input direction" });

    if (isNaN(bpm) || isNaN(duration) || (offset && isNaN(offset)))
      return res
        .status(400)
        .json({ error: "BPM, duration, and offset must be numbers" });

    if (offset && offset < 0)
      return res.status(400).json({ error: "Offset cannot be negative" });

    if (!req.files.pakage)
      return res.status(400).json({ error: "Map package file is required" });

    const packageFile = req.files.pakage;
    const packageUrl = `/uploads/${Date.now()}_${packageFile.name}`;
    await packageFile.mv(`./public${packageUrl}`);

    const newMap = await Map.create({
      name,
      artist,
      creator: req.session.userId,
      bpm,
      offset: offset || 0,
      duration,
      packageUrl,
      inputs,
    });

    res.status(201).json({ status: "success", map: newMap });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.deleteMap = async (req, res) => {
  try {
    const { mapId } = req.params;
    const map = await Map.findById(mapId);
    if (!map) {
      return res.status(404).json({ error: "Map not found" });
    }
    const user = await User.findById(req.session.userId).select("-password");
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (
      user.role !== "admin" &&
      map.creator.toString() !== user._id.toString()
    ) {
      return res.status(403).json({ error: "Unauthorized" });
    }
    fs.unlink(`./public${map.packageUrl}`, (err) => {
      if (err) {
        console.error("Failed to delete map package file:", err);
      }
    });
    await Map.findByIdAndDelete(mapId);
    res.status(200).json({ status: "success" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
