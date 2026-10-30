import { Router } from 'express';
import { listarBanners, crear, eliminar } from '../controllers/banner.js';
import upload from '../middlewares/multer.js';

const router = Router();

router.get('/', listarBanners);
router.post('/', upload.single('imagen'), crear);
router.delete('/:id', eliminar);

export default router;