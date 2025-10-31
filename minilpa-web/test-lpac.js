#!/usr/bin/env node

/**
 * LPAC 集成测试脚本
 * 测试 lpac 是否正确配置和可用
 */

require('dotenv').config();
const LPACExecutor = require('./server/lpac/executor');

const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testLPAC() {
  log('\n╔═══════════════════════════════════════╗', 'bright');
  log('║   LPAC 集成测试                       ║', 'bright');
  log('╚═══════════════════════════════════════╝\n', 'bright');

  const executor = new LPACExecutor();
  
  // 测试 1: 检查配置
  log('📋 当前配置:', 'blue');
  log(`  • 使用模拟数据: ${process.env.USE_MOCK_DATA || 'true'}`, 'yellow');
  log(`  • APDU 驱动: ${process.env.APDU_DRIVER || 'auto'}`, 'yellow');
  log(`  • 日志级别: ${process.env.LPAC_LOG_LEVEL || 'info'}`, 'yellow');
  log(`  • lpac 路径: ${executor.lpacPath}\n`, 'yellow');

  // 测试 2: 检查 lpac 可用性
  log('🔍 测试 1: 检查 lpac 可用性...', 'blue');
  try {
    const status = await executor.checkAvailability();
    if (status.available) {
      log('  ✅ lpac 可用', 'green');
      log(`  版本: ${status.version}`, 'green');
      log(`  路径: ${status.path}\n`, 'green');
    } else {
      log('  ❌ lpac 不可用', 'red');
      log(`  错误: ${status.error}`, 'red');
      log(`  提示: ${status.hint}\n`, 'yellow');
      log('💡 lpac 未安装？查看安装指南:', 'yellow');
      log('  docs/lpac-integration.md', 'yellow');
      log('  或运行模拟模式: USE_MOCK_DATA=true\n', 'yellow');
      return;
    }
  } catch (error) {
    log('  ❌ 测试失败', 'red');
    log(`  错误: ${error.message}\n`, 'red');
    return;
  }

  // 测试 3: 获取芯片信息
  log('🔍 测试 2: 获取芯片信息...', 'blue');
  try {
    const chipInfo = await executor.getChipInfo();
    log('  ✅ 成功获取芯片信息', 'green');
    if (chipInfo.eid) {
      log(`  EID: ${chipInfo.eid}`, 'green');
    }
    if (chipInfo.raw) {
      log('  原始输出:', 'green');
      log(chipInfo.raw.substring(0, 200) + '...', 'green');
    }
    log('');
  } catch (error) {
    log('  ⚠️  无法获取芯片信息', 'yellow');
    log(`  原因: ${error.error || error.message}`, 'yellow');
    log('  这可能是因为:', 'yellow');
    log('  • 没有连接 eSIM 卡', 'yellow');
    log('  • PCSC 服务未运行', 'yellow');
    log('  • 读卡器未连接\n', 'yellow');
  }

  // 测试 4: 列出 Profiles
  log('🔍 测试 3: 列出 Profiles...', 'blue');
  try {
    const profiles = await executor.listProfiles();
    if (Array.isArray(profiles)) {
      log(`  ✅ 成功获取 Profiles 列表`, 'green');
      log(`  共 ${profiles.length} 个 Profile\n`, 'green');
    } else {
      log('  ✅ 命令执行成功', 'green');
      if (profiles.raw) {
        log('  原始输出:', 'green');
        log(profiles.raw.substring(0, 200) + '...', 'green');
      }
      log('');
    }
  } catch (error) {
    log('  ⚠️  无法获取 Profiles', 'yellow');
    log(`  原因: ${error.error || error.message}\n`, 'yellow');
  }

  // 测试 5: 列出通知
  log('🔍 测试 4: 列出通知...', 'blue');
  try {
    const notifications = await executor.listNotifications();
    if (Array.isArray(notifications)) {
      log(`  ✅ 成功获取通知列表`, 'green');
      log(`  共 ${notifications.length} 条通知\n`, 'green');
    } else {
      log('  ✅ 命令执行成功', 'green');
      if (notifications.raw) {
        log('  原始输出:', 'green');
        log(notifications.raw.substring(0, 200) + '...', 'green');
      }
      log('');
    }
  } catch (error) {
    log('  ⚠️  无法获取通知', 'yellow');
    log(`  原因: ${error.error || error.message}\n`, 'yellow');
  }

  // 总结
  log('╔═══════════════════════════════════════╗', 'bright');
  log('║   测试完成                            ║', 'bright');
  log('╚═══════════════════════════════════════╝\n', 'bright');
  
  log('📖 下一步:', 'blue');
  log('  • 如果 lpac 可用，设置 USE_MOCK_DATA=false', 'yellow');
  log('  • 如果 lpac 不可用，继续使用模拟模式', 'yellow');
  log('  • 查看完整文档: docs/lpac-integration.md\n', 'yellow');
}

// 运行测试
testLPAC().catch(error => {
  log(`\n❌ 测试过程出错: ${error.message}\n`, 'red');
  process.exit(1);
});

