import express from "express";

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware for JSON parsing
app.use(express.json());

// Root endpoint (health check)
app.get("/", (_req, res) => {
  res.json({ message: "RacePredict API is up and running!" });
});

// Start the server
app.listen(PORT, () => {
  console.log(`🚀 Backend API listening at http://localhost:${PORT}`);
});
