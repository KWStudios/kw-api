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

  # Dog walk stuff

  # rubocop:disable MethodLength
  def get_dog_walk_json_string(dog_walk)
    dog_json_hash = get_dog_profile_json_hash(dog_walk.dogprofile)
    walk_json_hash = { id: dog_walk.id,
                       scheduled_time: dog_walk.scheduled_time,
                       type_of_job: dog_walk.type_of_job,
                       notes: dog_walk.notes,
                       was_acknowledged: dog_walk.was_acknowledged,
                       has_started: dog_walk.has_started,
                       was_finished: dog_walk.was_finished,
                       created_at: dog_walk.created_at,
                       updated_at: dog_walk.updated_at,
                       dog_profile: dog_json_hash }
    walk_success_json_string = JSON.generate(walk_json_hash)
    walk_success_json_string
  end

  def get_dog_walk_json_hash(dog_walk)
    dog_json_hash = get_dog_profile_json_hash(dog_walk.dogprofile)
    walk_json_hash = { id: dog_walk.id,
                       scheduled_time: dog_walk.scheduled_time,
                       type_of_job: dog_walk.type_of_job,
                       notes: dog_walk.notes,
                       was_acknowledged: dog_walk.was_acknowledged,
                       has_started: dog_walk.has_started,
                       was_finished: dog_walk.was_finished,
                       created_at: dog_walk.created_at,
                       updated_at: dog_walk.updated_at,
                       dog_profile: dog_json_hash }
    walk_json_hash
  end

  def get_dog_walks_for_dog_profile(dog_profile)
    dog_walks = dog_profile.dogwalks.all
    dog_walks
  end
end
