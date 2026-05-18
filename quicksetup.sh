#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$ROOT_DIR/server"
ENV_FILE="$SERVER_DIR/.env"

if [[ ! -d "$SERVER_DIR" ]]; then
	echo "ERROR: server klasoru bulunamadi: $SERVER_DIR"
	exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
	echo "ERROR: $ENV_FILE bulunamadi. .env.example dosyasini kopyalayip MONGOURL ekleyin."
	exit 1
fi

MONGOURL="$(grep -E '^MONGOURL=' "$ENV_FILE" | head -n 1 | cut -d '=' -f2- || true)"
MONGOURL="${MONGOURL//$'\r'/}"
MONGOURL="${MONGOURL#\"}"
MONGOURL="${MONGOURL%\"}"
MONGOURL="${MONGOURL#\'}"
MONGOURL="${MONGOURL%\'}"

if [[ -z "$MONGOURL" ]]; then
	echo "ERROR: server/.env icinde MONGOURL bos. MongoDB URL ekleyip tekrar calistirin."
	exit 1
fi

export MONGOURL

echo "Server bagimliliklari yukleniyor (npm install)..."
(cd "$SERVER_DIR" && npm install)

echo "Map dokumani ekleniyor..."
(cd "$SERVER_DIR" && node - <<'NODE'
const mongoose = require("mongoose");
const MapModel = require("./models/Map");

const mongoUrl = process.env.MONGOURL;
if (!mongoUrl) {
	console.error("MONGOURL env ayarlanamadi.");
	process.exit(1);
}

const mapDoc = {
	_id: new mongoose.Types.ObjectId("6a0a2ae9ad322f9fbab0bff2"),
	name: "running",
	artist: "Sinek",
	creator: new mongoose.Types.ObjectId("6a0a2a65dcdf9dbefad9f309"),
	description: "",
	bpm: 160.7,
	offset: 2000,
	duration: 169877,
	fileUrl: "/public/running.json",
	audioUrl: "/public/running.mp3",
	difficulty: "Normal",
	tags: [],
	playCount: 89,
};

async function run() {
	await mongoose.connect(mongoUrl, {});
	const result = await MapModel.updateOne(
		{ _id: mapDoc._id },
		{ $setOnInsert: mapDoc },
		{ upsert: true },
	);

	if (result.upsertedCount === 0) {
		console.log("Map zaten var. Ekleme atlandi.");
	} else {
		console.log("Map eklendi.");
	}

	await mongoose.disconnect();
}

run().catch((err) => {
	console.error("Map ekleme hatasi:", err);
	process.exit(1);
});
NODE
)

echo ""
echo "Serveri calistirmak icin:"
echo "  cd server"
echo "  npm start"
echo ""
echo "Godot web build icin:"
echo "  Webe build alin"
echo "  build directory icinde: python -m http.server 9080"
