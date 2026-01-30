import express from "express";

const app = express();
const PORT = process.env.PORT || 4000;

app.use(express.json());

app.get("/", (_req, res) => {
  res.json({ message: "RacePredict API is up and running!" });
});

app.listen(PORT, () => {
  console.log(`🚀 Backend API listening at http://localhost:${PORT}`);
});
