import request from './request'

export function getNotifications() {
  return request({
    url: '/notifications',
    method: 'get'
  })
}

export function getNotification(id) {
  return request({
    url: `/notifications/${id}`,
    method: 'get'
  })
}

export function createNotification(data) {
  return request({
    url: '/notifications',
    method: 'post',
    data
  })
}

export function processNotification(id) {
  return request({
    url: `/notifications/${id}/process`,
    method: 'post'
  })
}

export function deleteNotification(id) {
  return request({
    url: `/notifications/${id}`,
    method: 'delete'
  })
}

export function batchDeleteNotifications(ids) {
  return request({
    url: '/notifications/batch/delete',
    method: 'post',
    data: { ids }
  })
}

export function batchProcessNotifications(ids) {
  return request({
    url: '/notifications/batch/process',
    method: 'post',
    data: { ids }
  })
}

