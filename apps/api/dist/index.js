import express from "express";
const app = express();
const port = process.env.PORT ?? 3000;
app.get("/api/v1/health", (_req, res) => {
    res.json({ status: "ok" });
});
app.listen(port, () => {
    console.log(`API running on http://localhost:${port}`);
});
