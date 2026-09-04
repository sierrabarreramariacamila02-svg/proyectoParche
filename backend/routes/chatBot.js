import express from "express";
import { chatParche, obtenerHistorialELPARCHE } from "../controllers/chatBot.js";

const router = express.Router();

router.post("/", chatParche);
router.get("/historial/:sesionId", obtenerHistorialELPARCHE);

export default router;