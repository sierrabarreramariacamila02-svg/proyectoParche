import { Router } from 'express';
import { listarBanners, crear, eliminar } from '../controllers/banner.js';
import upload from '../middlewares/multer.js';

const router = Router();

router.get('/banners', listarBanners);
router.post('/banners', upload.single('imagen'), crear);
router.delete('/banners/:id', eliminar);

export default router;