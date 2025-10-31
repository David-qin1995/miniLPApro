import request from './request'

export function getSettings() {
  return request({
    url: '/settings',
    method: 'get'
  })
}

export function updateSettings(data) {
  return request({
    url: '/settings',
    method: 'patch',
    data
  })
}

export function updateBehavior(data) {
  return request({
    url: '/settings/behavior',
    method: 'patch',
    data
  })
}

export function resetSettings() {
  return request({
    url: '/settings/reset',
    method: 'post'
  })
}

