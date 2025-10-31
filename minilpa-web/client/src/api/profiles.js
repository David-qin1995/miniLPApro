import request from './request'

export function getProfiles() {
  return request({
    url: '/profiles',
    method: 'get'
  })
}

export function getProfile(id) {
  return request({
    url: `/profiles/${id}`,
    method: 'get'
  })
}

export function createProfile(data) {
  return request({
    url: '/profiles',
    method: 'post',
    data
  })
}

export function enableProfile(id) {
  return request({
    url: `/profiles/${id}/enable`,
    method: 'post'
  })
}

export function disableProfile(id) {
  return request({
    url: `/profiles/${id}/disable`,
    method: 'post'
  })
}

export function updateProfile(id, data) {
  return request({
    url: `/profiles/${id}`,
    method: 'patch',
    data
  })
}

export function deleteProfile(id) {
  return request({
    url: `/profiles/${id}`,
    method: 'delete'
  })
}

