const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const path = require('path');
const fs = require('fs');

// 确保数据目录存在
const dataDir = path.join(__dirname, '../data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir, { recursive: true });
}

const dbPath = process.env.DB_PATH || path.join(dataDir, 'db.json');
const adapter = new FileSync(dbPath);
const db = low(adapter);

// 初始化数据库结构
db.defaults({
  profiles: [],
  notifications: [],
  chips: [],
  settings: {
    language: 'zh-CN',
    theme: 'auto',
    daytimeTheme: 'FlatMacLightLaf',
    nighttimeTheme: 'FlatMacDarkLaf',
    autoNightMode: 'SYSTEM',
    emojiDesign: 'twemoji',
    behavior: {
      sendInstallNotification: false,
      removeInstallNotification: false,
      sendEnableNotification: false,
      removeEnableNotification: false,
      sendDisableNotification: false,
      removeDisableNotification: false,
      sendDeleteNotification: false,
      removeDeleteNotification: false
    }
  }
}).write();

module.exports = db;

