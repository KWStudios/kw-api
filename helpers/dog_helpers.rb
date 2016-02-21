# encoding: utf-8

# Helpers for all dog related stuff
module DogHelpers
  def get_dog_profile_json_string(dog_profile)
    dog_json_hash = { id: dog_profile.id,
                      pet_species: dog_profile.pet_species,
                      pet_name: dog_profile.pet_name,
                      alarm_system_info: dog_profile.alarm_system_info,
                      pet_characteristics: dog_profile.pet_characteristics,
                      created_at: dog_profile.created_at,
                      updated_at: dog_profile.updated_at }
    dog_success_json_string = JSON.generate(dog_json_hash)
    dog_success_json_string
  end

  def get_dog_profile_json_hash(dog_profile)
    dog_json_hash = { id: dog_profile.id,
                      pet_species: dog_profile.pet_species,
                      pet_name: dog_profile.pet_name,
                      alarm_system_info: dog_profile.alarm_system_info,
                      pet_characteristics: dog_profile.pet_characteristics,
                      created_at: dog_profile.created_at,
                      updated_at: dog_profile.updated_at }
    dog_json_hash
  end

  def get_dog_profiles_for_profile(profile)
    dog_profiles = profile.dogprofiles.all
    dog_profiles
  end
end
