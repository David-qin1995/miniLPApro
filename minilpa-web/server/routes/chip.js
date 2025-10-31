const express = require('express');
const router = express.Router();
const lpacService = require('../lpac/service');

// 获取芯片信息
router.get('/', async (req, res) => {
  try {
    const chipInfo = await lpacService.getChipInfo();
    res.json({ success: true, data: chipInfo });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 获取芯片证书信息
router.get('/certificate', async (req, res) => {
  try {
    const certificate = {
      subject: {
        commonName: 'eUICC Certificate',
        organization: 'STMicroelectronics',
        country: 'FR'
      },
      issuer: {
        commonName: 'GSMA Root CI',
        organization: 'GSMA',
        country: 'GB'
      },
      serialNumber: '1234567890ABCDEF',
      validFrom: '2023-01-01T00:00:00Z',
      validTo: '2033-01-01T00:00:00Z',
      publicKey: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...'
    };
    
    res.json({ success: true, data: certificate });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

