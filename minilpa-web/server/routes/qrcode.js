const express = require('express');
const router = express.Router();
const multer = require('multer');
const Jimp = require('jimp');
const jsQR = require('jsqr');
const path = require('path');

// 配置文件上传
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads'));
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({ 
  storage,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760 }
});

// 解析二维码图片
router.post('/parse', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No image file provided' });
    }
    
    // 读取图片
    const image = await Jimp.read(req.file.path);
    const imageData = {
      data: new Uint8ClampedArray(image.bitmap.data),
      width: image.bitmap.width,
      height: image.bitmap.height
    };
    
    // 解析二维码
    const code = jsQR(imageData.data, imageData.width, imageData.height);
    
    if (!code) {
      return res.status(400).json({ 
        success: false, 
        error: 'No QR code found in the image' 
      });
    }
    
    // 解析激活码
    const activationCode = parseActivationCode(code.data);
    
    res.json({ 
      success: true, 
      data: {
        rawData: code.data,
        ...activationCode
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 从文本解析激活码
router.post('/parse-text', (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({ success: false, error: 'No text provided' });
    }
    
    const activationCode = parseActivationCode(text);
    
    res.json({ 
      success: true, 
      data: activationCode
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 解析激活码的辅助函数
function parseActivationCode(text) {
  // LPA:1$smdp.example.com$ACTIVATION-CODE
  const lpaPattern = /^LPA:1\$([^\$]+)\$([^\$]+)(?:\$([^\$]+))?/i;
  const match = text.match(lpaPattern);
  
  if (match) {
    return {
      format: 'lpa',
      smdpAddress: match[1],
      matchingId: match[2],
      confirmationCode: match[3] || '',
      activationCode: text
    };
  }
  
  // 如果不是标准格式，尝试提取域名和激活码
  const urlPattern = /(https?:\/\/)?([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/;
  const urlMatch = text.match(urlPattern);
  
  return {
    format: 'unknown',
    smdpAddress: urlMatch ? urlMatch[2] : '',
    activationCode: text
  };
}

module.exports = router;

