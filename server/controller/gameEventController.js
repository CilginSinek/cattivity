const Map = require("../models/Map");
const User = require("../models/User");
const Play = require("../models/Play");
const fs = require("fs");

exports.savePlay = async (req, res) => {
  try {
    const userId = req.userId;
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
    const resplay = await play.populate([
      { path: "player", select: "name coalition" },
      { path: "playedMap", select: "name artist creator" },
    ]);
    map.playCount += 1;
    await map.save();
    res.status(201).json({ status: "success", resplay });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.uploadMap = async (req, res) => {
  try {
    const {
      name,
      artist,
      bpm,
      offset,
      duration,
      description,
      difficulty,
      tags,
    } = req.body;

    if (!name || !artist || !bpm || !duration)
      return res.status(400).json({ error: "Missing required fields" });

    if (isNaN(bpm) || isNaN(duration) || (offset && isNaN(offset)))
      return res
        .status(400)
        .json({ error: "BPM, duration, and offset must be numbers" });

    if (offset && offset < 0)
      return res.status(400).json({ error: "Offset cannot be negative" });

    const files = req.files || {};
    const audioFile =
      files.audio || files.audioFile || files.song || files.sound;
    const jsonFile =
      files.map || files.mapFile || files.beatmap || files.json || files.file;

    if (!audioFile || !jsonFile) {
      return res
        .status(400)
        .json({ error: "Audio and map JSON files are required" });
    }

    const timestamp = Date.now();
    const audioUrl = `/uploads/${timestamp}_${audioFile.name}`;
    const fileUrl = `/uploads/${timestamp}_${jsonFile.name}`;

    await audioFile.mv(`./public${audioUrl}`);
    await jsonFile.mv(`./public${fileUrl}`);

    const newMap = await Map.create({
      name,
      artist,
      creator: req.userId,
      bpm,
      offset: offset || 0,
      duration,
      description: description || "",
      difficulty,
      tags,
      fileUrl,
      audioUrl,
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
    const user = await User.findById(req.userId).select("-password");
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (
      user.role !== "admin" &&
      map.creator.toString() !== user._id.toString()
    ) {
      return res.status(403).json({ error: "Unauthorized" });
    }
    const filePaths = [map.fileUrl, map.audioUrl].filter(Boolean);
    filePaths.forEach((filePath) => {
      fs.unlink(`./public${filePath}`, (err) => {
        if (err) {
          console.error("Failed to delete map file:", err);
        }
      });
    });
    await Map.findByIdAndDelete(mapId);
    res.status(200).json({ status: "success" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
