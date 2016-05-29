# encoding: utf-8

# Helpers for all dog related stuff
module DogHelpers
  def get_dog_profile_json_string(dog_profile)
    dog_json_hash = get_dog_profile_json_hash(dog_profile)
    dog_success_json_string = JSON.generate(dog_json_hash)
    dog_success_json_string
  end

  # rubocop:disable MethodLength
  def get_dog_profile_json_hash(dog_profile)
    dog_json_hash = { id: dog_profile.id,
                      pet_species: dog_profile.pet_species,
                      pet_name: dog_profile.pet_name,
                      pet_age: dog_profile.pet_age,
                      alarm_system_info: dog_profile.alarm_system_info,
                      pet_characteristics: dog_profile.pet_characteristics,
                      created_at: dog_profile.created_at,
                      updated_at: dog_profile.updated_at,
                      profile: get_profile_json_hash(dog_profile.profile),
                      profile_image:
                        get_gcs_image_json_hash(dog_profile.gcsimage) }
    dog_json_hash
  end

  def get_dog_profiles_for_profile(profile)
    dog_profiles = profile.dogprofiles.all
    dog_profiles
  end

  # Dog walk stuff

  def get_dog_walk_json_string(dog_walk)
    walk_json_hash = get_dog_walk_json_hash(dog_walk)
    walk_success_json_string = JSON.generate(walk_json_hash)
    walk_success_json_string
  end

  # rubocop:disable MethodLength, AbcSize
  def get_dog_walk_json_hash(dog_walk)
    assigned_profile_hash = nil
    unless dog_walk.profile.nil?
      assigned_profile_hash = get_profile_json_hash(dog_walk.profile)
    end

    job_images = []
    dog_walk.gcsimages.each do |gcs_image|
      job_images << get_gcs_image_json_hash(gcs_image)
    end

    dog_json_hash = get_dog_profile_json_hash(dog_walk.dogprofile)
    walk_json_hash = { id: dog_walk.id,
                       scheduled_time: dog_walk.scheduled_time,
                       timeframe_lower: dog_walk.timeframe_lower,
                       timeframe_upper: dog_walk.timeframe_upper,
                       type_of_job: dog_walk.type_of_job,
                       notes: dog_walk.notes,
                       was_acknowledged: dog_walk.was_acknowledged,
                       has_started: dog_walk.has_started,
                       was_finished: dog_walk.was_finished,
                       is_weekly: dog_walk.is_weekly,
                       start_date: dog_walk.start_date,
                       end_date: dog_walk.end_date,
                       report: dog_walk.report,
                       created_at: dog_walk.created_at,
                       updated_at: dog_walk.updated_at,
                       job_images: job_images,
                       dog_profile: dog_json_hash,
                       assigned_profile: assigned_profile_hash }
    walk_json_hash
  end

  def get_dog_walks_for_dog_profile(dog_profile)
    dog_walks = dog_profile.dogwalks.all
    dog_walks
  end

  def get_dog_walks_for_profile(profile)
    dog_walks = profile.dogwalks.all
    dog_walks
  end

  def get_job_location_json_string(location)
    location_json_hash = get_job_location_json_hash(location)
    location_json_string = JSON.generate(location_json_hash)
    location_json_string
  end

  def get_job_location_json_hash(location)
    return {} if location.nil?

    location_json_hash = { latitude: location.latitude,
                           longitude: location.longitude }
    location_json_hash
  end
end
