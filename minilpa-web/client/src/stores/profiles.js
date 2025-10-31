import { defineStore } from 'pinia'
import { ref } from 'vue'
import * as profilesApi from '@/api/profiles'

export const useProfilesStore = defineStore('profiles', () => {
  const profiles = ref([])
  const loading = ref(false)

  async function fetchProfiles() {
    loading.value = true
    try {
      const response = await profilesApi.getProfiles()
      if (response.success) {
        profiles.value = response.data
      }
    } catch (error) {
      console.error('Failed to fetch profiles:', error)
    } finally {
      loading.value = false
    }
  }

  async function addProfile(data) {
    try {
      const response = await profilesApi.createProfile(data)
      if (response.success) {
        profiles.value.push(response.data)
      }
      return response
    } catch (error) {
      console.error('Failed to add profile:', error)
      throw error
    }
  }

  async function enableProfile(id) {
    try {
      const response = await profilesApi.enableProfile(id)
      if (response.success) {
        await fetchProfiles()
      }
      return response
    } catch (error) {
      console.error('Failed to enable profile:', error)
      throw error
    }
  }

  async function disableProfile(id) {
    try {
      const response = await profilesApi.disableProfile(id)
      if (response.success) {
        await fetchProfiles()
      }
      return response
    } catch (error) {
      console.error('Failed to disable profile:', error)
      throw error
    }
  }

  async function updateProfile(id, data) {
    try {
      const response = await profilesApi.updateProfile(id, data)
      if (response.success) {
        const index = profiles.value.findIndex(p => p.id === id)
        if (index !== -1) {
          profiles.value[index] = response.data
        }
      }
      return response
    } catch (error) {
      console.error('Failed to update profile:', error)
      throw error
    }
  }

  async function deleteProfile(id) {
    try {
      const response = await profilesApi.deleteProfile(id)
      if (response.success) {
        profiles.value = profiles.value.filter(p => p.id !== id)
      }
      return response
    } catch (error) {
      console.error('Failed to delete profile:', error)
      throw error
    }
  }

  return {
    profiles,
    loading,
    fetchProfiles,
    addProfile,
    enableProfile,
    disableProfile,
    updateProfile,
    deleteProfile
  }
})

