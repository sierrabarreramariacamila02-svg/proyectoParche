import multer from 'multer';

// Guarda temporalmente en memoria para enviarlo directo a la nube
const storage = multer.memoryStorage(); 

const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Solo se permiten imágenes'), false);
    }
};

const upload = multer({ storage, fileFilter });
export default upload;