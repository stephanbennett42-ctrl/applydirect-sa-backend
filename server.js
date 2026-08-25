const express = require("express");
const cors = require("cors");
const db = require("./db");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// GET: Fetch all institutions
app.get("/api/institutions", async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM institutions ORDER BY name ASC",
    );
    res.json({ success: true, count: rows.length, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET: Fetch single institution details by ID
app.get("/api/institutions/:id", async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM institutions WHERE institution_id = ?",
      [req.params.id],
    );
    if (rows.length === 0)
      return res
        .status(404)
        .json({ success: false, message: "Institution not found" });
    res.json({ success: true, data: rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Backend server running on port ${PORT}`));
